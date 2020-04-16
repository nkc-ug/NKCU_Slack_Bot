# frozen_string_literal: true

require 'sinatra'
require 'json'
require './shell_get'

get '/' do
  shell_response = shell_get(params['command'])

  {
    response: shell_response
  }.to_json
end