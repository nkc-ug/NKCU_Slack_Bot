# frozen-string-literal: true

require 'json'
require 'http'
require 'eventmachine'
require 'faye/websocket'

# getting a zoi image link
require "#{__dir__}/zoi/zoi_get"

# searching channel id
require "#{__dir__}/get_channel_id/get_channel_id"

SLACK_API_KEY = ENV['SLACK_API_KEY']
BOT_NOTIFICATION_CHANNEL = ENV['BOT_NOTIFICATION_CHANNEL']

def start_running_bot
  response = HTTP.post('https://slack.com/api/rtm.start',
                      params: { token: SLACK_API_KEY })

  rc = JSON.parse(response.body)

  websocket_url = rc['url']

  EM.run do
    # Starting Connection with Websocket
    websocket_connection = Faye::WebSocket::Client.new(websocket_url)

    # Run when Established Connection
    websocket_connection.on :open do
      p [:open]
    end

    # Accept response from RTM API
    websocket_connection.on :message do |event|
      data = JSON.parse(event.data)
      p [:Message, data]

      # 今日も一日
      if data['text'] == '今日も一日'
        websocket_connection.send(
          {
            type: 'message',
            text: zoi_get,
            channel: data['channel']
          }.to_json
        )
      end

      # notify when emojis published
      if data['type'] == 'emoji_changed'

        if data['subtype'] == 'add'
          emoji_name = data['name']

          websocket_connection.send(
            {
              type: 'message',
              text: "New Emojis Published! #{emoji_name}",
              channel: BOT_NOTIFICATION_CHANNEL
            }.to_json
          )
        end

      end
    end

    # Run when Closing Connection
    websocket_connection.on :cose do
      p [:close, event.code]
      websocket_connection = nil
      EM.stop
      # restart running bot process
      start_running_bot
    end
  end
end

start_running_bot
