class Category < ApplicationRecord
  attr_accessor :parent_category
  
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
  
  def self.by_art_count
    Category.order(art_count: :desc)
  end
  
  def saves_with_parent_category?(params)
    if params[:parent_category].present?
      category = if params[:parent_category] == "none" 
        nil
      else
        Category.find_by(name: params.delete(:parent_category))
      end
      self.parent = category
    end
    assign_attributes(params)
    save
  end
  
end
