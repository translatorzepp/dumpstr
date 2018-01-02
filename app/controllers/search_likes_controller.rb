class SearchLikesController < ApplicationController
  before_action :santize_search_terms

  def index
    default_params = {blog_name: "ritterssport", search_text: "john mulaney", source_blog: "princeofsparkles"}
    @search_params = default_params
  end

  def results
    search_params = params.extract!(:blog_name, :search_text, :source_blog)
    tumbler = TumblrGateway.new
    @results = tumbler.search_likes(blog_to_search: search_params[:blog_name], post_text: search_params[:search_text], post_creator: search_params[:source_blog])
    display_results
  end

  def display_results
  end

  def santize_search_terms
    params.permit([:blog_name, :search_text, :source_blog])
  end
end
