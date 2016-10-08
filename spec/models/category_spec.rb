require 'rails_helper'

CATEGORY_ATTRIBUTES = [:name, :art_count]
VALID_ATTRIBUTES = [:name]

RSpec.describe Category, type: :model do
  CATEGORY_ATTRIBUTES.each do |attr|
    it "has a #{attr.to_s}" do
      category = Category.new
      expect(category).to respond_to(attr)
    end
  end
  
  
  context "validations" do
    VALID_ATTRIBUTES.each do |att|
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
  
end