require 'pry'
require 'sinatra'
require 'sinatra/reloader'
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

enable :sessions

helpers do
# area for methods
  def current_user_restaurant
    Restaurant.find_by(id: session[:user_id])
  end

  def logged_in_restaurant?
    !!current_user_restaurant
  end

  def current_user
    User.find_by(id: session[:user_id])
  end

  def logged_in?
    !!current_user
  end

  def random_user
    range_users = User.last.id - User.first.id
    random_user = rand(0..range_users) + User.first.id
    found_user = User.find_by(id: random_user)

    if found_user == nil
      return random_user
    else
      return found_user.id
    end
  end

  def invitations invitation_comment,owner_id,days_valid,date
    invite = Invitation.new
    invite.invite = invitation_comment
    invite.user_id = random_user
    invite.restaurant_id = owner_id
    invite.time_start = date[0].to_s + "/" + date[1].to_s + "/" + date[2].to_s
    invite.time_end = (date[0]+days_valid).to_s + "/" + date[1].to_s + "/" + date[2].to_s
    invite.save
  end

  def date_now
    day = Time.now.day
    month = Time.now.month
    year = Time.now.year
    date = [day,month,year]
    return date
  end

  def geolocation
    location = HTTParty.post("https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyDymhDvUDW4UO33LK-BRymut6RoM_pG4eI")
    lat = location['location']['lat']
    long = location['location']['lng']
    return [lat,long]
  end

  def search (location_array, radius = 1000)
    search = HTTParty.post("https://developers.zomato.com/api/v2.1/search?lat=#{location_array[0]}&lon=#{location_array[1]}&radius=#{radius}", :headers => {"X-Zomato-API-Key" => "f4909ceb3554accebfc6de98eeac1b7a"})
      # @search["restaurants"][0]["restaurant"]["name"] this gives the restaurant name
    return @search.body
  end

  def general_search (words)
    search = HTTParty.post("https://developers.zomato.com/api/v2.1/search?q=#{words}", :headers => {"X-Zomato-API-Key" => "f4909ceb3554accebfc6de98eeac1b7a"})
  end

  def locationQuery cityname
    food = HTTParty.post("https://developers.zomato.com/api/v2.1/locations?query=#{cityname}", :headers => {"X-Zomato-API-Key" => "f4909ceb3554accebfc6de98eeac1b7a"})
    return food
  end
end

get '/' do
  session = nil
  erb :index
  # raise "hi"
end

get '/result/:id' do
  @something = params[:id]

  erb :search_result
end

get '/user/registration' do
  erb :user_registration
end

get '/restaurant/registration' do
  erb :restaurant_registration
end

get '/about' do
  erb :about
end

get '/registration' do
  erb :registration
end

get '/restaurant/portal' do
  erb :restaurant_portal
end

get '/user/portal' do
  erb :user_portal
end

post '/session' do
  selector = params[:selector]
  if selector == "user"
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect '/'
    else
      erb :index
    end
  elsif selector == "restaurant"
    user = Restaurant.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect '/'
    else
      erb :index
    end
  else
    erb :index
  end
end

delete '/session' do
  session[:user_id] = nil
  redirect '/'
end

post '/chowdown' do
  user_search = params[:search_input]
  input_array = user_search.split(" ")
  query = input_array.join("&")
  if user_search != nil && user_search != ""
    redirect "/result/#{query}"
  else
    erb :index
  end
end

post '/user/registration/new' do
  password1 = params[:password]
  password2 = params[:password_check]
  if password1 == password2
    new_user = User.new
    new_user.first_name = params[:first_name]
    new_user.last_name = params[:last_name]
    new_user.date_of_birth= params[:date_of_birth]
    new_user.email = params[:email]
    new_user.mobile = params[:mobile]
    new_user.address = params[:address]
    new_user.suburb = params[:suburb]
    new_user.city = params[:city]
    new_user.password = params[:password]
    new_user.points = 10
    new_user.save
    redirect '/'
  else
    @comment = "Your password is incorrect"
    erb :user_registration
  end
end

post '/restaurant/registration/new' do
  password1 = params[:password]
  password2 = params[:password_check]
  if password1 == password2
    new_user = Restaurant.new
    new_user.first_name = params[:first_name]
    new_user.last_name = params[:last_name]
    new_user.email = params[:email]
    new_user.mobile = params[:mobile]
    new_user.restaurant_name = params[:restaurant_name]
    new_user.address = params[:address]
    new_user.suburb = params[:suburb]
    new_user.city = params[:city]
    new_user.password = params[:password]
    new_user.save
    redirect '/'
  else
    @comment = "Your password is incorrect"
    erb :restaurant_registration
  end
end

post '/invitations' do
  number_of_invites = params[:num_invites].to_i
  invitation_comment = params[:body]
  days_valid = params[:days_valid].to_i
  owner_id = current_user_restaurant.id
  date = date_now

  for i in 0..number_of_invites
    invitations(invitation_comment,owner_id,days_valid,date)
  end
  redirect '/restaurant/portal'
end

post '/delete/comment' do

end

post '/delete/invitation' do

end
