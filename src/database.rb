# frozen_string_literal: true

require "json"
require "net/http"

class Database
  def initialize(url, api_key)
    @url = url
    @api_key = api_key
  end

  def read
    uri = URI(@url)
    request = Net::HTTP::Get.new(uri)
    request["Content-Type"] = "application/json"
    request["x-apikey"] = @api_key

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    JSON.parse response.body
  end
end
