class ApplicationController < ActionController::API

    include ActionController::Cookies
    before_action :authorize_user

    def current_user
        user = User.find_by(id: session[:current_user])
    end

    def authorize_user   
        return render json: { error: "Not authorized" }, status: 401 unless current_user
    end

end
