class S3Signer
  attr_reader :s3_object_name, :content_type, :s3_options, :headers

  def initialize(object_name, options={})
    @content_type = options[:content_type]
    @s3_options = {path_style: true}
    @headers = {"Content-Type" => content_type, "x-amz-acl" => "public-read"}
    @s3_object_name = object_name
  end
  
  
  def storage
    Fog::Storage.new(
      provider: 'AWS',
      aws_access_key_id: ENV['s3_access_key_id'],
      aws_secret_access_key: ENV['s3_secret_access_key'],
      region: ENV['s3_bucket_region']
    )
  end
  
  def put_url
    storage.put_object_url(ENV['s3_bucket_name'], "art/#{s3_object_name}", 15.minutes.from_now.to_time.to_i, headers, s3_options)
  end
  
end