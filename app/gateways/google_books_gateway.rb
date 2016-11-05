require 'google/apis/books_v1'
require 'nokogiri'

class GoogleBooksGateway
  attr_accessor :id, :ids, :guaranteed_ids
  
  def initialize(params={})
    @id             = params[:id]
    @ids            = params[:ids]
    @guaranteed_ids = ([id]+[ids]).flatten(1).compact
  end
  
  def items
    guaranteed_ids.map {|id| single_listing(id)}
  end
  
  def single_listing(id)
    api.get_volume(id).volume_info
  end

  def search(query, params={})
    api.list_volumes(query, params).items.select do |b| 
      b.volume_info.image_links.present? && b.volume_info.description.present?
    end.map do |b|
      {
        title: art_name(b.volume_info),
        year: art_release_date(b.volume_info),
        type: art_category(b.volume_info),
        image: art_image(b.volume_info),
        id: b.id
      }
    end

  end

  def art_image(art)
    art_images(art)[-1]
  end
  
  def art_images(art)
    art.image_links.to_h.values
  end
  
  def art_additional_images(art)
    art_images(art) - [art_image(art)]
  end
  
  def art_creator(art)
    art.authors.join(", ")
  end
  
  def art_release_date(art)
    art.published_date
  end
  
  def art_name(art)
    art.title
  end
  
  def art_description(art)
    fragment = Nokogiri::HTML::DocumentFragment.parse art.description
    fragment.content
  end
  
  def art_category(art)
    "Books and Literature"
  end
  
  def art_source
    "https://books.google.com"
  end
  
  def art_source_link(art)
    art.preview_link
  end
  
  private
  
  def api
    Google::Apis::RequestOptions.default.retries = 5
    @api ||= Google::Apis::BooksV1::BooksService.new

    @api.key = ENV['google_books_key']
    @api
  end

end