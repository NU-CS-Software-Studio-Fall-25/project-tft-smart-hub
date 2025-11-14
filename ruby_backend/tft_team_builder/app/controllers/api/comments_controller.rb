module Api
  class CommentsController < BaseController
    before_action :authenticate_user!, except: [:index]
    before_action :set_team_comp

    def index
      comments = @team_comp.comments.includes(:user)

      serialized_comments = comments.map do |comment|
        {
          id: comment.id,
          content: comment.content,
          createdAt: comment.created_at,
          user: {
            id: comment.user.id,
            email: comment.user.email,
            displayName: comment.user.display_name || comment.user.email.split('@').first
          },
          canDelete: current_user && (current_user.id == comment.user_id || current_user.admin?)
        }
      end

      render json: { 
        comments: serialized_comments,
        meta: {
          total: serialized_comments.length
        }
      }
    end

    def create
      comment = current_user.comments.build(
        team_comp: @team_comp,
        content: params[:content]
      )

      if comment.save
        render json: {
          id: comment.id,
          content: comment.content,
          createdAt: comment.created_at,
          user: {
            id: current_user.id,
            email: current_user.email,
            displayName: current_user.display_name || current_user.email.split('@').first
          },
          canDelete: true
        }, status: :created
      else
        render json: { error: comment.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end

    def destroy
      comment = Comment.find(params[:id])
      
      unless current_user.id == comment.user_id || current_user.admin?
        render json: { error: '无权删除此评论' }, status: :forbidden
        return
      end

      comment.destroy
      render json: { message: '评论已删除' }
    end

    private

    def set_team_comp
      @team_comp = TeamComp.find(params[:team_comp_id])
    end
  end
end
