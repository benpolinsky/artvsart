class PhilartGateway
  PHILART_ENDPOINT = "http://www.philart.net/api.json"

  attr_reader :api, :path, :paths
  
  def initialize(params={})
    @path = params[:path] || params[:listing_id]
    @paths = params[:paths] || params[:listing_ids]
  end
  
  def search(query, params={})
    art_link = api.links.find{|link| link.rel == 'titles'}.href
    art = api art_link
    query = Regexp.new(query, Regexp::IGNORECASE)
    art.body.list.select {|a| a["name"] =~ query}.map do |art| 
      art["title"] = art.delete("name")
      art["image"] = art_image(single_listing(link_for(art)))
      art['id'] = link_for(art)
      art
    end
  end
  
  def single_listing(path)
    api(path)
  end
  
  def items
    if path.present?
      [single_listing(path)]
    else
      paths.map do |path|
        single_listing(path)
      end
    end
  end
  
  def art_name(art)
    art['body']['title']['display']
  end
  
  def art_creator(art)
    artists = art.body['artists']
    artists ? art.body['artists'].map{|a| a["name"]}.join(", ") : "None Listed"
  end
  
  def art_description(art)
    [art_comments(art), art_location(art)].join('  ')
  end
  
  def art_release_date(art)
    art['body']['years'].map{|year| year['year']}.join(", ")
  end
  
  def art_location(art)
    "Located: #{art.body.location["description"]}."
  end
  
  def art_comments(art)
    art["body"]["comments"]
  end
  
  def art_image(art)
    art_images(art).first
  end
  
  def art_images(art)
    found_images = []
    art.body.pictures.each do |value| 
      found_images << value.values.map(&:url)
    end
    found_images.flatten
  end
  
  def link_for(art)
    art.links.find{|link| link.rel == 'self'}.href
  end

  
  def api(path=PHILART_ENDPOINT)
      Hyperclient.new(path) do |api|
        api.headers['Accept'] = 'application/vnd.philart-v2+json'
        api.connection(default: false) do |conn|
          conn.use FaradayMiddleware::FollowRedirects
          conn.use Faraday::Response::RaiseError
          conn.request :json
          conn.response :json, content_type: /\bjson$/
          conn.adapter :net_http
        end
      end

  end
  
end