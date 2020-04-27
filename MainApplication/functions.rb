# frozen-string-literal: true

require 'json'

# getting a zoi image link
require "#{__dir__}/zoi/zoi_get"

# getting random gif link
require "#{__dir__}/gif_get/gif_get"

# searching channel id
require "#{__dir__}/get_channel_id/get_channel_id"

# shell_get
require "#{__dir__}/shell_get"

## upload images class
require "#{__dir__}/file_provider/file_provider"

# Sending json data at Slack RTM API with websocket connections
class Functions
  # initialize instance.
  # @param [websocket] websocket connection instance.(`Faye::WebSocket::Client`)
  def initialize(argument_websocket)
    @websocket_connection = argument_websocket
    @bot_notification_channel = search_channel_id(ENV['BOT_NOTIFICATION_CHANNEL'])
  end

  # running functions
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
      # check written snippet in messages
      if data['text'] =~ /```.*```/

        data['blocks'].each do |block_item|
          if block_item['type'] == 'rich_text'

            # each items
            block_item['elements'].each do |rich_text_item|

              # checking include 'shellgei_exec' in top
              if rich_text_item['type'] == 'rich_text_section'

                rich_text_item['elements'].each do |section_elements|
                  if section_elements['type'] == 'text' && section_elements['text'].include?('shellgei_exec')
                    send_shellgei(data)
                  end
                end

              end
            end

          end

        end
      end
    end

    # notify when emoji published
    if data['type'] == 'emoji_changed'
      notify_adding_emoji(data['name']) if data['subtype'] == 'add'
    end

  end

  ### sending zoi_get
  #
  # @param [websocket] websocket connection instance.(`Faye::WebSocket::Client`)

  private

  def kyomo_ichinichi(channel)
    file_provider = FileProvider.new
    filepath = file_provider.download_file(zoi_get)
    result = file_provider.upload_file(filepath, channel)
    if result
      puts 'File Send Succeed.'
      FileUtils.rm(filepath)
    else
      puts 'File Send Failed.'
      puts "Failed File: #{filepath}"
    end
  end

  ### notifying specified channel at `bot_notification_channel`
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

      file_provider = FileProvider.new
      endpoint = gif_get(search_query)

      if endpoint == 'SearchCount: 0'
        @websocket_connection.send(
          {
            type: 'message',
            text: endpoint,
            channel: channel
          }.to_json
        )
      else
        filepath = file_provider.download_file(endpoint)
        result = file_provider.upload_file(filepath, channel)

        if result
          puts 'File Send Succeed.'
          FileUtils.rm(filepath)
        else
          puts 'File Send Failed.'
          puts "Failed File: #{filepath}"
        end
      end
    end
  end

  ### sending gif_shellgei result
  #
  # @param `data` : incoming `Faye::WebSocket::Client#on :message`
  def send_shellgei(data)
    command = ''

    # putting command text
    data['blocks'].each do |block_item|
      if block_item['type'] == 'rich_text'

        # each items
        block_item['elements'].each do |rich_text_item|

          if rich_text_item['type'] == 'rich_text_preformatted'
            # escape when snippet is empty
            unless rich_text_item['elements'].empty?
              command = rich_text_item['elements'][0]['text']
            end
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
