# frozen-string-literal: true

def zoi_get
  require 'json'
  require 'pp'

  zoi_list = []

  File.open("#{__dir__}/zoi.json") do |file|
    zoi_list = JSON.parse(file.read)
  end

  # return a randomly image link from zoi_list
  zoi_list.sample
end
