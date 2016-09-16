class HarvardArtGateway
  attr_reader :api, :id, :ids

  def initialize(params={})
    @id = params[:id]
    @ids = params[:ids]
  end
  
  
  def search(query, query_params={apikey: ENV['harvard_token']})
    query_params.reverse_merge!({title: query})
    api.get("/object?#{query_params.to_param}").body.records
  end
  
  
  def api(path='http://api.harvardartmuseums.org')
    @api ||= Faraday.new(url: path) do |connection|
      connection.request :url_encoded
      connection.response :json, content_type: /\bjson$/
      connection.adapter Faraday.default_adapter
      connection.use FaradayMiddleware::FollowRedirects
      connection.use Faraday::Response::RaiseError
    end
  end
  
  
end