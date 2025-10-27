class TeamCompsController < ApplicationController
  before_action :set_team_comp, only: %i[ show edit update destroy ]

  # GET /team_comps or /team_comps.json
  def index
    @team_comps = TeamComp.for_set(params[:set])
    @champions_map = Champion.for_set(params[:set]).ordered_for_picker.index_by(&:name)
  end

  # GET /team_comps/1 or /team_comps/1.json
  def show
    # @team_comp 已经由 before_action :set_team_comp 设置好了

    # 1. 获取阵容中的英雄名字，并分割成数组
    champion_names = @team_comp.champions.present? ? @team_comp.champions.split(',') : []

    # 2. 根据名字数组，从数据库中一次性找出所有对应的英雄对象
    # 为了保持阵容顺序，我们需要对结果进行排序
    @lineup_champions = Champion
                          .for_set(@team_comp.set_identifier)
                          .where(name: champion_names)
                          .in_order_of(:name, champion_names)

    # 3. (进阶) 分析并统计所有激活的羁绊
    # .flat_map - 将所有英雄的羁绊字符串打散成一个大数组
    # .tally - 统计数组中每个元素（羁绊名）出现的次数
    @active_traits = @lineup_champions.flat_map { |c| c.traits.split(' / ') }.tally
  end

  # GET /team_comps/new
  def new
    @team_comp = TeamComp.new
    @champions = Champion.for_set(params[:set]).ordered_for_picker
  end

  # GET /team_comps/1/edit
  def edit
    @champions = Champion.for_set(@team_comp.set_identifier).ordered_for_picker
  end

  # POST /team_comps or /team_comps.json
  def create
    @team_comp = TeamComp.new(team_comp_params)

    respond_to do |format|
      if @team_comp.save
        format.html { redirect_to team_comp_url(@team_comp), notice: "Team comp was successfully created." }
        format.json { render :show, status: :created, location: @team_comp }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @team_comp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /team_comps/1 or /team_comps/1.json
  def update
    respond_to do |format|
      if @team_comp.update(team_comp_params)
        format.html { redirect_to team_comp_url(@team_comp), notice: "Team comp was successfully updated." }
        format.json { render :show, status: :ok, location: @team_comp }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @team_comp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /team_comps/1 or /team_comps/1.json
  def destroy
    @team_comp.destroy!

    respond_to do |format|
      format.html { redirect_to team_comps_url, notice: "Team comp was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team_comp
      @team_comp = TeamComp.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def team_comp_params
      params.require(:team_comp).permit(:name, :description, :champions, :set_identifier)
    end
end
