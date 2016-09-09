class ArtsyAPI < HyperResource
  ARTSY_TOKEN = ENV['artsy_token']
  ARTSY_ENDPOINT = 'https://api.artsy.net/api'
  
  self.root = ARTSY_ENDPOINT
  self.headers = {
    'Accept' => 'application/vnd.artsy-v2+json',
    'X-Xapp-Token' => ARTSY_TOKEN
  }
end

