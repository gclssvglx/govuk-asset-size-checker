# frozen_string_literal: true

require_relative "src/asset_size_checker"

def checker(event:, context:)
  checker = AssetSizeChecker.new(
    Database.new(ENV["RESTDB_GET_URL"], ENV["RESTDB_API_KEY"]),
    "assets.yml",
    100
  )

  errors = []
  begin
    checker.check
  rescue => error
    errors << error.message
  end

  {
    status: 200,
    body: checker.inspect,
    errors: errors
  }
end
