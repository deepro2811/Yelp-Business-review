-- find the number of businesses in each category
with cte as (
select business_id, trim(A.value) as category
from tbl_yelp_businesses, 
lateral split_to_table(categories,',') A
)
select category, count(*) as no_of_business from cte
group by 1
order by 2 desc

--find top 10 users who have reviewed the maximum business in restaurant category

select r.user_id, count(distinct(r.business_id))
from yelp_review_table.public.tbl_yelp_reviews r inner join
businessreviews.public.tbl_yelp_businesses b on
r.business_id=b.business_id 
where b.categories ilike '%restaurant%' 
group by 1
order by 2 desc
limit 10

--Find the most popular categories of businesses (based on number of reviews)

with cte as (
select business_id, trim(A.value) as category
from tbl_yelp_businesses, 
lateral split_to_table(categories,',') A
)
select category, count(*) as no_of_reviews
from cte 
inner join yelp_review_table.public.tbl_yelp_reviews r on 
cte.business_id = r.business_id
group by 1
order by 2 desc

--top 3 most recent review for business
with cte as (
select r.*,b.name, 
row_number() over (partition by r.business_id order by review_date desc) as rnk
from yelp_review_table.public.tbl_yelp_reviews r inner join
businessreviews.public.tbl_yelp_businesses b on
r.business_id=b.business_id
)
select * from cte
where rnk <=3

--month with highest number of reviews

SELECT 
  MONTH(TO_DATE(review_date)) AS review_month, 
  COUNT(*) AS no_review
FROM yelp_review_table.public.tbl_yelp_reviews 
GROUP BY 1
ORDER BY 2 DESC;

--find percentage of 5 star reviews in each business
select b.business_id,b.name,count(*) as total_reviews,count(case when r.review_stars=5 then 1 else null end) as five_star_reviews,
five_star_reviews*100/total_reviews as percent_five_star from yelp_review_table.public.tbl_yelp_reviews r inner join
businessreviews.public.tbl_yelp_businesses b on
r.business_id=b.business_id
group by 1,2

--top 5 businesses in each city
with cte as (
select b.city, b.business_id,b.name,count(*) as total_reviews,
from yelp_review_table.public.tbl_yelp_reviews r inner join
businessreviews.public.tbl_yelp_businesses b on
r.business_id=b.business_id
group by 1,2,3
order by 1
)

select * from cte
qualify row_number() over (partition by city order by total_reviews desc) <=5

-- find average rating of businesses with  with atleast 100 reviews
select b.city,b.name,count(*) as total_reviews,
avg(review_stars) as avg_rating
from yelp_review_table.public.tbl_yelp_reviews r inner join
businessreviews.public.tbl_yelp_businesses b on
r.business_id=b.business_id
group by 1,2
having count(*)>=100

-- List the top 10 users who have written the most reviews along with the businesses they have reviewed.

with cte as(
select r.user_id,count(*) as total_reviews,
from yelp_review_table.public.tbl_yelp_reviews r inner join
businessreviews.public.tbl_yelp_businesses b on
r.business_id=b.business_id
group by 1
order by 2 desc
limit 10)
select user_id, business_id from tbl_yelp_reviews where user_id in
(select user_id from cte)
group by 1,2
order by user_id desc

--find top 10 business with positive sentiment reviews
select r.business_id, b.name,count(*) as total_reviews,
from yelp_review_table.public.tbl_yelp_reviews r inner join
businessreviews.public.tbl_yelp_businesses b on
r.business_id=b.business_id
where sentiments = 'Positive'
group by 1,2
order by 3 desc
limit 10
order by 2 desc
