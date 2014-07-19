# encoding: utf-8

import sys
import json

def main():
    sent_file = open(sys.argv[1])
    tweet_file = open(sys.argv[2])

    # Get sentiment dictionary for words.
    sent_dict = {}
    for line in sent_file:
        term, sent_score = line.split('\t')
        sent_score = int(sent_score)
        sent_dict[term] = sent_score


    # Convert streamed json-format tweet into dict in python.
    for line in tweet_file:
        tweet = json.loads(line)
        # Find the tweet content for each tweet and computer its sentiment
        # score.
        try:
            tweet_text = tweet['text']
        except (KeyError):
            # This tweet is mal-formed, just print a sentiment score of zero.
            print 0
            continue
        terms = tweet_text.split(' ')
        should_stripped_chars = u'\n.?!~:;()。？！：；～……'
        for i in range(len(terms)):
            terms[i] = terms[i].strip(should_stripped_chars)
        tweet_sent_score = 0
        for item in terms:
            try:
                item_score = sent_dict[item]
            except (KeyError):
                # The word is not in the sentiment dict, just ignore it.
                continue

            tweet_sent_score += item_score

        # Output sentiment score.
        print tweet_sent_score

if __name__ == '__main__':
    main()
