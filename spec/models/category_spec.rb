require 'rails_helper'

CATEGORY_ATTRIBUTES = [:name, :art_count]
VALID_CATEGORY_ATTRIBUTES = [:name]

RSpec.describe Category, type: :model do
  CATEGORY_ATTRIBUTES.each do |attr|
    it "has a #{attr.to_s}" do
      category = Category.new
      expect(category).to respond_to(attr)
    end
  end
  
  
  context "validations" do
    VALID_CATEGORY_ATTRIBUTES.each do |att|
      it "is invalid without a #{att}" do
        category = Category.new
        expect(category).to_not be_valid
        expect(category.errors[att].size).to eq 1
        category[att] = "A Valid #{att}"
        expect(category).to be_valid
        expect(category.errors[att].size).to eq 0
      end
    end
  end
  context "slugs" do
    let(:category){ Category.create(name: "Just here for the slugs") }
    
    it "uses its name" do
      expect(category.slug).to eq "just-here-for-the-slugs"
    end
  end
  
  context "subcategories" do
    let(:category){ Category.create(name: "Art") }
    it "has many subcategories" do
      expect(category.subcategories.size).to eq 0
      category.subcategories << Category.create(name: "Architecture")
      expect(category.subcategories.size).to eq 1
    end
    
    it "has a parent if a subcategory" do
      architecture = Category.create(name: "Architecture")
      category.subcategories << architecture
      expect(architecture.parent).to eq category
    end
    
    it "determines if it's the #root? or not" do
      architecture = Category.create(name: "Architecture")
      category.subcategories << architecture
      expect(category.root?).to eq true
      expect(architecture.root?).to eq false
    end
    
    it "retrieves only ::roots" do
      architecture = Category.create(name: "Architecture")
      category.subcategories << architecture
      expect(Category.roots).to include category
      expect(Category.roots).to_not include architecture
    end
    
    it "retrieves only ::children" do
      architecture = Category.create(name: "Architecture")
      category.subcategories << architecture
      expect(Category.children).to_not include category
      expect(Category.children).to include architecture
    end
  end
  
end