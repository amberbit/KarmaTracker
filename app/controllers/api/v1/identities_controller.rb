module Api
  module V1
    class IdentitiesController < ApplicationController
      before_filter :restrict_access
      respond_to :json

      def create

      end

      def destroy

      end
    end
  end
end
