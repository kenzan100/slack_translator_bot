require 'sinatra'
require 'rest-client'
require 'byebug'
require_relative 'translator'

SLACK_API_BASE_URL = 'https://slack.com/api/'
TOKEN = ENV['DOKUGAKU_SLACK_TOKEN']

post '/' do
  channel_id = params['channel_id']
  msg_count_candidate = params['text'].to_i
  msg_count = if msg_count_candidate > 0 && msg_count_candidate < 6
                msg_count_candidate
              else
                1
              end

  res = RestClient.post(SLACK_API_BASE_URL + 'channels.history',
                  token: TOKEN,
                  channel: channel_id,
                  count:   msg_count)
  res = JSON.parse(res)
  return res.to_s unless res["ok"] == true
  text_arr = res["messages"].map do |m_hash|
    m_hash["text"]
  end

  texts = text_arr.join(" ")
  translated_texts = MicrosoftTranslator.translate_text(texts)
  return translated_texts
end
