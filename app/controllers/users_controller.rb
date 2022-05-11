class UsersController < ApplicationController

    def create
        @user = User.new(user_params)
        respond_to do |format|
            if @user.save
                flash[:notice] = "<strong>#{I18n.t('authentication.notices.confirm_account')}</strong> #{I18n.t('authentication.notices.confirm_account_instruction')}"
                format.html { redirect_to(request.referer + ".html" || movies_path(format: :html)) }
                NotificationMailer.user_signup_confirmation(@user).deliver
            else
                format.turbo_stream do 
                    render turbo_stream: turbo_stream.replace("new_user", partial: "shared/authentication/sign_up_form", locals: { user: @user })
                end
            end
        end
    end

    def confirm
        @user = User.find_signed(params[:token], purpose: "signup_confirmation")
        if @user.present?
            @user.update_attribute(:confirmed_at, Time.now)
            @user.skip_password_validation = true
            session[:user_id] = @user.id
            redirect_to movies_path, notice: "<strong>#{I18n.t('authentication.notices.confirmation_successful')}</strong> #{I18n.t('authentication.notices.confirmation_successful_msg')}"
        else
            redirect_to movies_path, error: "<strong>#{I18n.t('authentication.errors.confirmation_link_invalid')}</strong> #{I18n.t('authentication.errors.confirmation_link_invalid_reclaim')}"
        end
    end

    private

    def user_params
        params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end

end