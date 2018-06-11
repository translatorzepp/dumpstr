require 'rails_helper'

RSpec.describe "TumblrGateway" do

  let(:successful_client_response) { {"liked_posts" => [{"summary" => "a post"}], "liked_count" => 1} }
  let(:failure_client_response) { {"status"=>404, "msg"=>"Not Found"} }

  let(:gateway) { TumblrGateway.new }

  describe "all_liked_posts" do
    before :each do
      @client_double = instance_double("Tumblr::Client")
      allow(Tumblr::Client).to receive(:new).and_return(@client_double)

      allow(@client_double).to receive(:blog_likes).with("existing", anything).and_return(successful_client_response)
      allow(@client_double).to receive(:blog_likes).with("unexisting", anything).and_return(failure_client_response)
    end

    it "on success, returns a hash with a collection of liked posts and a nil message" do
      success_result = gateway.all_liked_posts("existing")
      expect(success_result).to eq({"liked_posts" => [{"summary" => "a post"}], "message" => nil})
    end

    it "on failure, returns a hash with an empty collection of liked posts and an error message" do
      failure_result = gateway.all_liked_posts("unexisting")
      expect(failure_result).to eq({"liked_posts" => [], "message" => "This blog doesn't exist."})
    end

    it "logs on failure" do
      expect(Rails.logger).to receive(:error) do |log|
        expect(log).to include("Tumblr client error")
        expect(log).to include("404")
        expect(log).to include("Not Found")
      end

      failure_result = gateway.all_liked_posts("unexisting")
    end
  end
end
