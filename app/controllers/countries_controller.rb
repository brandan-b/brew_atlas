class CountriesController < ApplicationController
  def index
    @countries = Country.left_joins(:breweries)
                        .select("countries.*, count(breweries.id) as breweries_count")
                        .group("countries.id").order(:name)
                        .page(params[:page]).per(25)
  end

  def show
    @country = Country.find(params[:id])
    @breweries = @country.breweries.order(:name).page(params[:page]).per(25)
  end
end
