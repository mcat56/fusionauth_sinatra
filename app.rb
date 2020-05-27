require 'sinatra'
require 'pry'
require './models/user'
require 'fusionauth/fusionauth_client'
Tilt.register Tilt::ERBTemplate, 'html.erb'

set :current_user, User.find(session[:user_id])

get '/' do
  erb :'welcome/index'
end

get '/register' do
  erb :'/users/new'
end

post '/register' do
  user_data = params[:user_data]
  id = SecureRandom.uuid

  client = FusionAuth::FusionAuthClient.new(
    'XyF5-fU3a-eeYMCx_PHaGAs18NMIGxRF4UPE1A8dA-U',
    'http://localhost:9011'
  )

  result = client.register(id, {
    :user => {
      :firstName => user_data[:first_name],
      :lastName => user_data[:last_name],
      :email => user_data[:email],
      :password => user_data[:password]
    },
    :registration => {
      :applicationId => '9eef04cd-b188-42fa-b535-1962ff788b46',
      :preferredLanguages => %w(en fr),
      :roles => %w(user)
    }
  })


  require "pry"; binding.pry
  erb :'/users/show'
end

get '/login' do
  erb :'/sessions/new'
end
