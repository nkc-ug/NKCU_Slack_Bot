# frozen_string_literal:true

require 'net/http'
require 'json'

def shell_get(command)
  uri_at_shellgei = URI.parse('http://shellgei:4567')
  parameter = { command: command }
  # add Query parameter
  uri_at_shellgei.query = URI.encode_www_form(parameter)

  response_object = JSON.parse(Net::HTTP.get(uri_at_shellgei))

  # return response key object
  response_object['response']
end