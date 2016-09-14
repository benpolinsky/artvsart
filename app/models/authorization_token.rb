class AuthorizationToken < ApplicationRecord
  def self.artsy
    where(service: 'artsy').first
  end
  
  def expiring_soon?
    expires_on.nil? || expires_on <= 24.hours.from_now
  end
  
  def expired?
    expires_on.nil? || expires_on <= Time.zone.now
  end
end
