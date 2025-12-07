class ChampionsController < ApplicationController
  # GET /champions - Returns the list of champions for the picker page
  def index
    # Retrieve all Champion records from database and sort by tier
    @champions = Champion.for_set(params[:set]).ordered_for_picker
  end

  # GET /champions/:id - Returns a specific champion detail
  # Only used for detailed champion information
  def show
    @champion = Champion.find(params[:id])
  end
end
