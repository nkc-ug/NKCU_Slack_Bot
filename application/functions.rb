# frozen-string-literal: true

require 'json'

# getting a zoi image link
require "#{__dir__}/zoi/zoi_get"

# getting random gif link
require "#{__dir__}/gif_get/gif_get"

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

    # Replying to `put_gif ~~`
    if data['text']
      send_gif(data['text'], data['channel']) if data['text'] =~ /\Aput_gif /
    end

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

  ### sending gif_get result
  #
  # @param `message_text` : `data['text']`
  # @param `channel` : sending channel
  def send_gif(message_text, channel)
    # delete string `put_gif` in message_text
    message_text.slice!(0..7)
    # check search_query is existing
    unless search_query.nil?
      @websocket_connection.send(
        {
          type: 'message',
          text: gif_get(search_query),
          channel: channel
        }.to_json
      )
    end
  end

end
