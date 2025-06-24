--creating structured table from JSON table
create or replace table tbl_yelp_businesses as
select business_text:business_id::string as business_id,
business_text:name::string as name,
business_text:city::string as city,
business_text:state::string as state,
business_text:review_count::string as review_count,
business_text:stars::number as stars,
business_text:categories::string as categories
from yelp_businesses;

--creating tbl_yelp_reviews table

create or replace table tbl_yelp_reviews as
select review_text:business_id::string as business_id,
review_text:date::string as review_date,
review_text:user_id::string as user_id,
review_text:stars::number as review_stars,
review_text:text::string as reviews_text,
analyze_sentiments(review_text) as sentiments
from yelp_reviews limit 1000 

select * from tbl_yelp_reviews limit 5;
