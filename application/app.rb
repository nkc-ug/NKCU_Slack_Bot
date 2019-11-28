# frozen-string-literal: true

require 'json'
require 'http'
require 'eventmachine'
require 'faye/websocket'

# getting a zoi image link
require "#{__dir__}/zoi/zoi_get.rb"

SLACK_API_KEY = ENV['SLACK_API_KEY']

response = HTTP.post('https://slack.com/api/rtm.start',
                     params: { token: SLACK_API_KEY })

rc = JSON.parse(response.body)

WEBSOCKET_URL = rc['url']

EM.run do
  # Starting Connection with Websocket
  websocket_connection = Faye::WebSocket::Client.new(WEBSOCKET_URL)

  # Run when Established Connection
  websocket_connection.on :open do
    p [:open]
  end

  # Accept response from RTM API
  websocket_connection.on :message do |event|
    data = JSON.parse(event.data)
    p [:Message, data]
    if data['text'] == '今日も一日'
      websocket_connection.send(
        {
          type: 'message',
          text: zoi_get,
          channel: data['channel']
        }.to_json
      )
    end
  end

  # Run when Closing Connection
  websocket_connection.on :cose do
    p [:close, event.code]
    websocket_connection = nil
    EM.stop
  end
end
