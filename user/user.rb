# Creating a new user
#credit:http://goo.gl/weRQPO
#
#call like in this url:
#               "http://localhost:4567/createUser?name=Bir&sname=Gorkhali"
# and the email id of Bir Gorkahali will be "bir.gorkhali@domainname.com"
#
post '/createUser' do
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
                                                           'familyName' => sname.capitalize,
                                                           'givenName' => name.capitalize
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

  puts "Retriving info for : #{params[:email]}"
  result = api_client.execute(
                              :api_method => admin_api.users.get,
                              :parameters => {"userKey" => "#{params[:email]}"}

                              )
    result.data.to_json
end

# get '/updateUser' do

#   puts "Deleting the User : #{params[:email_addr]}"
#   result = api_client.execute(
#                               :api_method => admin_api.users.delete,
#                               :parameters => {"userKey" => "#{params[:email_addr]}"}

#                               )
#   result.data

# end

delete '/deleteUser' do

  puts "Deleting the User : #{params[:email]}"
  result = api_client.execute(
                              :api_method => admin_api.users.delete,
                              :parameters => {"userKey" => "#{params[:email]}"}

                              )
  result.data.to_json

end

get '/listUsers' do

  puts "Listing all the user : #{params[:domain]}"
  result = api_client.execute(
                              :api_method => admin_api.users.list,
                              :parameters => {"domain" => "#{params[:domain]}"}

                              )
  result.data.to_json

end
