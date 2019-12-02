# frozen-string-literal: true

require 'json'
require 'http'
require 'eventmachine'
require 'faye/websocket'

# functions class
require "#{__dir__}/functions"

SLACK_API_KEY = ENV['SLACK_API_KEY']
BOT_NOTIFICATION_CHANNEL = search_channelid(ENV['BOT_NOTIFICATION_CHANNEL'])

loop do
  response = HTTP.post('https://slack.com/api/rtm.start',
                       params: { token: SLACK_API_KEY })

  rc = JSON.parse(response.body)

  websocket_url = rc['url']

  EM.run do
    # Starting Connection with Websocket
    websocket_connection = Faye::WebSocket::Client.new(websocket_url)
    functions = Functions.new(websocket_connection)

    # Run when Established Connection
    websocket_connection.on :open do
      p [:open]
    end

    # Accept response from RTM API
    websocket_connection.on :message do |event|
      data = JSON.parse(event.data)
      p [:Message, data]
      functions.search_reply(data)
    end

    # Run when Closing Connection
    websocket_connection.on :close do |event|
      p [:close, event.code]
      websocket_connection = nil
      EM.stop
    end
  end
end
