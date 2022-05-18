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

    private

    def user_params
        params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end

end