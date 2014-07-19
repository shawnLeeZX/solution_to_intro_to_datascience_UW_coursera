# encoding: utf-8

import sys
import codecs
import json


# ===========================================
# By default Python 2 tries to convert unicode into bytes using the ascii codec.
# One approach to tackle this is to check sys.stdout's encoding, and if it's
# unknown (None) wrap it into a codecs.Writer that can handle all characters
# that may occur. UTF-8 is usually a good choice, but other codecs are possible.
# ====================================================================
def setupEncodingForStdio():
    Writer = codecs.getwriter('utf-8')
    if sys.stdout.encoding is None:
        sys.stdout = Writer(sys.stdout)
    if sys.stderr.encoding is None:
        sys.stderr = Writer(sys.stderr)

def hw():
    print 'Hello, world!'

def lines(fp):
    print str(len(fp.readlines()))

def main():
    sent_file = open(sys.argv[1])
    tweet_file = open(sys.argv[2])

    setupEncodingForStdio()

    # Get sentiment dictionary for words.
    sent_dict = {}
    for line in sent_file:
        term, sent_score = line.split('\t')
        sent_score = int(sent_score)
        sent_dict[term] = sent_score

    non_sent_dict = {}

    for line in tweet_file:
        tweet = json.loads(line)
        # Find the tweet content for each tweet and compute its sentiment
        # score.
        try:
            tweet_text = tweet['text']
        except (KeyError):
            # This tweet is mal-formed, just ignore this tweet.
            continue
        terms = tweet_text.split(' ')
        should_stripped_chars = u'\n.?!~:;()。？！：；～……'
        for i in range(len(terms)):
            terms[i] = terms[i].strip(should_stripped_chars)

        tweet_sent_score = 0
        for term in terms:
            if term in sent_dict:
                term_score = sent_dict[term]
            else:
                # The word is not in the sentiment dict, just ignore it.
                continue

            tweet_sent_score += term_score

        # Count the occurrence of term in the tweet.
        term_count = 0
        for term in terms:
            if term not in sent_dict:
                if term not in non_sent_dict:
                    term_stat = {}
                    term_count = 1
                    non_sent_dict[term] = term_stat
                else:
                    term_stat = non_sent_dict[term]
                    term_count += 1

        # Update non sentiment term score.
        for term in terms:
            if term in sent_dict:
                continue
            # Now the term should be in non_sent_dict, raise error when not.
            try:
                term_stat = non_sent_dict[term]
            except KeyError:
                print "Fatal error: term should be in the non_sent_dict ">> sys.stderr
                exit

            try:
                term_score = term_stat['score']
            # If the term does not have a score, it means it is newly added.
            # Compute its score based on this tweet.
            except KeyError:
                term_stat['score'] = tweet_sent_score / term_count
                term_stat['count'] = term_count
                continue

            # If the program reaches here, the term is an old term. Compute its
            # score based on history and current tweet.
            term_stat['score'] = (term_score * term_stat['count'] +
                    tweet_sent_score) / (term_stat['count'] + term_count)

            non_sent_dict[term] = term_stat

    for term in non_sent_dict:
        print term + ' ' + unicode(non_sent_dict[term]['score'])


if __name__ == '__main__':
    main()
