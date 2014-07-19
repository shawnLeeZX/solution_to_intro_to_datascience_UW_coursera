# encoding: utf-8
import sys
import json
import codecs

# ===========================================
# By default Python 2 tries to convert unicode into bytes using the ascii codec.
# One approach to tackle this is to check sys.stdout's encoding, and if it's
# unknown (None) wrap it into a codecs.Writer that can handle all characters
# that may occur. UTF-8 is usually a good choice, but other codecs are possible.
# ===========================================
def setupEncodingForStdio():
    Writer = codecs.getwriter('utf-8')
    if sys.stdout.encoding is None:
        sys.stdout = Writer(sys.stdout)
    if sys.stderr.encoding is None:
        sys.stderr = Writer(sys.stderr)

def loadSentDict(sent_file):
    '''
    Return dict with key being word and value being score.

    Parameters
    ----------
    sent_file : file contains sentiment words, in form of
                word<tab>sentiment_score

    ----------
    '''
    sent_dict = {}
    for line in sent_file:
        term, sent_score = line.split('\t')
        sent_score = int(sent_score)
        sent_dict[term] = sent_score

    return sent_dict

def tokenizeJsonTweets(json_tweet):
    '''
    Return a list which contains tokens extracted from tweet.

    Notes
    =====
    Return a empty list when the tweet is malformed.
    '''
    tweet = json.loads(json_tweet)
    # Find the tweet content for each tweet and compute its sentiment
    # score.
    try:
        tweet_text = tweet['text']
    except (KeyError):
        # This tweet is mal-formed, just ignore this tweet.
        return []
    terms = tweet_text.split(' ')
    should_stripped_chars = u'\n.?!~:;()。？！：；～……'
    for i in range(len(terms)):
        terms[i] = terms[i].strip(should_stripped_chars)

    return terms
