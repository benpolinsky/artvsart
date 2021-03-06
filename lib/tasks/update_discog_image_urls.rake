desc "One Time: Update Discogs Image Urls"

task one_time_update_discogs_image_urls: :environment do 
    gateway = DiscogsGateway.new
    musics = Art.published.joins(:category).where(categories: {name: 'Music'})
    musics.each do |music|
        id = music.source_link.split("/").last
        art = gateway.single_listing(id)
        if art
            art_image = gateway.art_image(art)
            if art_image != music.image
                puts "\n"
                puts "Updating #{music.name}'s image from \n\n"
                puts music.image
                puts "\n\nto \n\n"
                puts art_image
                puts "\n\n"
                music.update(image: art_image)
            end
        end
    end
end