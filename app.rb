require 'fusionauth/fusionauth_client'
require 'sinatra/activerecord'
require 'sinatra'
require './models/user'
require './models/identity'
require './models/registration'
require 'sinatra/flash'
require 'sinatra/json'
require 'sinatra/cookies'
require 'json'
require 'pry'
Tilt.register Tilt::ERBTemplate, 'html.erb'

class FusionAuthApp < Sinatra::Base
  helpers Sinatra::Cookies
  register Sinatra::Flash
  use Rack::Session::Cookie, :key => 'rack.session',
                             :path => '/',
                             :secret => ENV['SECRET']

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
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
    if current_user != nil
      erb :'/users/show'
    else
      erb :'welcome/index'
    end
  end

  get '/login' do
    if current_user != nil
      erb :'/users/show'
    else
      erb :'/sessions/new'
    end
  end

  get '/register' do
    if current_user != nil
      erb :'/users/show'
    else
      erb :'/users/new'
    end
  end

  post '/register' do
    user_data = params[:user_data]
    id = SecureRandom.uuid

    response = fusionauth_client.register(id, {
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
    if response.success_response
      session[:user_id] = id
      erb :'/users/show'
    else
      flash[:error] = 'Registration unsuccessful. Please try again.'
      erb :'/welcome/index'
    end
  end

  post '/login' do
    user_data = params[:user_data]
    response = fusionauth_client.login({
      :loginId => user_data[:email],
      :password => user_data[:password],
      :applicationId => application_id,
      })
    if response.success_response
      id = response.success_response.user.id
      session[:user_id] = id
      erb :'/users/show'
    else
      flash[:error] = "Unsuccessful login. Please try again."
      erb :'sessions/new'
    end
  end

  get '/user' do
    response = fusionauth_client.retrieve_user(current_user.id)
    if response.success_response
      json response.success_response.user
    else
      flash[:error] = 'Cannot find user information. Please try again.'
    end
  end

  get '/edit' do
    erb :'users/edit'
  end

  patch '/users/:id' do
    request = params[:user_data].select {|k,v| v != ''}
    patch_request = { user: request }
    response = fusionauth_client.patch_user(current_user.id, patch_request)
    if response.success_response
      flash[:success] = 'Update successful!'
      erb :'/users/show'
    else
      flash[:error] = 'Update unsuccessful. Please try again.'
      erb :'/upate'
    end
  end

  get '/logout' do
    fusionauth_client.logout(true, nil)
    flash[:notice] = 'Logout Successful'
    erb  :'/welcome/index'
  end

  delete '/delete_account' do
    fusionauth_client.delete_user(current_user.id)
    flash[:notice] = 'Account Successfully deleted'
    erb :'/welcome/index'
  end
end
