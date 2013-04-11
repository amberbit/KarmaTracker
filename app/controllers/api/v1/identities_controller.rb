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
          render json: {message: 'Resource not found'}, status: 404
        end
      end

      def pivotal_tracker
        @identity = IdentitiesFactory.new(PivotalTrackerIdentity, params[:identity]).create_identity
        if @identity.save
          render 'show'
        else
          render 'show', status: 422
        end
      end

      def destroy
        @identity = Identity.find(params[:id])
        if @identity.user.api_key == @api_key
          @identity.delete
          render 'api/v1/identities/show'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

    end
  end
end
