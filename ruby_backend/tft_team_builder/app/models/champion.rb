class Champion < ApplicationRecord
  scope :for_set, ->(set_identifier) { set_identifier.present? ? where(set_identifier:) : all }
  scope :ordered_for_picker, lambda {
    order(Arel.sql("COALESCE(cost, tier, 0) ASC"), :name)
  }

  validates :name, presence: true
  validates :api_id, presence: true, uniqueness: { scope: :set_identifier }, allow_nil: false
  validates :set_identifier, presence: true

  def trait_names
    traits.to_s.split(" / ").map(&:strip).reject(&:blank?)
  end

  def cost_value
    cost || tier
  end
end
