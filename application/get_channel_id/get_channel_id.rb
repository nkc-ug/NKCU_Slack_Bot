# frozen-string-literal: true

def search_channelid(search_channel_name)
  require 'json'
  require 'http'

  slack_api_key = ENV['SLACK_API_KEY']

  response = HTTP.post('https://slack.com/api/channels.list', params: { token: slack_api_key })
  channel_list = JSON.parse(response)

  channel_id = nil

  channel_list['channels'].each do |channel|
    channel_id = channel['id'] if channel['name'] == search_channel_name
  end

  # return channel id
  channel_id
end
