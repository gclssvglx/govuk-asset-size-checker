require_relative "../src/asset_size_checker"

RSpec.describe AssetSizeChecker do
  before do
    stub_request(:get, "http://www.example.com/")
      .with(
        headers: {
          "Content-Type" => "application/json",
          "X-Apikey" => "123456789"
        })
      .to_return(status: 200, body: [
        { "url" => "http://www.example.com/one", "file-size" => 1234 },
        { "url" => "http://www.example.com/two", "file-size" => 5678 }
      ].to_json
    )

    @checker = AssetSizeChecker.new(
      Database.new("http://www.example.com", "123456789"),
      "./spec/test_assets.yml",
      100
    )
  end

  describe "#initialize" do
    context "when asked for the tolerance" do
      it "returns the given tolerance" do
        expect(@checker.tolerance).to eq(100)
      end
    end
  end

  describe "#load_known_assets" do
    context "when asked to load the known assets" do
      it "returns an array of asset urls" do
        expected = [
          "http://www.example.com/one",
          "http://www.example.com/two"
        ]

        expect(@checker.load_known_assets).to eq(expected)
      end
    end
  end

  describe "#load_stored_assets" do
    context "when asked to load the stored assets" do
      it "returns a hash of asset urls and sizes" do
        expected = [
          { "url" => "http://www.example.com/one", "file-size" => 1234 },
          { "url" => "http://www.example.com/two", "file-size" => 5678 }
        ]

        expect(@checker.load_stored_assets).to eq(expected)
      end
    end
  end

  describe "#check" do
    before do
      stub_request(:get, "http://www.example.com/one")
        .to_return(status: 200, body: "1")
      stub_request(:get, "http://www.example.com/two")
        .to_return(status: 200, body: "12")
    end

    context "an asset in the assets file that does not exist in the database" do
      it "gets the asset size and adds a new record to the database" do
        stub_request(:get, "http://www.example.com/three")
          .to_return(status: 200, body: "123")

        allow(@checker).to receive(:load_known_assets) {
          [
            "http://www.example.com/one",
            "http://www.example.com/two",
            "http://www.example.com/three"
          ]
        }

        expect(@checker).to receive(:create_asset_size).with("http://www.example.com/three", 3)
        @checker.check
      end
    end

    context "an asset in the database where the size is within the tolerance" do
      it "does not update the database record" do
        expect(@checker).not_to receive(:update_asset_size).with("http://www.example.com/one", 1200)
        @checker.check
      end
    end

    context "an asset in the database where the size is not within the tolerance" do
      it "does update the database record with the new asset size" do
        stub_request(:get, "http://www.example.com/one")
          .to_return(status: 200, body: "123456")
        stub_request(:get, "http://www.example.com/two")
          .to_return(status: 200, body: "123456789")

        expect(@checker).to receive(:update_asset_size).with("http://www.example.com/one", 6)
        expect(@checker).to receive(:update_asset_size).with("http://www.example.com/two", 9)
        @checker.check
      end
    end

    context "all assets are the same size as expected" do
      it "does not create or update any records in the database" do
        expect(@checker).not_to receive(:create_asset_size).with("http://www.example.com/one", 1234)
        expect(@checker).not_to receive(:create_asset_size).with("http://www.example.com/two", 5678)

        expect(@checker).not_to receive(:update_asset_size).with("http://www.example.com/one", 1234)
        expect(@checker).not_to receive(:update_asset_size).with("http://www.example.com/two", 5678)
        @checker.check
      end
    end
  end

  describe "#within_tolerance?" do
    context "when passed an expected size that is lower than the tolerance allows" do
      it "returns false" do
        expect(@checker.within_tolerance?(99, 200)).to be false
      end
    end

    context "when passed an expected size that is higher than the tolerance allows" do
      it "returns false" do
        expect(@checker.within_tolerance?(301, 200)).to be false
      end
    end

    context "when passed an expected size that is within the tolerance limit" do
      it "returns true" do
        expect(@checker.within_tolerance?(250, 200)).to be true
      end
    end
  end

  describe "#notify" do
    context "when asked to notify" do
      it "returns a hash of the relevant details" do
        expect(@checker.notify("http://www.example.com/one", 1234, 1234)).to eq([
          {
            asset_url: "http://www.example.com/one",
            expected_size: 1234,
            current_size: 1234
          }
        ])
      end
    end
  end
end
