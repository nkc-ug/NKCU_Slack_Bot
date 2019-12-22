# frozen-string-literal: true

require 'json'

# getting a zoi image link
require "#{__dir__}/zoi/zoi_get"

# getting random gif link
require "#{__dir__}/gif_get/gif_get"

# searching channel id
require "#{__dir__}/get_channel_id/get_channel_id"

# shell_get
require "#{__dir__}/shell_get/shell_get"

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

    # Shellgei
    if data['type'] == 'message'
      # check writed snipet in messages
      if data['text'] =~ /```.*```/
        send_shellgei(data)
      end
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
    search_query = message_text
    search_query.slice!(0..7)

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

  ### sending gif_shellgei result
  #
  # @param `data` : incomming `Faye::WebSocket::Client#on :message`
  def send_shellgei(data)
    command = ''
    is_include_shellgei_exec = false

    # putting command text
    data['blocks'].each do |block_item|
      if block_item['type'] == 'rich_text'

        # eaching items
        block_item['elements'].each do |rich_text_item|
          if rich_text_item['type'] == 'text' && rich_text_item['text'].include?('shellgei_exec')
            is_include_shellgei_exec = true
          end

          if rich_text_item['type'] == 'rich_text_preformatted' && is_include_shellgei_exec
            command = rich_text_item['elements'][0]['text']
          end
        end

      end
    end

    # getting shell commands output
    shellget_result = if command != ''
                        "```#{shell_get(command)}```"
                      else
                        '書式に問題があるようです'
                      end
    # sending shell output
    @websocket_connection.send(
      {
        type: 'message',
        text: shellget_result,
        channel: data['channel']
      }.to_json
    )
  end
end
