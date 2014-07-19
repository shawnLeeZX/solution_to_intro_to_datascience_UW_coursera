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

def main():
    tweet_file = open(sys.argv[1])

    setupEncodingForStdio()

    terms_freq_stat = {}
    terms_count_sum = 0
    for line in tweet_file:
        terms = tokenizeJsonTweets(line)

        # Count the occurrence of term in the tweet.
        for term in terms:
            terms_count_sum += 1
            if term not in terms_freq_stat:
                terms_freq_stat[term] = 1
            else:
                terms_freq_stat[term] += 1

    for term in terms_freq_stat:
        terms_freq_stat[term] /= float(terms_count_sum)
        print term + ' ' + unicode(terms_freq_stat[term])


if __name__ == '__main__':
    main()
