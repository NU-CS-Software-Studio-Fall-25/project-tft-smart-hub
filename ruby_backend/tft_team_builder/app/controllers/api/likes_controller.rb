module Api
  class LikesController < BaseController
    before_action :authenticate_user!
    before_action :set_team_comp

    def create
      # Check if already liked
      existing_like = current_user.likes.find_by(team_comp: @team_comp)

      if existing_like
        # Already liked, return success status with fresh count
        render json: {
          liked: true,
          likesCount: @team_comp.reload.likes_count
        }, status: :ok
        return
      end

      like = current_user.likes.build(team_comp: @team_comp)

      if like.save
        render json: {
          liked: true,
          likesCount: @team_comp.reload.likes_count
        }, status: :created
      else
        render json: { error: like.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    def destroy
      like = current_user.likes.find_by(team_comp: @team_comp)

      if like
        like.destroy
        render json: {
          liked: false,
          likesCount: @team_comp.reload.likes_count
        }
      else
        render json: { error: "未找到点赞记录" }, status: :not_found
      end
    end

    def check
      liked = current_user.likes.exists?(team_comp: @team_comp)

      render json: {
        liked: liked,
        likesCount: @team_comp.likes_count
      }
    end

    private

    def set_team_comp
      @team_comp = TeamComp.find(params[:id])
    end
  end
end
