# -*- coding: utf-8 -*-
##---------------------------------------------------------------------------
## Create New Google Group
##---------------------------------------------------------------------------
##  ⚔Url: /createGroup?
#                     gemail=...
#                     &gname=...
#                     &gemail_alias=...
#                     &description=...
post '/createGroup' do

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
  puts "Creation of New Group Email: #{params[:gemail]} \n with alias: #{params[:gemail_alias]} succcesful."
  result.data.to_json
end
###
##------------------------------------------------------------------------
# Delete the whole Group
##------------------------------------------------------------------------
# ⚔Url:
#     /deleteGroup?gemail=test.group@test.com
###
delete '/deleteGroup' do


  result = api_client.execute(:api_method => admin_api.groups.delete,
                              :parameters=>{'groupKey'=> params[:gemail]}
                              )
  puts result.data.to_hash
  puts "your group #{params[:gemail]} is no more"
end
###
##------------------------------------------------------------------------
# List All the groups in th organistaon
##------------------------------------------------------------------------
# ⚔Url:
#     /listGroups?
#                      doamin= ...   → Let's put sukulgunda.mygbiz.com
#                      ... other options left to be added
###
get '/listGroups' do

  params[:doamin]= 'sukulgunda.mygbiz.com'
  puts "listing all the available groups: #{params[:domain]}"
  result = api_client.execute(:api_method => admin_api.groups.list,
                              :parameters=>{'domain'=> params[:domain]})
  puts "your group are #{result.data.to_hash}"
  result.data.to_json

end
###
#----------------------------------------------------------------------------
# Getting information about group
#----------------------------------------------------------------------------
# ⚔Url:
#     /getGroup?gemail=group@id
###
get '/getGroup' do

  result = api_client.execute(:api_method => admin_api.groups.get,
                              :parameters=>{'groupKey'=> params[:gemail]}
                              )
  puts "Ok, retrived info for: #{params[:gemail]} "
  result.data.to_hash
end
###
