# Wrapper around a wrapper 
# Just pass in a User-like object

module Slacker
  def self.notify_slack(email)
    if Rails.env == 'production'
      channel = "#artvsartsignups"
    else 
      channel = "#justame"
    end
    notifier = ::Slack::Notifier.new ENV['slack_webhook'], channel: channel
    message = "Art vs Art Sign Up WHAT #{email}" 
    notifier.ping message unless Rails.env == "test"
  end
end