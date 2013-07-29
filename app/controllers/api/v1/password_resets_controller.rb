module Api
  module V1

    class PasswordResetsController < ApplicationController
      respond_to :json

      def create
        @user = User.find_by_email(params[:email])
        @user.send_password_reset(request.host) if @user.present?
        render json: {message: 'Email with password reset instructions was sent'}, status: 200
      end


      def update
        @user = User.find_by_password_reset_token!(params[:token])
        if @user.password_reset_sent_at < 24.hours.ago
          @user.send_password_reset(request.host)
          render json: { error: 'Reset password token expired. New token has been sent'}, status: 410
        else
          @user.password = params[:password]
          @user.password_confirmation = params[:confirmation]
          if @user.save
            render json: { message: 'Password successfully changed'}, status: 200
          else
            render json: { error: 'Save unsuccessful' }, status: 400
          end
        end
      end

    end
  end
end
