require 'fusionauth/fusionauth_client'
require 'sinatra/activerecord'
require 'sinatra'
require './models/user'
require 'pry'
Tilt.register Tilt::ERBTemplate, 'html.erb'

class FusionAuthApp < Sinatra::Base
  enable :sessions

  def current_user
    @current_user ||= User.find(session[:user_id])
  end

  def fusionauth_client
    @client = FusionAuth::FusionAuthClient.new(
      'XyF5-fU3a-eeYMCx_PHaGAs18NMIGxRF4UPE1A8dA-U',
      'http://localhost:9011'
    )
  end

  get '/' do
    erb :'welcome/index'
  end

  get '/register' do
    erb :'/users/new'
  end

  post '/register' do
    user_data = params[:user_data]
    id = SecureRandom.uuid

    result = fusionauth_client.register(id, {
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
end
