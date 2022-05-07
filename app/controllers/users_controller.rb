class UsersController < ApplicationController

    def create
        @user = User.new(user_params)
        respond_to do |format|
            if @user.save
                session[:user_id] = @user.id
                format.html { redirect_to movies_path(format: :html) }
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