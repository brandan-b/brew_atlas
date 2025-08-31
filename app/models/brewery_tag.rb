class BreweryTag < ApplicationRecord
  belongs_to :brewery
  belongs_to :tag
end
