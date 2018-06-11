class SearchLikesController < ApplicationController
  before_action :santize_search_terms

  def index
    default_params = {blog_name: "ritterssport", search_text: "john mulaney"}
    @search_params = default_params
  end

  def results
    @results = []
    search_params = params.extract!(:blog_name, :search_text, :source_blog)
    tumbler = TumblrSearch.new(blog_to_search: search_params[:blog_name])
    results = tumbler.find_liked_posts_matching(post_text: search_params[:search_text], post_creator: search_params[:source_blog])

    flash results[:error_message] if results[:error_message]
    @result_count = results[:posts].size
    display_results(results[:posts])
  end

  def display_results(posts)
    display_friendly_links = posts.each_with_object([]) do |post, display_friendly_links|
      display_friendly_links << {
        :info_text => "liked from #{post['blog_name']}:",
        :link_text => post["summary"],
        :url => post["post_url"]
      }
    end

    @results = display_friendly_links
  end

  def santize_search_terms
    params.permit([:blog_name, :search_text, :source_blog])
  end
end
