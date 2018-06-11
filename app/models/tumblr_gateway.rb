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
    result["liked_posts"] = []

    # if request returns 200/201, it'll only return the response from the body
    #   otherwise, it'll return the 'meta' (incl status, msg) + body if it exists
    # will accept a max limit of 50. TODO: look at using offsets to get everything

    limit = 50
    likes_count = likes_count(blog_to_search)
    Rails.logger.debug("Number of liked posts: #{likes_count}")
    likes_count = likes_count > 1000 ? 1000 : likes_count
    offset = 0

    while offset <= 1000
      response_from_tumblr = @client.blog_likes(blog_to_search, {:limit => 50, :offset => offset})

      if response_from_tumblr["status"]
        result["liked_posts"] = []
        result["message"] = response_from_tumblr["msg"]

        # THIS IS TERRIBLE AND WILL INFINITE LOOP IF THERE'S AN ERROR
        Rails.logger.error("Tumblr client error. Status Code #{response_from_tumblr['status']}. Message: #{response_from_tumblr['msg']}")
      else
        result["liked_posts"] += response_from_tumblr["liked_posts"]
        result["message"] = nil
        Rails.logger.debug("Adding #{result['liked_posts'].size} liked posts. Offset: #{offset}")
        offset += 50
      end
    end
    result
  end

  def likes_count(blog_to_search)
    response = @client.blog_likes(blog_to_search, {:limit => 1})
    # error handling around status
    response["liked_count"]
  end
end
