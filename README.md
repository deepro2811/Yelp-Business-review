# Yelp-Business-review
# Yelp Business Reviews Analysis on Snowflake

This project showcases an end-to-end data pipeline and analysis workflow using Snowflake. Yelp's academic dataset, containing business and review information, is loaded from an AWS S3 bucket into Snowflake. The project then demonstrates how to transform this data, perform sentiment analysis using a Python UDF, and derive meaningful insights through various analytical queries.

The SQL scripts containing the implementation for each step described below are located within the project's code folders.

## Table of Contents

-   [Features](#features)
-   [Prerequisites](#prerequisites)
-   [Project Workflow](#project-workflow)
    -   [Step 1: Data Ingestion from S3](#step-1-data-ingestion-from-s3)
    -   [Step 2: Sentiment Analysis with Python UDF](#step-2-sentiment-analysis-with-python-udf)
    -   [Step 3: Data Transformation and Structuring](#step-3-data-transformation-and-structuring)
    -   [Step 4: Data Analysis and Insights](#step-4-data-analysis-and-insights)
-   [Usage](#usage)
-   [Contributing](#contributing)
-   [License](#license)

## Features

*   **Cloud Data Ingestion**: Efficiently loads large JSON datasets from AWS S3 into Snowflake.
*   **In-Database Machine Learning**: Implements a serverless Python function directly within Snowflake for sentiment analysis on review text.
*   **Data Transformation**: Flattens and structures semi-structured JSON data into relational tables for optimized analytical querying.
*   **Comprehensive Data Analysis**: Provides a suite of analytical queries to uncover patterns and insights from the Yelp dataset.

## Prerequisites

To replicate this project, you will need:

*   An active **Snowflake Account**.
*   An **AWS S3 Bucket** containing the Yelp dataset JSON files (for businesses and reviews).
*   **AWS IAM Credentials** (Access Key ID and Secret Access Key) with read permissions for the S3 bucket.

## Project Workflow

The project follows a logical sequence of data engineering and analysis steps.

### Step 1: Data Ingestion from S3

The first step involves creating raw tables in Snowflake to stage the incoming JSON data. The `COPY INTO` command is used to efficiently load the Yelp business and review files directly from the specified S3 bucket into these staging tables.

### Step 2: Sentiment Analysis with Python UDF

A powerful feature of Snowflake, a Python User-Defined Function (UDF), is created to perform sentiment analysis. This function uses the `TextBlob` library to process review text and classify it as 'Positive', 'Neutral', or 'Negative'. This allows for sentiment analysis to be performed at scale directly within the database during data transformation.

### Step 3: Data Transformation and Structuring

The raw, semi-structured JSON data is not ideal for analysis. In this step, the data is parsed, cleaned, and transformed into structured, relational tables. One table is created for businesses (`tbl_yelp_businesses`) and another for reviews (`tbl_yelp_reviews`). During the creation of the reviews table, the sentiment analysis UDF is applied to each review text, enriching the data with a new `sentiments` column.

### Step 4: Data Analysis and Insights

With the data cleaned and structured, a wide range of analytical queries are performed to answer key business questions. The SQL scripts for these analyses can be found in the repository. The analyses include:

*   **Business Category Analysis**:
    *   Finding the total number of businesses per category.
    *   Identifying the most popular business categories based on the volume of reviews.

*   **User Activity Analysis**:
    *   Identifying the top 10 most active users in the 'Restaurant' category.
    *   Listing the top 10 users by their total number of reviews written.

*   **Review Trends**:
    *   Determining which month of the year has the highest number of reviews.
    *   Finding the three most recent reviews for every business.

*   **Business Rating Analysis**:
    *   Calculating the percentage of 5-star reviews for each business.
    *   Finding the average rating for businesses that have at least 100 reviews.
    *   Identifying the top 5 most-reviewed businesses within each city.

*   **Sentiment-Based Analysis**:
    *   Listing the top 10 businesses that receive the most 'Positive' sentiment reviews.

## Usage

To use this project:

1.  Ensure all prerequisites are met.
2.  Upload your Yelp dataset files to your AWS S3 bucket.
3.  Locate the SQL scripts in the project folders.
4.  Execute the scripts in your Snowflake environment in the logical order presented in the [Project Workflow](#project-workflow) section, making sure to replace placeholder credentials and S3 paths.

## Contributing

Contributions are welcome! If you have suggestions for improvements, new analyses, or bug fixes, feel free to open an issue or submit a pull request.

## License

This project is open-source and available under the [MIT License](LICENSE).
