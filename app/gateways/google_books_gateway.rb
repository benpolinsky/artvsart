require 'google/apis/books_v1'
require 'nokogiri'

class GoogleBooksGateway < AbstractGateway
  
  def single_listing(id)
    begin
      api.get_volume(id).volume_info
    rescue Google::Apis::ClientError => e
      error_response(e.message)
    rescue Google::Apis::ServerError
      error_response
    end
  end

  def search(query, params={})
    results = api.list_volumes(query, params).items
    if results
      results.select do |b| 
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
    else
      error_response
    end

  end

  def art_image(art)
    art_images(art)[-1]
  end
  
  def art_images(art)
    art.image_links.to_h.values
  end
  
  def art_creator(art)
    art.authors.join(", ")
  end
  
  def art_release_date(art)
    art.published_date
  end
  
  def art_description(art)
    fragment = Nokogiri::HTML::DocumentFragment.parse art.description
    fragment.content
  end
  
  def art_category(art)
    "Books and Literature"
  end
  
  def art_source
    "books.google.com"
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