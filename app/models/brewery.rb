class Brewery < ApplicationRecord
  belongs_to :country
  has_many :brewery_tags, dependent: :destroy
  has_many :tags, through: :brewery_tags

  validates :name, presence: true
  validates :brewery_type, presence: true
  validates :city, presence: true

  scope :search, ->(q) {
    if q.present?
      where("lower(breweries.name) like :q or lower(breweries.city) like :q", q: "%#{q.downcase}%")
    else
      all
    end
  }

  scope :in_country, ->(country_id) {
    if country_id.present?
      where(country_id: country_id)
    else
      all
    end
  }
end
