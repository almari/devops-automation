#!/bin/env ruby

require 'rubygems'
require 'google/api_client'
#require 'sinatra'
#require 'logger'
require 'launchy'
require 'httparty'

#Credentials form the Google APIs Console
CLIENT_ID = '505116653458.apps.googleusercontent.com'
CLIENT_SECRET= 'HkeV-VsdGPYLzs9aHmCaGKIw'
OAUTH_SCOPE="https://www.googleapis.com/auth/admin.directory.user https://www.googleapis.com/auth/admin.directory.user.readonly"
REDIRECT_URI='urn:ietf:wg:oauth:2.0:oob'

#create an google api client & load Google Admin SDK API
cf_client=Google::APIClient.new
api =cf_client.discovered_api("admin", "directory_v1")

#request the authorization
cf_client.authorization.client_id= CLIENT_ID
cf_client.authorization.client_secret= CLIENT_SECRET
cf_client.authorization.scope= OAUTH_SCOPE
cf_client.authorization.redirect_uri= REDIRECT_URI

uri = cf_client.authorization.authorization_uri
puts uri
Launchy.open(uri)

#Exchange authorization code for access token
$stdout.write "Authorization code please: "
cf_client.authorization.code = gets.chomp
cf_client.authorization.fetch_access_token!

# code dealing with client and auth
#credit: http://goo.gl/weRQPO
new_user = api.users.insert.request_schema.new({
  'password' => 'apple123',
  'primaryEmail' => 'factorybot@sproutify.com',
  'name' => {
    'familyName' => 'cf',
    'givenName' => 'bot'
  }
})

result = cf_client.execute(
  :api_method => api.users.insert,
  :body_object => new_user
)

puts result.data.to_hash
#master_url= 'https://www.googleapis.com/admin/directory/v1'
#resp = HTTParty.get("#{master_url}/zerOnepal@sukulgunda.mygbiz.com?key=#{token}")
#result = cf_client.execute(
#                           :api_method =>



# enable :sessions

# def logger; settings.logger end

# def api_client; settings.api_client; end

# def calendar_api; settings.calendar; end

# def user_credentials
#   # Build a per-request oauth credential based on token stored in session
#   # which allows us to use a shared API client.
#   @authorization ||= (
#     auth = api_client.authorization.dup
#     auth.redirect_uri = to('/oauth2callback')
#     auth.update_token!(session)
#     auth
#   )
# end

# configure do
#   log_file = File.open('calendar.log', 'a+')
#   log_file.sync = true
#   logger = Logger.new(log_file)
#   logger.level = Logger::DEBUG

#   client = Google::APIClient.new
#   client.authorization.client_id = '993914706015-eggi75acq4cvpusohtor9vro45qsmh0g.apps.googleusercontent.com'
#   client.authorization.client_secret = 'Y1wkvovRRRS4m_4gKltthRbl'
#   client.authorization.scope = 'https://www.googleapis.com/auth/calendar'

#   calendar = client.discovered_api('calendar', 'v3')

#   set :logger, logger
#   set :api_client, client
#   set :calendar, calendar
# end

# before do
#   # Ensure user has authorized the app
#   unless user_credentials.access_token || request.path_info =~ /^\/oauth2/
#     redirect to('/oauth2authorize')
#   end
# end

# after do
#   # Serialize the access/refresh token to the session
#   session[:access_token] = user_credentials.access_token
#   session[:refresh_token] = user_credentials.refresh_token
#   session[:expires_in] = user_credentials.expires_in
#   session[:issued_at] = user_credentials.issued_at
# end

# get '/oauth2authorize' do
#   # Request authorization
#   redirect user_credentials.authorization_uri.to_s, 303
# end

# get '/oauth2callback' do
#   # Exchange token
#   user_credentials.code = params[:code] if params[:code]
#   user_credentials.fetch_access_token!
#   redirect to('/')
# end

# get '/' do
#   # Fetch list of events on the user's default calandar
#   result = api_client.execute(:api_method => settings.calendar.events.list,
#                               :parameters => {'calendarId' => 'primary'},
#                               :authorization => user_credentials)
#   [result.status, {'Content-Type' => 'application/json'}, result.data.to_json]
# end
