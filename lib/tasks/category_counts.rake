desc "set category art counts"

task update_art_counts: :environment do
  Category.all.each do |category|
    category.update(art_count: category.arts.count)
  end
end