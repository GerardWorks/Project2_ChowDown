class Booking < ActiveRecord::Base
  belongs_to :restaurant
  belongs_to :user
  has_one :discount_code
end
