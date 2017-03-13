require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'httparty'
require_relative 'database_config'

get '/' do
  location = HTTParty.post("https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyDymhDvUDW4UO33LK-BRymut6RoM_pG4eI")
  lat = location['location']['lat']
  long = location['location']['lng']
  @food = HTTParty.post("https://developers.zomato.com/api/v2.1/locations?query=sydney", :headers => {"X-Zomato-API-Key" => "f4909ceb3554accebfc6de98eeac1b7a"})
  @search = HTTParty.post("https://developers.zomato.com/api/v2.1/search?lat=#{lat}&lon=#{long}&radius=1000", :headers => {"X-Zomato-API-Key" => "f4909ceb3554accebfc6de98eeac1b7a"})
  return @search.body
  # @search["restaurants"][0]["restaurant"]["name"]
  # @showme = @location['location']['lat']
  erb :index
end
