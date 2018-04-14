class TumblrGateway
  def initialize
    Tumblr.configure do |config|
      config.consumer_key = Rails.application.secrets.tumblr_consumer_key
      config.consumer_secret = Rails.application.secrets.tumblr_consumer_secret
      config.oauth_token = Rails.application.secrets.tumblr_oauth_token
      config.oauth_token_secret = Rails.application.secrets.tumblr_oauth_token_secret
    end

    @client = Tumblr::Client.new
  end

  def all_liked_posts(blog_to_search)
    result = {}

    # if request returns 200/201, it'll only return the response from the body
    #   otherwise, it'll return the 'meta' (incl status, msg) + body if it exists
    # will accept a max limit of 50. TODO: look at using offsets to get everything
    response_from_tumblr = @client.blog_likes(blog_to_search, {:limit => 50})

    if response_from_tumblr["status"]
      result["liked_posts"] = []
      result["message"] = response_from_tumblr["msg"]

      Rails.logger.error("Tumblr client error. Status Code #{response_from_tumblr['status']}. Message: #{response_from_tumblr['msg']}")
    else
      result["liked_posts"] = response_from_tumblr["liked_posts"]
      result["message"] = nil
    end

    result
  end
end
