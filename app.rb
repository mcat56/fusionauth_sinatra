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

  def application_id
    '9eef04cd-b188-42fa-b535-1962ff788b46'
  end

  get '/' do
    erb :'welcome/index'
  end

  get '/login' do
    erb :'/sessions/new'
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
        :applicationId => application_id,
        :preferredLanguages => %w(en fr),
        :roles => %w(user)
      }
    })
    session[:user_id] = id
    erb :'/users/show'
  end

  post '/login' do
    user_data = params[:user_data]
    response = fusionauth_client.login({
      :loginId => user_data[:email],
      :password => user_data[:password],
      :applicationId => application_id,
      })
    id = response.success_response.user.id
    session[:user_id] = id
    erb :'/users/show'
  end
end
