class ChampionsController < ApplicationController
  # ���������Ӧ "Ӣ���б�" ҳ�� (GET /champions)
  def index
    # �����ݿ��л�ȡ���� Champion ��¼���������� (tier) ����
    @champions = Champion.for_set(params[:set]).ordered_for_picker
  end

  # ���������Ӧ "Ӣ������" ҳ�� (GET /champions/:id)
  # ����֮����õ�
  def show
    @champion = Champion.find(params[:id])
  end
end
