require 'pco_api'
require 'rubygems'
require 'json'
require 'dotenv'
require 'dotenv-rails'
require "net/http"
require "uri"

#
@settings = Setting.x

def send_text(target_num,cid,message)

    uri = URI.parse(@settings.nexmo_url)
    params = {
        'api_key' => @settings.nexmo_key,
        'api_secret' => @settings.nexmo_secret,
        'to' => target_num,
        'from' => cid,
        'text': message
    }

    response = Net::HTTP.post_form(uri, params)
    return response
end
