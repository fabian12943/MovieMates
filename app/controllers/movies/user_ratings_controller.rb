class Movies::UserRatingsController < ApplicationController
  before_action :set_movie
  before_action :require_login

  def create
    @user_rating = Movies::UserRating.new(movie_tmdb_id: user_rating_params[:id], rating: user_rating_params[:rating].to_f * 2, user_id: current_user.id)
    respond_to do |format|
      if @user_rating.save
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("user-rating", partial: "movies/details_partials/user_rating")  
        }
      else
        # Rating was not created
        # TODO: Render Toast Message with error in future version
      end
    end
  end

  def destroy
    user_rating = Movies::UserRating.find(params[:user_rating_id])
    respond_to do |format|
      if user_rating.destroy
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("user-rating", partial: "movies/details_partials/user_rating")  
        }
      else
        # Rating was not deleted
        # TODO: Render Toast Message with error in future version
      end
    end
  end

  private 

  def user_rating_params
    params.permit(:id, :rating, :authenticity_token, :locale, :user_rating_id)
  end

  def set_movie
    tmdb_id = user_rating_params[:id]
    if tmdb_id.to_i == 0
        not_found
    end
    begin
        Movies::Movie.create_or_update_movie(tmdb_id, I18n.locale)
        @movie = Movies::Movie.find_by(tmdb_id: tmdb_id, language: I18n.locale)
    rescue TmdbErrors::ResourceNotFoundError => e
        not_found
    end
  end
end
