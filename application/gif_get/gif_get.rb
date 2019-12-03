# frozen-string-literal: true

def gif_get(search_query)
  require 'http'

  giphy_api_key = ENV['GIPHY_API_KEY']
  response = HTTP.get('https://api.giphy.com/v1/gifs/search',
                      params: { api_key: giphy_api_key,
                                q: search_query,
                                limit: 50 })

  JSON.parse(response)['data'].sample['images']['original']['url']
end
