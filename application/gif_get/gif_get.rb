# frozen-string-literal: true

def gif_get(search_query)
  require 'http'

  tenor_api_key = ENV['TENOR_API_KEY']
  response = JSON.parse(HTTP.get('https://api.giphy.com/v1/gifs/search',
                                 params: { api_key: tenor_api_key,
                                           q: search_query,
                                           limit: 50 }))
  if response['data'].empty?
    'SearchCount: 0'
  else
    response['data'].sample['images']['original']['url']
  end
end
