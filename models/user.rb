class User < ActiveRecord::Base
  has_secure_password # you need bcrypt gem
  has_many :comments
  has_many :invitations
  has_many :wish_lists
  has_many :discount_codes
  has_many :bookings
end
