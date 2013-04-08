module Api
  module V1
    class UsersController < ApplicationController
      before_filter :restrict_access
      respond_to :json

      def index
        respond_with User.all
      end

    end
  end
end
