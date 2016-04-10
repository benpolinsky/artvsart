class Competition < ApplicationRecord
  belongs_to :challenger, class_name: "Art"
  belongs_to :art
end
