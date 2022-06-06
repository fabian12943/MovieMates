class Movies::CommentsController < ApplicationController
    include Commentable

    before_action :set_commentable

    private

    def set_commentable
        @commentable = Movies::Movie.find_by(tmdb_id: params[:id], language: locale)
    end
end