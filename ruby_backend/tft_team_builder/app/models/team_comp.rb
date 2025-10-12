class TeamComp < ApplicationRecord
  validates :name, presence: true
  validates :champions, presence: true

  def champion_names
    champions.to_s.split(",").map { |name| name.strip }.reject(&:blank?)
  end

  def champion_records
    names = champion_names
    return [] if names.empty?

    @champion_records ||= Champion.where(name: names).in_order_of(:name, names)
  end

  def win_rate_value
    win_rate&.to_f
  end

  def play_rate_value
    play_rate&.to_f
  end
end
