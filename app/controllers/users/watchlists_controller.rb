class Users::WatchlistsController < ApplicationController 
  before_action :set_user
  before_action :require_login, only: [:create]

  def index
    if (current_user && current_user == @user.id)
      @watchlists = Watchlist.where(user_id: @user.id)
    else
      @watchlists = Watchlist.where(user_id: @user.id, private: false)
    end
  end

  def show
    @watchlist = Watchlist.find(params[:id])
    Movies::Movie.create_or_update_movies(@watchlist.watchlisted_movies.pluck(:movie_tmdb_id), I18n.locale, false)
  end

  def create
    @watchlist = Watchlist.new(watchlist_params)
    @watchlist.user_id = current_user.id
   
    respond_to do |format|
      if @watchlist.save
        format.html { redirect_to(request.referer + ".html" || movies_path(format: :html)) }
      else
        format.turbo_stream do 
          render turbo_stream: turbo_stream.replace("new_watchlist", partial: "users/watchlists/create_form", locals: { watchlist: @watchlist })
        end
      end
    end
  end

  private 

  def watchlist_params
    params.require(:watchlist).permit(:name, :description)
  end 

  def set_user
    user = User.find_by(username: params[:username])
    if user.nil?
      not_found
    else
      @user = user
    end
  end
end