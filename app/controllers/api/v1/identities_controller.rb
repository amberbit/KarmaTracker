module Api
  module V1
    class IdentitiesController < ApplicationController
      before_filter :restrict_access
      respond_to :json

      def index
        @identities = if params[:service]
          @api_key.user.identities.by_service(params[:service])
        else
          @api_key.user.identities
        end
        render 'index'
      end

      def show
        @identity = Identity.find(params[:id])
        if @identity.user.api_key == @api_key
          render 'show'
        else
          head :forbidden
        end
      end

      def create
        identity = IdentitiesFactory.new(params).create_identity
        if identity && identity.save
          head :ok
        else
          head :internal_server_error
        end
      end

      def destroy
        identity = Identity.find(params[:id])
        if identity.user.api_key == @api_key
          identity.delete
          head :ok
        else
          head :forbidden
        end
      end
    end
  end
end
