# frozen_string_literal: true

require "net/http"
require "yaml"

require_relative "database"

class AssetSizeChecker
  attr_reader :db_connection, :asset_filename, :tolerance, :notifications

  def initialize(db_connection, asset_filename, tolerance)
    @db_connection = db_connection
    @asset_filename = asset_filename
    @tolerance = tolerance
    @notifications = []
  end

  def check
    stored_asset_urls = load_stored_assets.collect { |stored| stored["url"] }

    load_known_assets.each do |known_asset_url|
      current_asset_size = get_current_size(known_asset_url)
      create_asset_size(known_asset_url, current_asset_size) unless stored_asset_urls.include?(known_asset_url)
    end

    load_stored_assets.each do |asset|
      current_asset_size = get_current_size(asset["url"])

      unless within_tolerance?(current_asset_size, asset["file-size"])
        update_asset_size(asset["url"], current_asset_size)
        notify(asset["url"], current_asset_size, asset["file-size"])
      end
    end
  end

  def within_tolerance?(current_size, expected_size)
    current_size.between?(expected_size - tolerance, expected_size + tolerance)
  end

  def notify(asset_url, current_size, expected_size)
    notifications << {
      asset_url: asset_url,
      expected_size: expected_size,
      current_size: current_size
    }
  end

  def load_known_assets
    YAML.load(File.read(asset_filename))
  end

  def load_stored_assets
    db_connection.read
  end

private

  def get_current_size(asset_url)
    uri = URI(asset_url)
    request = Net::HTTP::Get.new(uri)
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end
    @current_size = response.body.bytesize
  end

  def create_asset_size(asset_url, current_size)
    # TODO
  end

  def update_asset_size(asset_url, current_size)
    # TODO
  end
end
