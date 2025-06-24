CREATE OR REPLACE FUNCTION analyze_sentiments(review_text STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('textblob')
HANDLER = 'sentiment_analyzer'
AS
$$
from textblob import TextBlob

def sentiment_analyzer(review_text):
    if review_text is None:
        return 'Unknown'
    
    analysis = TextBlob(str(review_text))
    polarity = analysis.sentiment.polarity

    if polarity > 0:
        return 'Positive'
    elif polarity == 0:
        return 'Neutral'
    else:
        return 'Negative'
$$;
