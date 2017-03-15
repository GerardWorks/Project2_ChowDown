class Booking < ActiveRecord::Base
  belongs_to :restaurant
  belongs_to :user
  belongs_to :discount_code
end
