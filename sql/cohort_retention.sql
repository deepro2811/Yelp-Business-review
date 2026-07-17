-- ============================================================================
-- COHORT RETENTION ANALYSIS
-- ============================================================================
-- Business question:
--   Of the users who wrote their first review in a given month, how many are
--   still reviewing 1, 3, 6, 12 months later? Is user stickiness improving
--   or deteriorating across acquisition cohorts?
--
-- Method:
--   Users are grouped into monthly cohorts by the month of their FIRST review
--   (their "acquisition" month). For every later month in which they wrote at
--   least one review, we compute the offset in months from their cohort month.
--   Retention = distinct active users at each offset / cohort size.
--
-- Depends on: tbl_yelp_reviews (see create_table.sql)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Assign each user to an acquisition cohort (month of first review)
-- ----------------------------------------------------------------------------
with user_cohorts as (
    select
        user_id,
        date_trunc('month', min(to_date(review_date))) as cohort_month
    from tbl_yelp_reviews
    group by user_id
),

-- ----------------------------------------------------------------------------
-- 2. One row per user per active month
-- ----------------------------------------------------------------------------
user_activity as (
    select distinct
        user_id,
        date_trunc('month', to_date(review_date)) as activity_month
    from tbl_yelp_reviews
),

-- ----------------------------------------------------------------------------
-- 3. Months elapsed between cohort month and each active month
--    (offset 0 = the acquisition month itself, so retention there is 100%)
-- ----------------------------------------------------------------------------
cohort_activity as (
    select
        c.cohort_month,
        datediff('month', c.cohort_month, a.activity_month) as month_offset,
        a.user_id
    from user_cohorts c
    join user_activity a on c.user_id = a.user_id
),

cohort_sizes as (
    select cohort_month, count(*) as cohort_size
    from user_cohorts
    group by cohort_month
)

-- ----------------------------------------------------------------------------
-- 4a. Retention matrix (long format) — cohort x month offset
-- ----------------------------------------------------------------------------
select
    ca.cohort_month,
    cs.cohort_size,
    ca.month_offset,
    count(distinct ca.user_id)                                   as active_users,
    round(count(distinct ca.user_id) * 100.0 / cs.cohort_size, 1) as retention_pct
from cohort_activity ca
join cohort_sizes cs on ca.cohort_month = cs.cohort_month
group by ca.cohort_month, cs.cohort_size, ca.month_offset
order by ca.cohort_month, ca.month_offset;

-- ----------------------------------------------------------------------------
-- 4b. Wide retention table for key checkpoints (M1 / M3 / M6 / M12)
--     One row per cohort — the classic retention triangle, readable at a
--     glance and directly chartable in Power BI or a notebook.
-- ----------------------------------------------------------------------------
with user_cohorts as (
    select
        user_id,
        date_trunc('month', min(to_date(review_date))) as cohort_month
    from tbl_yelp_reviews
    group by user_id
),

user_activity as (
    select distinct
        user_id,
        date_trunc('month', to_date(review_date)) as activity_month
    from tbl_yelp_reviews
),

cohort_activity as (
    select
        c.cohort_month,
        c.user_id,
        datediff('month', c.cohort_month, a.activity_month) as month_offset
    from user_cohorts c
    join user_activity a on c.user_id = a.user_id
)

select
    cohort_month,
    count(distinct user_id)                                                        as cohort_size,
    round(count(distinct case when month_offset =  1 then user_id end) * 100.0
          / count(distinct user_id), 1)                                            as m1_retention_pct,
    round(count(distinct case when month_offset =  3 then user_id end) * 100.0
          / count(distinct user_id), 1)                                            as m3_retention_pct,
    round(count(distinct case when month_offset =  6 then user_id end) * 100.0
          / count(distinct user_id), 1)                                            as m6_retention_pct,
    round(count(distinct case when month_offset = 12 then user_id end) * 100.0
          / count(distinct user_id), 1)                                            as m12_retention_pct
from cohort_activity
group by cohort_month
order by cohort_month;
