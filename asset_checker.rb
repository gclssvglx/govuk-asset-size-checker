# frozen_string_literal: true

require "net/http"

class AssetChecker
  attr_reader :url, :expected_size, :current_size

  def initialize(url, size)
    @url = url
    @expected_size = size
    check
  end

  def size_matches?
    current_size == expected_size
  end

  def report
    { url: url, expected_size: expected_size, current_size: current_size }
  end

  private

  def check
    uri = URI(url)
    request = Net::HTTP::Get.new(uri)
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end
    @current_size = response.body.bytesize
  end
end
