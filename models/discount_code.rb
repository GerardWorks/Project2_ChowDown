class DiscountCode < ActiveRecord::Base
  belongs_to :restaurant
  belongs_to :user
  has_many :bookings
end
