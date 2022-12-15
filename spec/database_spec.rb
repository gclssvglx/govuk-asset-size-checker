require_relative "../src/database"

RSpec.describe Database, ".read" do
  context "reading the existing database records" do
    it "returns the assets and sizes" do
      stub_request(
        :get, "http://www.example.com"
      ).to_return(status: 200, body: {}.to_json, headers: {
        "Content-Type" => "application/json",
        "x-apikey" => "123456789"
      })

      db = Database.new("http://www.example.com", "123456789")
      expect(db.read).to eq({})
    end
  end
end
