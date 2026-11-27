module Api
  module V1
    class CountriesController < ApplicationController
      def index
        render json: {
          data: Country.order(:name).as_json(only: [:id, :name, :country_code])
        }
      end
    end
  end
end
