I set up a fresh Rails::API project by using

    rails new backend --api --minimal --database=postgresql

using PostGreSQL as default database. 

For Heroku, CD into backend and run

    bundle lock --add-platform x86_64-linux --add-platform ruby
    
RACK/CORS may become a problem. Under config/cors.rb, the following line is commented out:

    # Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins "example.com"
#
#     resource "*",
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end

For now, leave that commented out.

In my project for phase 4, I added the line above exactly to config/application.rb. I'd like to see if, with all RACK/CORS related lines commented out, I receive any errors. If I do, I'd like to first uncomment the line from config/cors.rb. Finally , if that doesn't work, add it to config/application.rb, just like I had it in my original phase-4 project (before merging with Mahdy):

    module Back
        class Application < Rails::Application
            # Initialize configuration defaults for originally generated Rails version.
            config.load_defaults 7.0

            # Configuration for the application, engines, and railties goes here.
            #
            # These settings can be overridden in specific environments using the files
            # in config/environments, which are processed later.
            #
            # config.time_zone = "Central Time (US & Canada)"
            # config.eager_load_paths << Rails.root.join("extras")

            # Only loads a smaller set of middleware suitable for API only apps.
            # Middleware like session, flash, cookies can be added back manually.
            # Skip views, helpers and assets when generating a new resource.

            Rails.application.config.middleware.insert_before ActionDispatch::Static, Rack::Cors do
            allow do
                origins '*'
                
                resource '*',
                headers: :any,
                methods: %i[get post put patch delete options head]
                end
            end
            
            config.api_only = true

            config.middleware.use ActionDispatch::Cookies
            config.middleware.use ActionDispatch::Session::CookieStore
            # if any problems, comment the following out
            # config.action_dispatch.cookies_same_site_protection = :strict

        end
    end
    
Rails::API does not by default set up the project to use sessions. Sessions can be important if one of your API clients is a browser. To set up sessions, add the following  to config/applications.rb:

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

Add the following gems:

    gem 'bcrypt', '~> 3.1', '>= 3.1.16'

    gem 'rack-cors', :require => 'rack/cors'

    gem 'faker', :git => 'https://github.com/faker-ruby/faker.git', :branch =>      'master'

    gem 'byebug', '~> 11.1', '>= 11.1.3'
    
# app/controllers/application_controller.rb

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

# app/controllers/users_controller.rb

    class UsersController < ApplicationController

    skip_before_action :authorize_user, only: [:create]

    def index
        users = User.all
        render json: users
    end

    def show
        if current_user
            render json: current_user, status: 200
        else
            render json: {error: "No current user set"}, status: 401
        end
    end

    def create
        user = User.create(user_params)
        if user.valid?
            return render json: user, status: 201
        else
            return render json: { error: user.errors.full_messages }, status: 404
        end
    end

    private

    def user_params
        params.permit(:name, :username, :password, :password_confirmation)
    end

end

# app/controller/sessions_controller.rb

    class UsersController < ApplicationController

    skip_before_action :authorize_user, only: [:create]

    def index
        users = User.all
        render json: users
    end

    def show
        if current_user
            render json: current_user, status: 200
        else
            render json: {error: "No current user set"}, status: 401
        end
    end

    def create
        user = User.create(user_params)
        if user.valid?
            return render json: user, status: 201
        else
            return render json: { error: user.errors.full_messages }, status: 404
        end
    end

    private

    def user_params
        params.permit(:name, :username, :password, :password_confirmation)
    end

end