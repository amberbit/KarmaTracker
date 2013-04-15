module Api
  module V1

    class AdminController < ApplicationController
      before_filter :restrict_admin_access

      private

      def restrict_admin_access
        unless restrict_access_by_params(true) || restrict_access_by_header(true)
          render json: {message: 'Invalid API Token'}, status: 401
          return
        end

        @current_admin = @api_key.user if @api_key
      end

    end
  end
end
