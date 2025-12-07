module Api
  class FavoritesController < BaseController
    before_action :authenticate_user!
    before_action :set_team_comp, except: [ :index ]

    def index
      favorites = current_user.favorites.includes(team_comp: :user)
      team_comps = favorites.map(&:team_comp)

      serialized_teams = team_comps.map do |team|
        TeamCompSerializer.new(team, request: request, current_user: current_user).as_json
      end

      render json: {
        favorites: serialized_teams,
        meta: {
          total: serialized_teams.length
        }
      }
    end

    def create
      # Check if already favorited
      existing_favorite = current_user.favorites.find_by(team_comp: @team_comp)

      if existing_favorite
        # Already favorited, return success status with fresh count
        render json: {
          favorited: true,
          favoritesCount: @team_comp.reload.favorites_count
        }, status: :ok
        return
      end

      favorite = current_user.favorites.build(team_comp: @team_comp)

      if favorite.save
        render json: {
          favorited: true,
          favoritesCount: @team_comp.reload.favorites_count
        }, status: :created
      else
        render json: { error: favorite.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    def destroy
      favorite = current_user.favorites.find_by(team_comp: @team_comp)

      if favorite
        favorite.destroy
        render json: {
          favorited: false,
          favoritesCount: @team_comp.reload.favorites_count
        }
      else
        render json: { error: "未找到收藏记录" }, status: :not_found
      end
    end

    def check
      favorited = current_user.favorites.exists?(team_comp: @team_comp)

      render json: {
        favorited: favorited,
        favoritesCount: @team_comp.favorites_count
      }
    end

    private

    def set_team_comp
      @team_comp = TeamComp.find(params[:id])
    end
  end
end
