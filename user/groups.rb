# -*- coding: utf-8 -*-
##---------------------------------------------------------------------------
## Create New Google Group
##---------------------------------------------------------------------------
##  ⚔Url: /createGroup?
#                     gemail=...
#                     &gname=...
#                     &gemail_alias=...
#                     &description=...
get '/createGroup' do

  group_email= params[:gemail]
  group_name= params[:gname]
  description= params[:description]
  aliases=params[:gemail_alias]

  new_group = admin_api.groups.insert.request_schema.new({
                                                           "email"=> group_email,
                                                           "name"=> group_name,
                                                           "description"=> description
                                                         })
  result = api_client.execute(
                              :api_method => admin_api.groups.insert,
                              :body_object => new_group
                              )
  puts "Creation of New Group Email: #{params[:group_email]} \n with alias: #{params[:group_email_alias]} succcesful."
  result.data.to_hash
end
###
##------------------------------------------------------------------------
# Add new member to the group
##------------------------------------------------------------------------
# ⚔Url:
#     /deleteGroup?gemail=testgroup@test.com
###
delete '/deleteGroup' do

  puts "Okies the googleGroup: #{params[:gemail]} is no more."
  result = api_client.execute(:api_method => admin_api.groups.delete,
                              :parameters=>{'groupKey'=> params[:gemail]}
                              )
  puts result.data
  puts "your group #{params[:gemail]} is no more"
end
###
##------------------------------------------------------------------------
# List All the users in the group
##------------------------------------------------------------------------
# ⚔Url:
#     /listGroupMembers?
#                      groupKey::gemail="emailOfyourgroup"
#                      role= role : { OWNER, MANAGER, MEMBER }   → Let's put MEMBER default
#                      maxResult
###
get '/listGroupMembers' do

  puts "Okies the googleGroup: #{params[:gemail]} is no more."
  result = api_client.execute(:api_method => admin_api.groups.delete,
                              :parameters=>{'groupKey'=> params[:gemail]}
                              )
  puts result.data
  puts "your group #{params[:gemail]} is no more"
end
###
#----------------------------------------------------------------------------
# Add new member to the group
#----------------------------------------------------------------------------
# ⚔Url:
#     /addUser2Group? group=group@id &
#                     email=email@id &
#                     role=one_of_following_roles &
#                     type=one_of_following_type
# Possible role : { OWNER, MANAGER, MEMBER }   → Let's put MEMBER default
# Possible type : { USER, GROUP }             → Let's put USER default
###
get '/addUser2Group' do

  group = params[:group]
  email= params[:email]

  #set role to MEMBER by default
  if params[:role].nil? || params[:role].length == 0
    role = 'MEMBER'
  else
    role = params[:role]
  end

  #set type to USER by default
  if params[:type].nil? || params[:type].length == 0
    type = 'USER'
  else
    type=params[:type]
  end

  puts "Adding...\t  #{params[:email]}\nto the group: #{params[:group]} :D \nas a: #{params[:type]} \n with role #{params[:role]} "

  new_group = admin_api.members.insert.request_schema.new({
                                                           "email"=> email,
                                                           "role"=> role,
                                                           "type"=> type
                                                         })
  result = api_client.execute(
                              :api_method => admin_api.members.insert,
                              :body_object => new_group,
                              :parameters => {'groupKey'=> "#{params[:group]}"}
                              )
  puts "Ok, succesfully added: #{params[:email]} \n to the group: #{params[:group]}:D \n as a: #{params[:type]} \n with role #{params[:role]} "
  result.data.to_hash
end
