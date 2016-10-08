class Category < ApplicationRecord
  has_many :arts
  validates_presence_of :name

  extend FriendlyId
  friendly_id :name, use: :slugged
end
