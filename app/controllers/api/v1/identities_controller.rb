module Api
  module V1
    class IdentitiesController < ApplicationController
      before_filter :restrict_access
      respond_to :json

      def index
        respond_with @api_key.user.identities
      end

      def show

      end

      def create

      end

      def destroy
        identity = Identity.find(params[:id])
        if identity.user.api_key == @api_key
          identity.delete
          respond_with 'Identity destroyed', status: 200
        else
          respond_with 'Access denied', status: 403
        end
      end
    end
  end
end
