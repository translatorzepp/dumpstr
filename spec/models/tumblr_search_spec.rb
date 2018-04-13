require 'rails_helper'

RSpec.describe "TumblrSearch" do

  let(:blog) { "rlbmut" }

  let(:fake_response_success_empty) { {
    "liked_posts" => [],
    "msg" => "success",
  } }
  let(:fake_response_success_populated) { {
    "liked_posts" => [post_overcome_1, post_no_overcome_1, post_overcome_2, post_overcome_3],
    "msg" => "success",
  } }
  let(:fake_response_failure) { {
    "liked_posts" => [],
    "msg" => "made up error about user not having searchable likes",
    "status" => 401,
  } }

  let(:post_overcome_1)    { {"summary" => "who overcomes", "tags" => ["paradise lost"]}               }
  let(:post_no_overcome_1) { {"summary" => "by force", "tags" => ["paradise lost"]}                    }
  let(:post_overcome_2)    { {"summary" => "hath overcome", "tags" => ["paradise lost"]}               }
  let(:post_overcome_3)    { {"summary" => "but half his foe", "tags" => ["paradise lost","overcome"]} }

  before :each do
    @gateway_double = instance_double("TumblrGateway")
    @tumblrsearch = TumblrSearch.new(blog_to_search: blog, gateway: @gateway_double)
  end

  it "returns a hash with no error message and results when there are matching liked posts" do
    expect(@gateway_double).to receive(:all_liked_posts).with(blog).and_return(fake_response_success_populated)

    result = @tumblrsearch.find_liked_posts_matching(post_text: "Overcome")
    expect(result[:error_message]).to be(nil)
    expect(result[:posts]).to include(post_overcome_3, post_overcome_2, post_overcome_1)
  end

  it "returns a hash with no error message and empty result set when there are no matching liked posts" do
    expect(@gateway_double).to receive(:all_liked_posts).with(blog).and_return(fake_response_success_populated)

    result = @tumblrsearch.find_liked_posts_matching(post_text: "friend")
    expect(result).to eq({:error_message => nil, :posts => []})
  end

  it "returns a hash with no error message and empty result set when there are no liked posts at all" do
    expect(@gateway_double).to receive(:all_liked_posts).with(blog).and_return(fake_response_success_empty)

    result = @tumblrsearch.find_liked_posts_matching(post_text: "paradise")
    expect(result).to eq({:error_message => nil, :posts => []})
  end

  it "returns a hash with failure message when the request fails" do
    expect(@gateway_double).to receive(:all_liked_posts).with(blog).and_return(fake_response_failure)

    result = @tumblrsearch.find_liked_posts_matching(post_text: "overcome")
    expect(result).to eq({:error_message => "made up error about user not having searchable likes", :posts => []})
  end
end
