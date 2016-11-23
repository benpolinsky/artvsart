desc "set category art counts"

task update_art_counts: :environment do
  Category.all.each do |category|
    Category.reset_counters(category.id, :arts)
  end
end