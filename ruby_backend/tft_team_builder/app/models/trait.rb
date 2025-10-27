class Trait < ApplicationRecord
  scope :for_set, ->(set_identifier) { set_identifier.present? ? where(set_identifier:) : all }

  validates :api_id, presence: true
  validates :name, presence: true
  validates :set_identifier, presence: true, allow_blank: false
end
