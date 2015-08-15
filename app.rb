require 'sinatra'
require 'rest-client'
require 'byebug'

get '/' do
  puts params
end
