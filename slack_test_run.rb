require 'rest-client'
require 'pp'

SLACK_API_BASE_URL = 'https://slack.com/api/'
GENERAL_CHANNEL_ID = 'C06TNBFAL'
TOKEN = ENV['DOKUGAKU_SLACK_TOKEN']

# res = RestClient.post(SLACK_API_BASE_URL + 'channels.list',
res = RestClient.post(SLACK_API_BASE_URL + 'channels.history',
  token:    TOKEN,
  channel:  GENERAL_CHANNEL_ID,
  count: 5
)

pp JSON.parse(res)

# channels = JSON.parse(res)['channels']
# pp channels.map{ |channel| {name: channel['name'], id: channel['id']} }
