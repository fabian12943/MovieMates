class PasswordResetsController < ApplicationController

  def create
    user = User.find_by_email(user_params[:email].downcase)

    if user.present?
      NotificationMailer.user_password_reset(user).deliver
    end
    
    flash[:notice] = I18n.t('authentication.notices.send_password_reset_msg')
    redirect_to(request.referer + ".html" || movies_path(format: :html))
  end

  def edit
    @user = User.find_signed(params[:token], purpose: "password_reset")
    redirect_to movies_path(format: :html), error: I18n.t('authentication.errors.password_reset_link_invalid') if @user.nil?
  end

  def update
    @user = User.find_signed(params[:token], purpose: "password_reset")
    if @user.update(password_params)
      redirect_to movies_path(format: :html), notice: I18n.t('authentication.notices.password_reset_successful')
    else
      render :edit
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def user_params
    params.require(:user).permit(:email)
  end
  
end
