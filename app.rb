require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'curb'
require 'colorize'
require_relative 'response_logic'
require_relative 'params_manager'

set :bind, Socket.ip_address_list.find { |ai|
  ai.ipv4? && !ai.ipv4_loopback? }.ip_address
set :port, 9494
set :logging, true
$responses_path = '/responses/responses.json'


configure do
  register Sinatra::Reloader
end

post '/validateJson' do
  validate_json_reply
end

post '/getConfigJson' do
  get_config_json
end

post '/getGlobalDelayFrom' do
  get_global_delay_from
end

post '/getGlobalDelayTo' do
  get_global_delay_to
end

post '/setServerAddress' do
  set_server_address
  status 200
end

post '/getServerAddress' do
  get_server_address
end

post '/resetServerAddress' do
  reset_server_address
  status 200
end

post '/setGlobalDelay' do
  set_global_delay
  status 200
end

post '/resetGlobalDelay' do
  reset_global_delay
  status 200
end

post '/setReply' do
  set_reply
  status 200
end

post '/resetReply' do
  reset_reply
  status 200
end

post '/saveFakeFile' do
  save_fake_file
  redirect to('/setconfig')
end

post '/getFakeImages' do
  get_fake_images
end

post '/getFakeFiles' do
  get_fake_files
end

post '/resetFakeImages' do
  reset_fake_images
  status 200
end

post '/resetFakeFiles' do
  reset_fake_files
  status 200
end

post '/applyConfigFile' do
  apply_config_file
  redirect to('/setconfig')
end

post '/addConfigFile' do
  add_config_file
  redirect to('/setconfig')
end

post '/applyTextAreaConfig' do
  apply_textarea_config
end

post '/dowloadFile' do
  attachment "config.json"
  get_config_json
end

post '/resetAll' do
  reset_config
  redirect to('/setconfig')
end

post  '/saveAsTemplate' do
  save_as_template
end

post '/setConfigFromTemplate' do
  set_config_from_template
  status 200
end

post '/delConfigFromTemplate' do
  del_config_from_template
end

post '/getConfigTemplates' do
  obj = get_config_templates.to_json
  obj
end

get '/__sinatra__/:image.png' do
  filename = File.dirname(__FILE__) + "/public/favicon.ico"
  content_type :ico
  send_file filename
end

get '/setconfigfromfile/:filename' do
  set_config_from_template
end

get '/setconfig' do 
  get_config_templates
  erb :form
end

get '/fakefile/:path/:file_name' do
  send_file "./responses/#{params[:path]}/#{params[:file_name]}"
end

get '/*' do
  get_response
end