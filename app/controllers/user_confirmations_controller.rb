class UserConfirmationsController < ApplicationController

  def create
    user = User.find_by_email(user_params[:email].downcase)

    if user.present? && user.confirmed_at.nil?
      NotificationMailer.user_resend_confirmation_link(user).deliver
    end

    flash[:notice] = I18n.t('authentication.notices.resend_confirmation_msg')
    redirect_to(request.referer + ".html" || movies_path(format: :html))
  end

  def update
    user = User.find_signed(params[:token], purpose: "account_confirmation")
    
    if user.present? && user.confirmed_at.nil?
      user.update_attribute(:confirmed_at, Time.now)
      user.skip_password_validation = true
      session[:user_id] = user.id
      redirect_to movies_path, notice: "<strong>#{I18n.t('authentication.notices.confirmation_successful')}</strong> #{I18n.t('authentication.notices.confirmation_successful_msg')}"
    else
      redirect_to movies_path, error: "<strong>#{I18n.t('authentication.errors.confirmation_link_invalid')}</strong> #{I18n.t('authentication.errors.confirmation_link_invalid_reclaim')}"
    end
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
  
end