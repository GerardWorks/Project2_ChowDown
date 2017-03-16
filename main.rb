# require 'pry'
require 'sinatra'
# require 'sinatra/reloader'
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
    Restaurant.find_by(email: session[:user_id])
  end

  def logged_in_restaurant?
    !!current_user_restaurant
  end

  def current_user
    User.find_by(email: session[:user_id])
  end

  def logged_in?
    !!current_user
  end

  def random_user location
    found_user = User.where(city: location).sample
    if found_user == nil
      return User.all.sample.id
    else
      return found_user.id
    end
  end

  def discount_generator user_id,rest_id
    discount = DiscountCode.new
    discount.restaurant_id = rest_id
    discount.user_id = user_id
    discount.code = rand(123456..654321)
    discount.claim = "false"
    discount.save
    return discount
  end

  def invitations invitation_comment,owner_id,days_valid,date
    owner_location = Restaurant.find(owner_id).city
    invite = Invitation.new
    invite.invite = invitation_comment
    invite.user_id = random_user(owner_location)
    invite.restaurant_id = owner_id
    invite.time_start = date[0].to_s + "/" + date[1].to_s + "/" + date[2].to_s
    invite.time_end = (date[0]+days_valid).to_s + "/" + date[1].to_s + "/" + date[2].to_s
    invite.save
    discount = discount_generator(invite.user_id,invite.restaurant_id)
    invite.discount_code_id = discount.id
    invite.save
  end
  
  def date_now
    day = Time.now.day
    month = Time.now.month
    year = Time.now.year
    date = [day,month,year]
    return date
  end

  def restaurant_db_search name
    array_name = name.split(" ")
    array_caps = array_name.map{|x| x.capitalize}.join(" ")
    find = Restaurant.find_by(restaurant_name: array_caps)
    return find
  end


  def booking_create user_id,rest_id,person,date,time
    discount = discount_generator(user_id,rest_id)
    booking = Booking.new
    booking.restaurant_id = rest_id
    booking.user_id = user_id
    booking.code_id = discount.id
    booking.booking_date = date
    booking.booking_time = time
    booking.confirmation = "false"
    booking.person = person
    booking.save
  end

  def rating_average score1,score2,score3
    x = score1.to_i
    y = score2.to_i
    z = score3.to_i
    average_score = (x + y + z)/3.0
    return average_score
  end

  def create_comment (discount_id,user_id,restaurant_id,rating,body)
    comment = Comment.new
    comment.body = body
    comment.user_id = user_id
    comment.restaurant_id = restaurant_id
    comment.rating = rating
    comment.save
    discount_change = DiscountCode.find(discount_id)
    discount_change.claim = 'true'
    discount_change.save
  end

  def delete_old_invites invite_id
      file_invite = Invitation.find(invite_id)
      file_discount = file_invite.discount_code
      file_discount.destroy
      file_invite.destroy

      if current_user_restaurant != nil
        redirect '/restaurant/portal'
      elsif current_user != nil
        redirect '/user/portal'
      else
        erb :index
      end
  end

  def check_invites invite_id
    file = Invitation.find(invite_id)
    invite_time = file.time_end.split("/").map{|x| x.to_i}
    today_date = date_now

    if invite_time[0] < today_date[0] && invite_time[1] <= today_date[1] && invite_time[2] <= today_date[2]
      return delete_old_invites(invite_id)
    else
      return
    end
  end

  def rating_search name
    restaurant = restaurant_db_search(name)
    rating_sum = 0
    if restaurant != nil
      comments_length = restaurant.comments.length
      for i in 0..comments_length -1
        rating_sum += restaurant.comments[i].rating
      end
      average_rating = rating_sum/comments_length
      return average_rating
    else
      return "Currently no ratings with us"
    end
  end

  # def geolocation
  #   location = HTTParty.post("https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyDymhDvUDW4UO33LK-BRymut6RoM_pG4eI")
  #   lat = location['location']['lat']
  #   long = location['location']['lng']
  #   return [lat,long]
  # end

  def search (query, location_array, radius = 2000)
    search = HTTParty.post("https://developers.zomato.com/api/v2.1/search?q=#{query}&lat=#{location_array[0]}&lon=#{location_array[1]}&radius=#{radius}", :headers => {"X-Zomato-API-Key" => "f4909ceb3554accebfc6de98eeac1b7a"})
  end

  def search_my_area (location_array, radius = 2000)
    search = HTTParty.post("https://developers.zomato.com/api/v2.1/search?lat=#{location_array[0]}&lon=#{location_array[1]}&radius=#{radius}", :headers => {"X-Zomato-API-Key" => "f4909ceb3554accebfc6de98eeac1b7a"})
  end

  def general_search (words)
    search = HTTParty.post("https://developers.zomato.com/api/v2.1/search?q=#{words}", :headers => {"X-Zomato-API-Key" => "f4909ceb3554accebfc6de98eeac1b7a"})
  end

  def locationQuery cityname
    food = HTTParty.post("https://developers.zomato.com/api/v2.1/locations?query=#{cityname}", :headers => {"X-Zomato-API-Key" => "f4909ceb3554accebfc6de98eeac1b7a"})
  end
end

get '/' do
  session = nil
  erb :index
  # raise "hi"
end

