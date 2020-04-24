# frozen_string_literal:true

require 'open-uri'

# download file to `download_images/` directory
# @param endpoint <string> image file link
def download_file(endpoint)
  # 1. 'https://pbs.twimg.com/media/BspTawrCEAAwQnP.jpg:large' => 'media/BspTawrCEAAwQnP.jpg'
  # 2. 'media/BspTawrCEAAwQnP.jpg' => 'BspTawrCEAAwQnP.jpg'
  filename = endpoint[/media\/.*.jpg/][6..]

  URI.open(endpoint) do |binary|
    File.open("#{__dir__}/../download_images/#{filename}", mode = 'w'){|file|
      file.write(binary.read)
    }
    true
  end
rescue OpenURI::HTTPError
  'リソース取得に失敗しました'
end
