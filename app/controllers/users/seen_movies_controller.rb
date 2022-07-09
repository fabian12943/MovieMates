class Users::SeenMoviesController < ApplicationController
  before_action :set_user

  def index
    @pagy, @seen_movies = pagy(SeenMovie.where(user_id: @user.id).order(created_at: :desc, id: :asc), items: 20)
    Movies::Movie.create_or_update_movies(@seen_movies.pluck(:movie_tmdb_id), I18n.locale, false)

    respond_to do |format|
      format.html
      format.json {
        render json: { entries: render_to_string(partial: "seen_movies", formats: [:html]), pagination: view_context.pagy_nav(@pagy)}
      }
    end
  end

  private 

  def set_user
    user = User.find_by(username: params[:username])
    if user.nil?
      not_found
    else
      @user = user
    end
  end

end
