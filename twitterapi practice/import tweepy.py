import sys
sys.path.append('/Users/wuchi/Limjunhyoun/twitterapi practice/myvenv/Lib')
import tweepy
from common import *
import json
secretkey='django-insecure-54_)h8mpwy*j^p0u93^-bqyjtel06#s0ke4uh(br1b_@+yd0yp'
apikey='GTXHIZKs2B6kpsOwgFvpBmGb1'
apikeysecret='MiDErYRlw7iPkiFLCK4GBp4sfb7TENBwgIWm6adUVGm0di92Qu'
accesstoken='1544839648220188672-GhJsKSMc59wsObdotenSMe3eSaJvTTs'
accesstokensecret='W8qDgUOxOlsaQm4LlnMCGBZv8U4jpjkAvlvIVyP2n1R68'

# group=input('typegroup')
# api=connect_api()
# def UserTimelineCursor(screen_name):
#     tweets = tweepy.Cursor(api.user_timeline, screen_name=screen_name, tweet_mode="extended")
#     return tweets

# apiResult = get_tweet_by_keyword(api, group)
# print(apiResult)
# print(5)
# for i in apiResult:
#     print(i)
#     break

# "SECRET_KEY": "django-insecure-54_)h8mpwy*j^p0u93^-bqyjtel06#s0ke4uh(br1b_@+yd0yp",
#     "API_KEY": "GTXHIZKs2B6kpsOwgFvpBmGb1",
#     "API_KEY_SECRET": "MiDErYRlw7iPkiFLCK4GBp4sfb7TENBwgIWm6adUVGm0di92Qu",
#     "ACCESS_TOKEN": "1544839648220188672-GhJsKSMc59wsObdotenSMe3eSaJvTTs",
#     "ACCESS_TOKEN_SECRET": "W8qDgUOxOlsaQm4LlnMCGBZv8U4jpjkAvlvIVyP2n1R68"








api=connect_api()
tweets=get_tweet_by_keyword(api,'BTS')
print(tweets)
print(dir(type(tweets)))
print(type(tweets))
print(str(tweets))
print(tweets.__iter__())
# tweets=list(tweets)
# print(parse_tweet_response(tweets))

# # help(type(tweets))
for a in tweets:
    print(a)



