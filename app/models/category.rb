class Category < ApplicationRecord
  has_many :arts
  has_many :subcategories, class_name: "Category", foreign_key: 'parent_id'
  belongs_to :parent, class_name: "Category", foreign_key: 'parent_id'
  
  validates_presence_of :name

  extend FriendlyId
  friendly_id :name, use: :slugged
  
  def root?
    parent.blank?
  end
  
  def self.roots
    where(parent: nil)
  end
  
  def self.children
    where("parent_id IS NOT NULL")
  end
end
