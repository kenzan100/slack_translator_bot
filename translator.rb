require 'rest-client'
require 'rexml/document'
require 'byebug'
require 'nokogiri'
require 'pp'

CLIENT_ID            = 'slack_translate_bot'
CLIENT_SECRET        = ENV['MICROSOFT_TRANSLATE_CLIENT_SECRET']
AUTHORIZE_URL        = 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13'
TRANSLATION_URL      = 'http://api.microsofttranslator.com/V2/Http.svc/Translate'
BULK_TRANSLATION_URL = 'http://api.microsofttranslator.com/V2/Http.svc/TranslateArray'
SCOPE                = 'http://api.microsofttranslator.com'

class MicrosoftTranslator
  def self.translate_single_text(text)
    token = get_access_token
    response = RestClient::Request.execute(method: :get,
      url: "#{TRANSLATION_URL}?from=ja&to=en&text=#{CGI.escape(text)}",
      headers: {
        Authorization: "Bearer #{token}",
      }
    )
    xml = REXML::Document.new(response)
    xml.root.text
  end

  def self.translate_texts(texts_arr)
    token = get_access_token
    response = RestClient.post(BULK_TRANSLATION_URL,
      translate_array_xml_builder(texts_arr, { from: 'ja', to: 'en' }),
      Authorization: "Bearer #{token}"
    )
    byebug
    xml = REXML::Document.new(response)
    xml.root.text
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

  def self.translate_array_xml_builder(text_array, params = {})
    data_contract = "http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2"
    serialization = "http://schemas.microsoft.com/2003/10/Serialization/Arrays"
    Nokogiri::XML::Builder.new do |xml|
      xml.TranslateArrayRequest {
        xml.AppId
        xml.From_ params[:from]
        xml.Options {
          xml.Category({xmlns: data_contract}, "general")
          xml.ContentType({xmlns: data_contract})
          xml.ReservedFlags({xmlns: data_contract})
          xml.State({xmlns: data_contract})
          xml.Uri({xmlns: data_contract})
          xml.User({xmlns: data_contract})
        }
        xml.Texts {
          text_array.each do |text|
            xml.string({xmlns: serialization}, text)
          end
        }
        xml.To_ params[:to]
      }
    end.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::AS_XML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION).strip
  end
end

# puts MicrosoftTranslator.translate_texts(["コンニチハ！"])
# pp MicrosoftTranslator.translate_array_xml_builder(["こんにちは"], { from: 'ja', to: 'en' })
