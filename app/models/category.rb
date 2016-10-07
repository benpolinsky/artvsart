class Category < ApplicationRecord
  has_many :arts
  validates_presence_of :name

end