get '/result/:id' do
  @array = params[:id].split("&&")
  lat = @array[1].to_f.round(4).to_s
  long = @array[2].to_f.round(4).to_s
  # binding.pry
  location = [lat,long]
  if @array[0] == 'chowdown'
    results = search_my_area(location)
    @restaurants = results["restaurants"]
  else
    results = search(@array[0],location)
    @restaurants = results["restaurants"]
  end
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
  @invitation = Invitation.where(restaurant_id: current_user_restaurant)
  @comment = Comment.where(restaurant_id: current_user_restaurant)
  @booking = Booking.where(restaurant_id: current_user_restaurant)
  erb :restaurant_portal
end

get '/user/portal' do
  @open = 900
  @close = 2100
  @invitation = Invitation.where(user_id: current_user)
  @comment = Comment.where(user_id: current_user)
  @booking = Booking.where(user_id: current_user)
  erb :user_portal
end

post '/session' do
  selector = params[:selector]
  if selector == "user"
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.email
      redirect '/'
    else
      erb :index
    end
  elsif selector == "restaurant"
    user = Restaurant.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.email
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
  location = params[:longnlat].gsub(" ","&&")
  remove_non_alpha_chars = user_search.downcase.gsub(/[^a-z0-9\s]/i, '')
  input_string = remove_non_alpha_chars.gsub(' ','%20')
  empty_query = "chowdown"+"&&"+location
  normal_query = input_string + "&&" +location
  if user_search == ""
    redirect "/result/#{empty_query}"
  elsif user_search != nil && user_search != ""
    redirect "/result/#{normal_query}"
  else
    erb :index
  end
end

post '/user/registration/new' do
  password1 = params[:password]
  password2 = params[:password_check]
  if password1 == password2 && password1 != "" && password2 != ""
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
  if password1 == password2 && password1 != "" && password2 != ""
    new_rest = Restaurant.new
    new_rest.first_name = params[:first_name]
    new_rest.last_name = params[:last_name]
    new_rest.email = params[:email]
    new_rest.mobile = params[:mobile]
    new_rest.restaurant_name = params[:restaurant_name]
    new_rest.address = params[:address]
    new_rest.suburb = params[:suburb]
    new_rest.city = params[:city]
    new_rest.password = params[:password]
    new_rest.save
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

  for i in 0..number_of_invites - 1
    invitations(invitation_comment,owner_id,days_valid,date)
  end
  redirect '/restaurant/portal'
end

get '/delete/comment/:id' do
  file = Comment.find(params[:id])
  file.destroy
  if current_user_restaurant != nil
    redirect '/restaurant/portal'
  elsif current_user != nil
    redirect '/user/portal'
  else
    erb :index
  end
end

get '/delete/invitation/:id' do
    file = Invitation.find(params[:id])
    file.destroy
    if current_user_restaurant != nil
      redirect '/restaurant/portal'
    elsif current_user != nil
      redirect '/user/portal'
    else
      erb :index
    end
end

get '/delete/booking/:id' do
  file = Booking.find(params[:id])
  if current_user_restaurant != nil
    file.destroy
    redirect '/restaurant/portal'
  elsif current_user != nil
    file.destroy
    redirect '/user/portal'
  else
    erb :index
  end
end

get "/approve/booking/:id" do
  file = Booking.find(params[:id])
  file.confirmation = "true"
  file.save
  redirect '/restaurant/portal'
end

post '/booking/create' do
  find_restaurant = restaurant_db_search(params[:name])
  if find_restaurant != nil
    booking_create(current_user.id,find_restaurant.id,params[:persons],params[:date],params[:time])
    redirect '/user/portal'
  else
    redirect '/user/portal'
  end
end

get '/claim/invitation/:id' do
  find = DiscountCode.find(params[:id])
  @discount_id = params[:id]
  @restaurant_id = find.restaurant.id
  @restaurant_name = find.restaurant.restaurant_name
  erb :claim
end

post '/comment/submit/:id' do
  discount_object = DiscountCode.find(params[:id])
  restaurant_id = discount_object.restaurant_id
  user_id = discount_object.user_id
  rating = rating_average(params[:service],params[:quality],params[:environment])
  body = params[:body]
  create_comment(params[:id],user_id,restaurant_id,rating,body)
  redirect '/user/portal'
end

get '/user/edit' do
  @session = current_user
  erb :user_profile
end

put '/user/update' do
  session_user = current_user
  if session_user && session_user.authenticate(params[:current_password])
    session_user.first_name = params[:first_name]
    session_user.last_name = params[:last_name]
    session_user.date_of_birth = params[:date_of_birth]
    session_user.email = params[:email]
    session_user.mobile = params[:mobile]
    session_user.address = params[:address]
    session_user.suburb = params[:suburb]
    session_user.city = params[:city]
    session_user.password = params[:new_password]
    session_user.save
    redirect '/user/portal'
  else
    redirect '/user/edit'
  end
end

get '/restaurant/edit' do
  @session = current_user_restaurant
  erb :restaurant_profile
end

put '/restaurant/update' do
  session_user = current_user_restaurant
  if session_user && session_user.authenticate(params[:current_password])
    session_user.first_name = params[:first_name]
    session_user.last_name = params[:last_name]
    session_user.restaurant_name = params[:restaurant_name]
    session_user.email = params[:email]
    session_user.mobile = params[:mobile]
    session_user.address = params[:address]
    session_user.suburb = params[:suburb]
    session_user.city = params[:city]
    session_user.password = params[:new_password]
    session_user.save
    redirect '/restaurant/portal'
  else
    redirect '/restaurant/edit'
  end
end
