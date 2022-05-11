class SessionsController < ApplicationController

    def create
      user = User.find_by(email: login_params[:email].downcase)
      respond_to do |format|
        if user && user.authenticate(login_params[:password]) && user.confirmed?
          session[:user_id] = user.id
          format.html { redirect_to(request.referer + ".html" || movies_path(format: :html)) }
        else
          format.turbo_stream do 
            render turbo_stream: turbo_stream.replace("login", partial: "shared/authentication/sign_in_form", locals: { error: true })
          end
        end
      end
    end

    def omniauth
      user_info = request.env['omniauth.auth']
      I18n.locale = request.env['omniauth.params']['locale']
      user = User.from_omniauth(user_info)
      user.skip_password_validation = true
      if user.valid?
        session[:user_id] = user.id
        redirect_to request.env['omniauth.origin']
      else
        error_msg = "<strong>#{I18n.t("authentication.omniauth.errors.sign_in_failed")}</strong> "
        if user.errors.added? :email, :taken, value: user.email
          error_msg += I18n.t("authentication.omniauth.errors.email_taken", provider: user_info.provider.capitalize, email: user.email)
        end
        flash[:error] = error_msg
        redirect_to request.env['omniauth.origin']
      end
    end
  
    def destroy
      session[:user_id] = nil
      redirect_to request.referer || root_path, notice: "<strong>#{I18n.t("authentication.notices.log_out_successful")}</strong> #{I18n.t("authentication.notices.see_you_soon")}"
    end
  
    private 
  
    def login_params
      params.require(:session).permit(:email, :password)
    end
    
  
  end