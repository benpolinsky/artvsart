class S3Controller < ApplicationController
  def sign
    s3_signer = S3Signer.new(params[:objectName], content_type: params[:contentType])
    render json: {signedUrl: s3_signer.put_url}
  end
end