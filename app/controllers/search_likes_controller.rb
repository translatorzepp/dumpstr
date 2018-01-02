class SearchLikesController < ApplicationController
  before_action :santize_search_terms

  def index
    default_params = {blog_name: "ritterssport", search_text: "clothes", source_blog: "princeofsparkles"}
    @search_params = default_params
  end

  def results
    display_results
  end

  def display_results
    @results = params.extract!(:blog_name, :search_text, :source_blog)
  end

  def santize_search_terms
    params.permit([:blog_name, :search_text, :source_blog])
  end
end
