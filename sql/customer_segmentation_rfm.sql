-- ============================================================================
-- CUSTOMER SEGMENTATION — RFM ANALYSIS
-- ============================================================================
-- Business question:
--   Which reviewers actually drive engagement on the platform, and which
--   segments should a marketing / community team prioritise?
--
-- Method:
--   Classic RFM, adapted for review data:
--     Recency   — days since the user's most recent review (measured against
--                 the newest review date in the dataset, since this is a
--                 static snapshot rather than a live feed)
--     Frequency — total number of reviews written
--     Engagement (monetary proxy) — number of distinct businesses reviewed;
--                 breadth of engagement is the closest analogue to "spend"
--                 in a review dataset
--
--   Each dimension is scored 1-4 with NTILE(4), then users are mapped to
--   named segments a stakeholder can act on.
--
-- Depends on: tbl_yelp_reviews (see create_table.sql)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Per-user RFM base metrics
-- ----------------------------------------------------------------------------
with snapshot as (
    -- static dataset: anchor "today" to the newest review present
    select max(to_date(review_date)) as snapshot_date
    from tbl_yelp_reviews
),

user_metrics as (
    select
        r.user_id,
        datediff('day', max(to_date(r.review_date)), s.snapshot_date) as recency_days,
        count(*)                                                      as frequency,
        count(distinct r.business_id)                                 as businesses_reviewed,
        avg(r.review_stars)                                           as avg_stars_given,
        sum(case when r.sentiments = 'Positive' then 1 else 0 end)
            / count(*)                                                as positive_review_share
    from tbl_yelp_reviews r
    cross join snapshot s
    group by r.user_id, s.snapshot_date
),

-- ----------------------------------------------------------------------------
-- 2. Score each dimension 1-4 (4 = best)
--    Recency is inverted: the smaller the gap, the higher the score.
-- ----------------------------------------------------------------------------
rfm_scores as (
    select
        *,
        ntile(4) over (order by recency_days desc)        as recency_score,
        ntile(4) over (order by frequency)                as frequency_score,
        ntile(4) over (order by businesses_reviewed)      as engagement_score
    from user_metrics
),

-- ----------------------------------------------------------------------------
-- 3. Map score combinations to named, actionable segments
-- ----------------------------------------------------------------------------
segmented as (
    select
        *,
        case
            when frequency = 1 and recency_score <= 2
                then 'One-and-Done'          -- tried once, long gone: win-back or ignore
            when recency_score >= 3 and frequency_score >= 3
                then 'Power Reviewer'        -- active and prolific: nurture, early access
            when recency_score >= 3 and frequency_score <= 2
                then 'Promising Newcomer'    -- recent but light: onboard towards habit
            when recency_score <= 2 and frequency_score >= 3
                then 'At-Risk Regular'       -- used to be heavy, going quiet: re-engage now
            else 'Casual / Lapsed'           -- low activity, low recency: low-cost touch
        end as segment
    from rfm_scores
)

-- ----------------------------------------------------------------------------
-- 4. Segment summary — the stakeholder-facing output
-- ----------------------------------------------------------------------------
select
    segment,
    count(*)                                   as users,
    round(count(*) * 100.0 / sum(count(*)) over (), 1) as pct_of_users,
    round(avg(recency_days), 0)                as avg_recency_days,
    round(avg(frequency), 1)                   as avg_reviews_per_user,
    round(avg(businesses_reviewed), 1)         as avg_businesses_reviewed,
    round(avg(avg_stars_given), 2)             as avg_stars_given,
    round(avg(positive_review_share) * 100, 1) as pct_positive_reviews
from segmented
group by segment
order by users desc;

-- ----------------------------------------------------------------------------
-- Optional: user-level detail for downstream targeting / export
-- (uncomment to materialise)
-- ----------------------------------------------------------------------------
-- create or replace table tbl_user_rfm_segments as
-- select user_id, recency_days, frequency, businesses_reviewed,
--        recency_score, frequency_score, engagement_score, segment
-- from segmented;
