#frozen_string_literal:true

require 'net/http'
require 'json'

uri_at_shellgei = URI.parse('http://shellgei:4567')
parameter = { command: 'ojichat' }
# add Query parameter
uri_at_shellgei.query = URI.encode_www_form(parameter)

response_object = JSON.parse(Net::HTTP.get(uri_at_shellgei))
puts response_object['response']
