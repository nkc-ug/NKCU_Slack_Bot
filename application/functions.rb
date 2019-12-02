# frozen-string-literal: true

require 'json'
require 'http'
require 'faye/websocket'

# getting a zoi image link
require "#{__dir__}/zoi/zoi_get"

# searching channel id
require "#{__dir__}/get_channel_id/get_channel_id"

# Sending json data at Slack RTM API with websocket connnections
class Functions
  # initialize instance.
  # @param [websocket] websocket connection instance.(`Faye::WebSocket::Client`)
  def initialize(argument_websocket)
    @websocket_connection = argument_websocket
    @bot_notification_channel = search_channelid(ENV['BOT_NOTIFICATION_CHANNEL'])
  end

  # runnning functions
  #
  # @param [data] incomming `Faye::WebSocket::Client#on :message`
  def search_reply(data)
    # Replying to `今日も一日`
    kyomo_ichinichi(data['channel']) if data['text'] == '今日も一日'

    # notify when emojis published
    if data['type'] == 'emoji_changed'
      notify_adding_emoji(data['name']) if data['subtype'] == 'add'
    end

  end

  ### sending zoi_get
  #
  # @param [websocket] websocket connection instance.(`Faye::WebSocket::Client`)

  private

  def kyomo_ichinichi(channel)
    @websocket_connection.send(
      {
        type: 'message',
        text: zoi_get,
        channel: channel
      }.to_json
    )
  end

  ### notifying specified channnel at `bot_notification_channel`
  #
  # @param [data] incomming data(`Faye::WebSocket::Client#on :message`)

  def notify_adding_emoji(emoji_name)
    @websocket_connection.send(
      {
        type: 'message',
        text: "New Emojis Published! :#{emoji_name}:",
        channel: @bot_notification_channel
      }.to_json
    )
  end
end
