require 'rubygems'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'sinatra'
require 'logger'

require_relative 'groups'
enable :sessions

CREDENTIAL_STORE_FILE = "#{$0}-oauth2.json"

def logger; settings.logger end

def api_client; settings.api_client; end

def admin_api; settings.admin; end

def user_credentials
  # Build a per-request oauth credential based on token stored in session
  # which allows us to use a shared API client.
  @authorization ||= (
    auth = api_client.authorization.dup
    auth.redirect_uri = to('/oauth2callback')
    auth.update_token!(session)
    auth
  )
end

configure do
  log_file = File.open('admin.log', 'a+')
  log_file.sync = true
  logger = Logger.new(log_file)
  logger.level = Logger::DEBUG

  client = Google::APIClient.new(
    :application_name => 'Google Apps Manager',
    :application_version => '0.0.1')

  file_storage = Google::APIClient::FileStorage.new(CREDENTIAL_STORE_FILE)

  if file_storage.authorization.nil?
    client_secrets = Google::APIClient::ClientSecrets.load
    client.authorization = client_secrets.to_authorization

  #scopes involved
  client.authorization.scope = ["https://www.googleapis.com/auth/admin.directory.user","https://www.googleapis.com/auth/admin.directory.user.readonly","https://www.googleapis.com/auth/admin.directory.group","https://www.googleapis.com/auth/admin.directory.group","https://www.googleapis.com/auth/admin.directory.group.member","https://www.googleapis.com/auth/admin.directory.group.readonly"]

  else
    client.authorization = file_storage.authorization

  #scopes involved
  client.authorization.scope = ["https://www.googleapis.com/auth/admin.directory.user","https://www.googleapis.com/auth/admin.directory.user.readonly","https://www.googleapis.com/auth/admin.directory.group","https://www.googleapis.com/auth/admin.directory.group","https://www.googleapis.com/auth/admin.directory.group.member","https://www.googleapis.com/auth/admin.directory.group.readonly"]

  end

  # Since we're saving the API definition to the settings, we're only retrieving
  # it once (on server start) and saving it between requests.
  # If this is still an issue, you could serialize the object and load it on
  # subsequent runs.

#  calendar = client.discovered_api('calendar', 'v3')
  admin = client.discovered_api('admin', 'directory_v1')

  set :logger, logger
  set :api_client, client
  set :admin, admin
end

before do
  # Ensure user has authorized the app
  unless  user_credentials.access_token || request.path_info =~ /\A\/oauth2/
    redirect to('/oauth2authorize')
  end
end

after do
  # Serialize the access/refresh token to the session and credential store.
  session[:access_token] = user_credentials.access_token
  session[:refresh_token] = user_credentials.refresh_token
  session[:expires_in] = user_credentials.expires_in
  session[:issued_at] = user_credentials.issued_at

  file_storage = Google::APIClient::FileStorage.new(CREDENTIAL_STORE_FILE)
  file_storage.write_credentials(user_credentials)
end

get '/oauth2authorize' do
  # Request authorization
  redirect user_credentials.authorization_uri.to_s, 303
end

get '/oauth2callback' do
  #    File.open('hawa.txt','a+') {|f| f.write("yaha aaiyo") }
  # Exchange token
  user_credentials.code = params[:code] if params[:code]
  user_credentials.fetch_access_token!
  # File.open('hawa.txt','a+') {|f| f.write("yaha BATA PARA AAYO") }
  puts "Yippy, successful #{params[:code]}"
  #  puts user_credentials.authorization_uri
end

get '/' do

# Make an API call to retrive user.,

  #puts api_client
  #puts user_credentials.access_token
  #puts user_credentials.authorization_uri

# result = api_client.execute(
#                              :api_method => admin_api.users.get,
#                              :parameters => {'userKey' => 'blah@sukulgunda.mygbiz.com'},
#                              :authorization => user_credentials
#                              )
 # puts result.status
#  [ attr_reader :result.status, {'Content-Type' => 'application/json'}, result.data.to_json ]
  #puts result.data.to_json

  #puts result.data.to_json


  #result = api_client.execute(:api_method => calendar_api.events.list,
  #                            :parameters => {'calendarId' => 'primary'},
  #                            :authorization => user_credentials)
  #[result.status, {'Content-Type' => 'application/json'}, result.data.to_json]
  #  'Hello world'
  # 'I got the code'
end


# Creating a new user
#credit:http://goo.gl/weRQPO
#
#call like this url:
#               "http://localhost:4567/createUser?name=Bir&sname=Gorkhali"
# and the email id of Bir Gorkahali will be "bir.gorkhali@domainname.com"
#
get '/createUser' do

  #paramaters needed: { Name and FamilyName }
  name = params[:name]
  sname = params[:sname]
  passwd = 'tech@sprout'
  email ="#{name.downcase}.#{sname.downcase}@sukulgunda.mygbiz.com"

  new_user = admin_api.users.insert.request_schema.new({
                                                         'password' => passwd,
                                                         'primaryEmail' => email,
                                                         "changePasswordAtNextLogin"=> true,
                                                         'name' => {
                                                           'familyName' => sname,
                                                           'givenName' => name
                                                         }


                                                       })
  result = api_client.execute(
                              :api_method => admin_api.users.insert,
                              :body_object => new_user
                              )
  puts "Hurray, New User #{email} created. :)"
  result.data.to_hash

end


get '/getUser' do

  puts "Retriving info for : #{params[:email_addr]}"
  result = api_client.execute(
                              :api_method => admin_api.users.get,
                              :parameters => {"userKey" => "#{params[:email_addr]}"}

                              )
    result.data.to_hash
end

# get '/updateUser' do

#   puts "Deleting the User : #{params[:email_addr]}"
#   result = api_client.execute(
#                               :api_method => admin_api.users.delete,
#                               :parameters => {"userKey" => "#{params[:email_addr]}"}

#                               )
#   result.data

# end

get '/deleteUser' do

  puts "Deleting the User : #{params[:email_addr]}"
  result = api_client.execute(
                              :api_method => admin_api.users.delete,
                              :parameters => {"userKey" => "#{params[:email_addr]}"}

                              )
  result.data

end

get '/listUsers' do

  puts "Listing all the user : #{params[:domain]}"
  result = api_client.execute(
                              :api_method => admin_api.users.list,
                              :parameters => {"domain" => "#{params[:domain]}"}

                              )
  result.data.to_hash

end







# get '/calander' do

#   # Fetch list of events on the user's default calandar
#   result = api_client.execute(:api_method => calendar_api.events.list,
#                               :parameters => {'calendarId' => 'primary'},
#                               :authorization => user_credentials)
#   [result.status, {'Content-Type' => 'application/json'}, result.data.to_json]
# end
