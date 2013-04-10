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
          render json: {status: 401, message: 'Forbidden'}
        end
      end

      def create
        identity = IdentitiesFactory.new(params).create_identity
        if identity && identity.save
          render json: {status: 200, message: 'Identity created'}
        else
          render json: {status: 500, message: 'Internal server error'}
        end
      end

      def destroy
        identity = Identity.find(params[:id])
        if identity.user.api_key == @api_key
          identity.delete
          render json: {status: 200, message: 'Identity destroyed'}
        else
          render json: {status: 401, message: 'Forbidden'}
        end
      end
    end
  end
end
