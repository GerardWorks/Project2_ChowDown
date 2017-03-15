require 'pry'
require 'sinatra'
require 'pg'
require 'httparty'
require_relative 'database_config'
require_relative 'models/booking'
require_relative 'models/comment'
require_relative 'models/discount_code'
require_relative 'models/invitation'
require_relative 'models/open_promo'
require_relative 'models/restaurant'
require_relative 'models/user'
require_relative 'models/wish_list'

binding.pry
# TEST DATA ENTERED

# User.create(first_name: 'John',last_name: 'Smith',date_of_birth: '10/11/12',email: 'john.smith@mail.com', mobile: '0404232323', address: '123 someplace somewhere', suburb: 'suburbie', city: 'citiesh', password: 'pudding', points: 0)
#
# Restaurant.create(first_name: 'Michael', last_name: 'Pomp', email: 'michael.pomp@mail.com', mobile: '0142412412', restaurant_name: "Michaels Pistacio's", address: '292 Wowzat Way', suburb: 'suburbie', city: 'citiesh', password: 'michpomp')
#
# Comment.create(body: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", rating: 8, restaurant_id: 1, user_id: 1)
#
# Invitation.create(invite:"You have been invited", user_id: 1, restaurant_id: 1, time_start: "2017-03-15 14:28:06 +1100", time_end: "2017-03-15 14:28:06 +1100")
#
# OpenPromo.create(restaurant_id: 1, time_start: "2017-03-14 14:28:06 +1100", time_end: "2017-03-15 14:28:06 +1100", promotion_headline: "THIS IS A PROMOTION!", promotion: "promotion text yeah this is great.")
#
# WishList.create(restaurant_id: 1, user_id: 1, time_start: "2017-03-14 14:28:06 +1100", time_end: "2017-03-15 14:28:06 +1100")
#
# DiscountCode.create(restaurant_id: 1, user_id: 1, code: "123codeme" )
#
# Booking.create(restaurant_id: 1, user_id: 1, code_id:1, booking_date: "2017-03-14 14:28:06 +1100", booking_time: "2017-03-15 14:28:06 +1100")
