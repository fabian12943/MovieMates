class People::CommentsController < ApplicationController
  include Commentable

  before_action :set_commentable

  private

  def set_commentable
    @commentable = People::Person.find_by(tmdb_id: params[:id], language: locale)
  end
end