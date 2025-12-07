# frozen_string_literal: true

# = TeamComp Model
#
# Represents a Teamfight Tactics team composition.
# Stores champion configurations, metadata, and user interactions.
#
# == Attributes
# * +name+ - Team composition name (required, max 50 chars)
# * +description+ - Detailed description (max 200 chars)
# * +notes+ - Additional notes (max 100 chars)
# * +champions+ - Comma-separated champion names (required)
# * +set_identifier+ - TFT set identifier (e.g., 'TFT15', default: TFT15)
# * +team_type+ - Type of team ('system' or 'user')
# * +size+ - Number of units in composition
# * +play_count+ - Number of times this composition was played
# * +win_count+ - Number of games won with this composition
# * +top4_count+ - Number of top 4 placements
# * +avg_placement+ - Average placement statistic
# * +composition_key+ - Unique identifier for composition
# * +top1_rate+ - First place win rate
# * +top2_rate+ - Top 2 placement rate
# * +top3_rate+ - Top 3 placement rate
# * +top4_rate+ - Top 4 placement rate
# * +win_rate+ - Overall win rate percentage
# * +play_rate+ - Play rate percentage
# * +user_id+ - Associated user (nullable for system teams)
# * +created_at+ - Record creation timestamp
# * +updated_at+ - Record update timestamp
#
# == Associations
# * +belongs_to :user+ - Owner of the team composition (optional)
# * +has_many :likes+ - User likes on this team
# * +has_many :favorites+ - User favorites of this team
# * +has_many :comments+ - Comments on this team
#
# == Validations
# * +name+ - Required, maximum 50 characters
# * +champions+ - Required (comma-separated champion list)
# * +set_identifier+ - Required (auto-set to default if blank)
# * +description+ - Optional, maximum 200 characters
# * +notes+ - Optional, maximum 100 characters
#
# == Scopes
# * +for_set(set_identifier)+ - Filter teams by TFT set
# * +system_teams+ - Get all system teams
# * +user_teams+ - Get all user-created teams
#
# == Class Constants
# * +DEFAULT_SET_IDENTIFIER+ - Default TFT set (from ENV or "TFT15")
#
# == Methods
# * +champion_names+ - Parse and return array of champion names
# * +champion_records+ - Fetch associated Champion records from database
# * +win_rate_value+ - Convert win_rate to float
# * +play_rate_value+ - Convert play_rate to float
# * +derived_metadata+ - Generate metadata hash with calculated values
#
# == Example
#   # Create a user team composition
#   team = TeamComp.create(
#     name: "Astral Casters",
#     champions: "Ahri, Lulu, Taliyah, Neeko",
#     set_identifier: "TFT15",
#     team_type: "user",
#     user: current_user
#   )
#
#   # Get champion objects
#   team.champion_records  # => [#<Champion>, #<Champion>, ...]
#
#   # Filter by set
#   TeamComp.for_set("TFT15")
#
class TeamComp < ApplicationRecord
  DEFAULT_SET_IDENTIFIER = ENV.fetch("DEFAULT_TFT_SET", "TFT15")

  belongs_to :user, optional: true
  has_many :likes, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :comments, dependent: :destroy

  scope :for_set, ->(set_identifier) { set_identifier.present? ? where(set_identifier:) : all }
  scope :system_teams, -> { where(team_type: "system") }
  scope :user_teams, -> { where(team_type: "user") }

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
