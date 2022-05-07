class SessionsController < ApplicationController

    def create
      user = User.find_by(email: login_params[:email].downcase)
      respond_to do |format|
        if user && user.authenticate(login_params[:password])
          session[:user_id] = user.id
          format.html { redirect_to(request.referer + ".html" || movies_path(format: :html)) }
        else
          format.turbo_stream do 
            render turbo_stream: turbo_stream.replace("login", partial: "shared/authentication/sign_in_form", locals: { error: true })
          end
        end
      end
    end
  
    def destroy
      session[:user_id] = nil
      redirect_to request.referer || root_path
    end
  
    private 
  
    def login_params
      params.require(:session).permit(:email, :password)
    end
    
  
  end