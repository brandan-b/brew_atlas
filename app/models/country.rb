class Country < ApplicationRecord
  has_many :breweries, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true, length: { is: 2 }
end
