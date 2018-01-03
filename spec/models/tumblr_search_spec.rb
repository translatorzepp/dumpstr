require 'rails_helper'

RSpec.describe "TumblrSearch" do

  @fake_response_success_empty = {"liked_posts": []}
  @fake_response_success_populated = {
    "liked_posts": [
      {"summary": "", "tags": ""},
      {"summary": "", "tags": ""},
      {"summary": "", "tags": ""},
      {"summary": "", "tags": ""},
    ]
  }
  @fake_response_failure = {"status": 401, "msg": "made up error about user not having searchable likes", "liked_posts": []}
  @blog = "rlbmut"

  before :each do
    @gateway_double = instance_double("TumblrGateway")
  end

  it "returns an empty hash" do
    expect(@gateway_double).to receive(:all_liked_posts).with(@blog).and_retur(@fake_response)
    t = TumblrSearch.new(@gateway_double, @blog)
    result = t.search_likes(post_text: "something")
    expect(result).to eq({})
  end
end
