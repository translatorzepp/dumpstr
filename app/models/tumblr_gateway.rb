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

  def likes_count(blog_to_search)
    response = @client.blog_likes(blog_to_search, {:limit => 1})
    # error handling around status
    response["liked_count"]
  end


  def search_likes(blog_to_search:, post_text:, post_creator: nil)
    match_regex = Regexp.new(post_text, Regexp::IGNORECASE)

    limit = likes_count(blog_to_search)
    like_response = @client.blog_likes(blog_to_search, {:limit => limit})
    status = like_response["status"]
    Rails.logger.debug("tumblr client search response status: #{status}")
    # error handling around status

    liked_posts = like_response["liked_posts"] #array of hashes

    liked_posts.each_with_object({}) do |post, matching_posts|
      if post["summary"].match(match_regex) || post["tags"].any? { |tag| tag.match(match_regex) }
        matching_posts[post["post_url"]] = post["summary"]
      end
    end
  end
end

