class DiscountCode < ActiveRecord::Base
  belongs_to :restaurant
  belongs_to :user
  belongs_to :booking
  has_many :invitations
end
