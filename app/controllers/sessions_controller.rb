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

    def omniauth
      user_info = request.env['omniauth.auth']
      user = User.from_omniauth(user_info)
      user.skip_password_validation = true
      if user.valid?
        session[:user_id] = user.id
        redirect_to request.env['omniauth.origin']
      else
        notice_msg = "Anmeldung war nicht erfolgreich."
        if user.errors.added? :email, :taken, value: user.email
          notice_msg += " Es ist bereits ein Account mit dieser Email-Adresse registriert. Bitte verwende diese um dich anzumelden."
        end
      end
      redirect_to request.env['omniauth.origin'], notice: notice_msg if notice_msg
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