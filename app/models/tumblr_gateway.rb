class TumblrGateway
  class TumblrError < StandardError; end
  LIMIT = 50
  HIGHEST_OFFSET = 1000

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
    results = {
      "liked_posts" => [],
      "message" => nil
    }
    offset = 0

    # if request returns 200/201, it'll only return the response from the body
    #   otherwise, it'll return the 'meta' (incl status, msg) + body if it exists
    # currently only searches a max of 1000 likes
    begin
      likes_count = _likes_count(blog_to_search)

      likes_count = likes_count > HIGHEST_OFFSET ? HIGHEST_OFFSET : likes_count
      while offset <= likes_count
        response_from_tumblr = _make_api_call(blog_to_search, {:limit => LIMIT, :offset => offset})

        results["liked_posts"] += response_from_tumblr["liked_posts"]
        Rails.logger.debug("Adding #{results['liked_posts'].size} liked posts. Offset: #{offset}")
        offset += LIMIT
      end

    rescue TumblrError => e
      results["message"] = _errors(e.message)
    end

    results
  end

  private

  def _likes_count(blog_to_search)
    response_from_tumblr = _make_api_call(blog_to_search, {:limit => 1})
    count = response_from_tumblr["liked_count"]
    Rails.logger.debug("Number of liked posts: #{count}")
    count
  end

  def _make_api_call(blog_to_search, options)
    response_from_tumblr = @client.blog_likes(blog_to_search, options)
    if response_from_tumblr["status"]
      Rails.logger.error("Tumblr client error. Status Code #{response_from_tumblr['status']}. Message: #{response_from_tumblr['msg']}")
      raise TumblrError.new(response_from_tumblr["status"])
    end
    response_from_tumblr
  end

  def _errors(status_code)
    {
      "404" => "This blog doesn't exist.",
      "403" => "This blog has their likes set to private.",
      "429" => "Tumblr says this page is trying to searching too much. Try again later (maybe in an hour?)",
    }[status_code]
  end
end
