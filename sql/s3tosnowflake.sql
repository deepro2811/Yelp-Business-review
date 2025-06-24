-- Fetching data from S3
COPY INTO yelp_businesses
FROM 's3://yelpreviewsbuckets3/yelp_academic_dataset_business.json'
CREDENTIALS = (
  AWS_KEY_ID = 'ENTER AWS KEY ID',
  AWS_SECRET_KEY = 'ENTER AWS SECRET KEY'
)
FILE_FORMAT = (
  TYPE = 'JSON'
);

COPY INTO yelp_reviews
FROM 's3://yelpreviewsbuckets3..../'
CREDENTIALS = (
  AWS_KEY_ID = 'ENTER AWS KEY ID',
  AWS_SECRET_KEY = 'ENTER AWS SECRET KEY'
)
FILE_FORMAT = (
  TYPE = 'JSON'
);
