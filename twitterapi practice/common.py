import sys
sys.path.append('/Users/wuchi/Limjunhyoun/twitterapi practice/myvenv/Lib')
import tweepy
def connect_api() :
    #secretkey='django-insecure-54_)h8mpwy*j^p0u93^-bqyjtel06#s0ke4uh(br1b_@+yd0yp'
    apikey='GTXHIZKs2B6kpsOwgFvpBmGb1'
    apikeysecret='MiDErYRlw7iPkiFLCK4GBp4sfb7TENBwgIWm6adUVGm0di92Qu'
    accesstoken='1544839648220188672-GhJsKSMc59wsObdotenSMe3eSaJvTTs'
    accesstokensecret='W8qDgUOxOlsaQm4LlnMCGBZv8U4jpjkAvlvIVyP2n1R68'

    # 트위터에 접근하기
    auth = tweepy.OAuthHandler(apikey, apikeysecret)
    auth.set_access_token(accesstoken, accesstokensecret)
    api = tweepy.API(auth, wait_on_rate_limit=True)
    
    return api

def get_tweet_by_keyword(api, keyword) :
    cursor = tweepy.Cursor(api.search_tweets, q=keyword, count=10)#tweet_mode = 'extended')
    return cursor.items()

def parse_tweet_response(info) : 
    tmp = {}
    tmp['id'] = info['id']
    tmp['created_at'] = info['created_at']
    hashtags = info['retweeted_status']['entities']['hashtags']
    tmp['hashtags'] = [hashtag['text'] for hashtag in hashtags]
    tmp['full_text'] = info['retweeted_status']['full_text']

    # url 다시 찾아야함 원본 게시글 url
    tmp['tweet_url'] = tmp['full_text'][tmp['full_text'].find('http'):]
    tmp['retweet_count'] = info['retweeted_status']['retweet_count']
    tmp['favorite_count'] = info['retweeted_status']['favorite_count']
    # tmp['user_name'] = info['user']['name']
    tmp['user_screen_name'] = info['entities']['user_mentions'][0]['screen_name']
    tmp['user_name'] = info['entities']['user_mentions'][0]['name']
    tmp['user_profile_image_url'] = info['user']['profile_image_url']

    if 'extended_entities' in info :
        medias = info['retweeted_status']['extended_entities']['media']
        tmp['media_url'] = [media['media_url'] for media in medias]
    else :
        tmp['media_url'] = None

    return tmp
