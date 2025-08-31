class Tag < ApplicationRecord
  has_many :brewery_tags, dependent: :destroy
  has_many :breweries, through: :brewery_tags

  validates :name, presence: true, uniqueness: true
end
