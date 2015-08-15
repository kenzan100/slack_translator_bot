require 'sinatra'
require 'rest-client'
require 'byebug'

post '/' do
  puts params
  return params
end
