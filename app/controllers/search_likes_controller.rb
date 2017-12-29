class SearchLikesController < ApplicationController
  before_action :santize_search_terms

  def index
    puts "*** the index method has been called ***"
    @search_params = params.extract!(:blog_name, :text_term, :text_term_case_insensitive, :source_blog)
    render :index
  end

  def santize_search_terms
    params.permit([:blog_name, :text_search_term, :text_search_case_sensitive, :source_blog_search_term])
  end
end
