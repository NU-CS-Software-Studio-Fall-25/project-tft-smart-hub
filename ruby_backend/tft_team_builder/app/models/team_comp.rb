class TeamComp < ApplicationRecord
  DEFAULT_SET_IDENTIFIER = ENV.fetch("DEFAULT_TFT_SET", "TFT15")

  belongs_to :user, optional: true
  has_many :likes, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :comments, dependent: :destroy

  scope :for_set, ->(set_identifier) { set_identifier.present? ? where(set_identifier:) : all }
  scope :system_teams, -> { where(team_type: 'system') }
  scope :user_teams, -> { where(team_type: 'user') }

  before_validation :apply_default_set_identifier

  validates :name, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 200 }, allow_blank: true
  validates :notes, length: { maximum: 100 }, allow_blank: true
  validates :champions, presence: true
  validates :set_identifier, presence: true

  def champion_names
    champions.to_s.split(",").map { |name| name.strip }.reject(&:blank?)
  end

  def champion_records
    # Use cached records if available (set by controller preloading)
    return @champion_records_cache if defined?(@champion_records_cache)

    names = champion_names
    return [] if names.empty?

    @champion_records ||= Champion
                          .for_set(set_identifier)
                          .where(name: names)
                          .in_order_of(:name, names)
  end

  def win_rate_value
    win_rate&.to_f
  end

  def play_rate_value
    play_rate&.to_f
  end

  def derived_metadata
    {
      set: set_identifier,
      size: size || champion_names.length,
      playCount: play_count,
      winCount: win_count,
      top4Count: top4_count,
      avgPlacement: avg_placement,
      compositionKey: composition_key,
      top1Rate: top1_rate,
      top2Rate: top2_rate,
      top3Rate: top3_rate,
      top4Rate: top4_rate
    }.compact
  end

  private

  def apply_default_set_identifier
    self.set_identifier = (set_identifier.presence || DEFAULT_SET_IDENTIFIER)
  end
end
