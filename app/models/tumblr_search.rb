class TumblrSearch
  def initialize(blog_to_search:, gateway: TumblrGateway.new)
    @gateway = gateway
    @blog = blog_to_search
  end

  def find_liked_posts_matching(post_text:, post_creator: nil)
    response = @gateway.all_liked_posts(@blog)

    return _failure(response) if response["message"]
    return _success(response, post_text)
  end

  private

  def _success(response, post_text)
    match_regex = Regexp.new(post_text, Regexp::IGNORECASE)
    # an array of post hashes
    matching_posts = _posts_with_match(response["liked_posts"], match_regex)

    {:error_message => nil, :posts => matching_posts}
  end

  def _failure(response)
    {:error_message => response["message"], :posts => []}
  end

  def _posts_with_match(posts, regex)
    posts.each_with_object([]) do |post, matching_posts|
      post_body = post["body"] || ""

      if post["summary"].match(regex) ||
          post["tags"].any? { |tag| tag.match(regex) } ||
          post_body.match(regex)

        matching_posts << post
      end
    end
  end
end
