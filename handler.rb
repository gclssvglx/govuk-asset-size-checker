require "json"
require "net/http"

require_relative "asset_checker"

def checker(event:, context:)
  uri = URI(ENV["RESTDB_GET_URL"])
  request = Net::HTTP::Get.new(uri)
  request["Content-Type"] = "application/json"
  request["x-apikey"] = ENV["RESTDB_API_KEY"]

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
    http.request(request)
  end

  file_sizes = JSON.parse response.body
  errors = []

  file_sizes.each do |entry|
    checker = AssetChecker.new(entry["url"], entry["file-size"])
    errors << checker.report unless checker.size_matches?
  end

  {
    status: 200,
    errors: errors
  }
end
