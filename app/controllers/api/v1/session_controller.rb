module Api
  module V1
    class SessionController < ApplicationController
      respond_to :json

      ##
      # Authenticates user and returns user object with API Token.
      #
      # POST /api/v1/session
      #
      # params:
      #   session[email] - user email
      #   session[password] - user password
      #
      # = Examples
      #
      #   resp = conn.post("/api/v1/session",
      #                    "session[email]" => 'a@b.com',
      #                    "session[password]" => "asdf1234")
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"user":{"id":1,"email":"a@b.com","token":"644cef349e7b80d3e7151c980dccf2ec"}}
      #
      #   resp = conn.post("/api/v1/session",
      #                    "session[email]" => 'a@b.com',
      #                    "session[password]" => "invalid")
      #   resp.status
      #   => 401
      #
      #   resp.body
      #   => {"message": "Invalid email or password"}
      #
      def create
        if @user = User.authenticate(params[:session])
          if @user.confirmation_token.nil?
            @api_key = @user.api_key
            render 'api/v1/users/_show'
          else
            UserMailer.confirmation_email(@user, request.host).deliver
            render json: {message: 'User email address is not confirmed, please check your inbox or spam folder.'}, status: 401
          end
        else
          render json: {message: 'Invalid email or password'}, status: 401
        end
      end


      ##
      # Callback method for OmniAuth (Google, Github etc) login HTTP (not json!) callbacks. Extract user data, creates/updates user with 
      # token login and expire time. Get or create user. Redirects to '#/oauth' page
      #
      # GET /auth/:provider/callback
      #
      # params:
      # Request object should have OmniAuth hash https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema
      # which will contain information about the just authenticated user including a unique id, the strategy they just used for authentication, and personal details such as name and email address as available. For an in-depth description of what the authentication hash might contain, see the Auth Hash Schema wiki page.
      # https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema
      def oauth
        data = request.env["omniauth.auth"]
        if data.nil?
          render json: {message: 'OmniAuth authentication failed'}, status: 401
        else
          user = User.find_by_email data.info.email
          unless user.present?
            password = SecureRandom.hex(6)
            user = User.new(email: data.info.email, password: password)
            UserMailer.account_created(user, request.host, params[:provider], password).deliver
          end
          user.oauth_token = data.credentials.token
          user.oauth_token_expires_at = data.credentials.expires_at.nil? ? nil : Time.at(data.credentials.expires_at).utc
          user.confirmation_token = nil
          user.save
          redirect_to "/#/oauth?email=#{user.email}&oauth_token=#{user.oauth_token}"
        end
      end

      ##
      # Verifies OmniAuth token belongs to user and is didn't expire
      #
      # POST /api/v1/session/oauth_verify
      #
      # params:
      #   email - user email
      #   token - most recent OmniAuth token
      #
      # = Examples
      #
      #   resp = conn.post("/api/v1/session",
      #                    "email" => 'a@b.com',
      #                    "token" => "asdf1234")
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"user":{"id":1,"email":"a@b.com","token":"644cef349e7b80d3e7151c980dccf2ec"}}
      #
      #   resp = conn.post("/api/v1/session",
      #                    "token" => "asdf1234")
      #   resp.status
      #   => 404
      #
      #   resp.body
      #   => {"message": "Email and OmniAuth token required"}
      #
      def oauth_verify
        if params[:email].present? && params[:token].present?
          @user = User.find_by_email params[:email]
          if @user.present? && @user.oauth_token.present? && @user.oauth_token == params[:token]
            if @user.oauth_token_expires_at.nil? || @user.oauth_token_expires_at > Time.now
              @user.update_column :oauth_token, nil
              @api_key = @user.api_key
              render 'api/v1/users/_show'
            else
              render json: {message: 'OmniAuth token expired'}, status: 400
            end
          else
            render json: {message: 'Invalid OmniAuth token or user'}, status: 401
          end
        else
          render json: {message: 'Email and OmniAuth token required'}, status: 404
        end
      end

      ##
      # OmniAuth login failure handler
      #
      # GET /api/v1/session/failure
      #
      # params:
      #   strategy - name of OmniAuth strategy that failed
      #   message - fail reason
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/session/failure",
      #                    "message" => "invalid_credentials")
      #                    "strategy" => 'google',
      #   resp.status
      #   => 302
      #
      def failure
        redirect_to root_path, error: I18n.t('errors.omniauth_fail',
                                        provider: params[:strategy].capitalize,
                                        reason: params[:message].gsub('_', ' '))
      end
    end
  end
end
