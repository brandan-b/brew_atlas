class TagsController < ApplicationController
  def index
    @tags = Tag.order(:name).page(params[:page]).per(25)
  end

  def show
    @tag = Tag.find(params[:id])
    @breweries = @tag.breweries.order(:name).page(params[:page]).per(25)
  end
end
