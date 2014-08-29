require 'sinatra/base'
require 'rake'
require 'httparty'

class Foursquare < Sinatra::Base
	enable :sessions

  	helpers do
  		def client_id
	  		ENV['client_id'] = 'SARNKCB5OFBOXNTQIRXS2ATNJFVJOWNQQUQVSU4W1HS4YRID'
	  	end

	  	def client_secret
	  		ENV['client_secret'] = 'XAHXGO1XAHR54PIIY2F0SFFWJILG3ILMTRGWUNMM2IBKLRFB'
	  	end

	  	def redirect_uri
	  		ENV['redirect_uri'] = 'http://localhost:9292/auth'
	  	end

	  	def get_user_json
	  		return user_json ||= HTTParty.get("https://api.foursquare.com/v2/users/self?oauth_token=#{session['access_token']}&v=20140827").fetch("response")
	  	end
  	end

	get "/" do 
		erb :home_page, :layout => false
	end

	get '/sign-up' do
		redirect "https://foursquare.com/oauth2/authenticate?client_id=#{client_id}&response_type=code&redirect_uri=#{redirect_uri}"
	end

	get '/auth' do
		code = params[:code]
		url = "https://foursquare.com/oauth2/access_token?client_id=#{client_id}&client_secret=#{client_secret}&grant_type=authorization_code&redirect_uri=#{redirect_uri}&code=#{code}"
		session['access_token'] = HTTParty.get(url)["access_token"]
		redirect '/query'
	end

	get '/query' do
		@username = get_user_json["user"]["firstName"]
		@user_location = get_user_json["user"]["homeCity"]
		erb :query
	end

	get '/results' do
		search_query = params[:search]
		city = get_user_json["user"]["homeCity"]
		url = URI.escape("https://api.foursquare.com/v2/venues/search?client_id=#{client_id}&client_secret=#{client_secret}&v=20140815&query=#{search_query}&near=#{city}&limit=50")
		@query = HTTParty.get(url).fetch("response")["venues"]
		erb :results
	end

	get '/privacy' do
		"privacy"
	end
end