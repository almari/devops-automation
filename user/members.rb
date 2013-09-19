# -*- coding: utf-8 -*-
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
get '/addGroupMember' do

  group = params[:group]
  member = params[:member]

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

  puts "Adding...\t  #{params[:member]}\nto the group: #{params[:group]} :D \nas a: #{params[:type]} \n with role #{params[:role]} "

  new_group = admin_api.members.insert.request_schema.new({
                                                           "email"=> member,
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
###
get '/getMembers' do

  puts "Retriving info for : #{params[:email]}"
  result = api_client.execute(
                              :api_method => admin_api.members.list,
                              :parameters => {"groupKey" => params[:email]}

                              )
    result.data.to_json
end

get '/deleteGroupMember' do

  puts "Deleting the User : #{params[:member]} \n from the group: #{params[:group]} "
  result = api_client.execute(
                              :api_method => admin_api.members.delete,
                              :parameters =>
                              {
                                "groupKey" => params[:group],
                                "memberKey" => params[:member]
                              }
                              )
  result.data.to_json

end
