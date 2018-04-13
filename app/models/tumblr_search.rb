class TumblrSearch
  def initialize(blog_to_search:, gateway: TumblrGateway.new)
    @gateway = gateway
    @blog = blog_to_search
  end

  def find_liked_posts_matching(post_text:, post_creator: nil)
    response = @gateway.all_liked_posts(@blog)

    return _failure(response) if response["status"]
    return _success(response["liked_posts"], post_text)
  end

  private

  def _success(liked_posts, post_text)
    match_regex = Regexp.new(post_text, Regexp::IGNORECASE)
    # an array of post hashes
    results = liked_posts.each_with_object([]) do |post, matching_posts|
      if post["summary"].match(match_regex) || post["tags"].any? { |tag| tag.match(match_regex) }
        matching_posts << post
      end
    end

    {:error_message => nil, :posts => results}
  end

  def _failure(response)
    {:error_message => response["msg"], :posts => []}
  end
end