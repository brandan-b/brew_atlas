class BreweriesController < ApplicationController
  def index
    @countries = Country.order(:name)
    @q = params[:q].to_s
    @country_id = params[:country_id].to_s
    @breweries = Brewery.includes(:country)
                        .search(@q)
                        .in_country(@country_id)
                        .order(:name)
                        .page(params[:page]).per(25)
  end

  def show
    @brewery = Brewery.find(params[:id])
  end
end
