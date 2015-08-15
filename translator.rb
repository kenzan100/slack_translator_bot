require 'rest-client'

CLIENT_ID       = 'slack_translate_bot'
CLIENT_SECRET   = ENV['MICROSOFT_TRANSLATE_CLIENT_SECRET']
AUTHORIZE_URL   = 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13'
TRANSLATION_URL = 'http://api.microsofttranslator.com/V2/Http.svc/Translate'
SCOPE           = 'http://api.microsofttranslator.com'

class MicrosoftTranslator

  def self.translate_text(text)
    token = get_access_token
    response = RestClient::Request.execute(method: :get,
      url: "#{TRANSLATION_URL}?from=ja&to=en&text=#{CGI.escape(text)}",
      headers: {Authorization: "Bearer #{token}"}
    )
    response
  end

  def self.get_access_token
    access_token = nil
    response = RestClient.post(AUTHORIZE_URL,
                               client_id: CLIENT_ID,
                               client_secret: CLIENT_SECRET,
                               scope: SCOPE,
                               grant_type: "client_credentials"
                              )
    json           = JSON.parse(response)
    access_token   = json['access_token']
  end

  puts translate_text("Hello! What's your name?")
end
