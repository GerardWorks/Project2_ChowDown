class Restaurant < ActiveRecord::Base
  has_secure_password # you need bcrypt gem
  has_many :bookings
  has_many :comments
  has_many :discount_codes
  has_many :invitations
  has_many :open_promos
end
