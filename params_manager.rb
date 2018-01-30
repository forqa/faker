require_relative 'response_logic'

def get_server_address
    if nil_or_empty?(json_parser['serverAddress'])
      'Set redirect address (e.g. http://test.ru)'
    else
      json_parser['serverAddress']
    end
end

def set_server_address
  config_json = json_parser
  config_json['serverAddress'] = params[:serverAddress].gsub(/\/$/, '')
  write_to_responses(config_json)
end

def reset_server_address
  config_json = json_parser
  config_json['serverAddress'].clear
  write_to_responses(config_json)
end
  
def get_global_delay_from
	if nil_or_empty?(json_parser['globalDelayFrom'])
		'Randomize from'
	else
		json_parser['globalDelayFrom']
	end
end
  
def get_global_delay_to
	if nil_or_empty?(json_parser['globalDelayTo'])
		'Randomize to'
	else
		json_parser['globalDelayTo']
	end
end
	
def set_global_delay
	config_json = json_parser
	delayFrom = params[:globalDelayFrom]
	delayTo = params[:globalDelayTo]
	if (!nil_or_empty?(delayFrom) && delayFrom > delayTo)
		delayTo = delayFrom
	elsif (!nil_or_empty?(delayTo) && nil_or_empty?(delayFrom))
		delayFrom = '0'
	end
	config_json['globalDelayFrom'] = delayFrom
	config_json['globalDelayTo'] = delayTo
	write_to_responses(config_json)
end

def reset_global_delay
  config_json = json_parser
  config_json['globalDelayFrom'].clear
  config_json['globalDelayTo'].clear
  write_to_responses(config_json)
end
  
def get_fake_images
  fake_images = `ls -C './responses/img/'`.split
	if not fake_images.any?
		fake_images = 'No fake images'
  end
  fake_images
end

def reset_fake_images
  system ("rm -rf ./responses/img/*")
end

def get_fake_files
	fake_files = `ls -C './responses/files/'`.split
	if not fake_files.any?
		fake_files = 'No fake files'
  end
  fake_files
end

def reset_fake_files
  system ("rm -rf ./responses/files/*")
end

def set_reply
  path = params[:request].gsub(/[\?].*/, '').gsub(/^\//, '')
  if params[:request].include? '?'
    query = params[:request].gsub(/.*[\?]/, '')
  end
  replyType = params[:replyType]
  reply = params[:reply]
  if (!nil_or_empty?(reply) && valid_json?(reply) && (replyType == 'Fake json' || replyType == 'Merge json'))
    reply = JSON.parse(reply)
  end
  findEditingPart = params[:findEditingPart]
  if (!nil_or_empty?(findEditingPart) && valid_json?(findEditingPart))
    findEditingPart = JSON.parse(findEditingPart)
  else 
    findEditingPart = ''
  end
  delayFrom = params[:customDelayFrom]
  delayTo = params[:customDelayTo]
  if (!nil_or_empty?(delayFrom) && delayFrom > delayTo)
    delayTo = delayFrom
  elsif (!nil_or_empty?(delayTo) && nil_or_empty?(delayFrom))
    delayFrom = '0'
  end
  config_json = json_parser
  config_json_size = config_json['responseList'].size
  config_json['responseList'].insert(config_json_size, {path: path,
                                                        query: query,
                                                        customDelayFrom: delayFrom,
                                                        customDelayTo: delayTo,
                                                        accumulationDelay: params[:accumulationDelay],
                                                        httpCode: params[:httpCode],
                                                        contentType: params[:contentType],
                                                        customContentType: params[:customContentType],
                                                        replyType: params[:replyType],
                                                        dontSendRequest: params[:dontSendRequest],
                                                        findEditingPart: findEditingPart,
                                                        reply: reply
                                                        })
  write_to_responses(config_json)
end

def apply_textarea_config
  @file = params[:textConfigFile]
  if valid_json?(@file)
    File.open("./responses/responses.json", 'wb') do |f|
      f.write(@file)
    end
    status 200
  else
    status 400
    critical_error = 'json is not valid, fix error or click on button reset all'    
  end
end

def add_config_file
  if not params[:file].nil?
    file = File.read(params[:file][:tempfile])
    file_temlate = params[:file][:filename].gsub(' ', '')
    File.new("./responses/templates/#{file_temlate}", "w")
    File.open("./responses/templates/#{file_temlate}", 'wb') do |f|
      f.write(file)
    end
  end
end

def apply_config_file
  if not params[:file].nil?
    file = File.read(params[:file][:tempfile])
    if valid_json?(file)
      file_temlate = params[:file][:filename].gsub(' ', '')
      File.new("./responses/templates/#{file_temlate}", "w")
      File.open("./responses/templates/#{file_temlate}", 'wb') do |f|
        f.write(file)
      end
      File.open("./responses/responses.json", 'wb') do |f|
        f.write(file)
      end
    end
  end
end

def save_fake_file
  if not params[:file].nil?
    filename = 'FAKE_' + params[:file][:filename].gsub(' ', '')
    if nil_or_empty?(params[:isImage])
      path = 'files'
    else
      path = 'img'
    end
    file = params[:file][:tempfile]
    File.open("./responses/#{path}/#{filename}", 'wb') do |f|
      f.write(file.read)
    end
  end
end

def set_config_from_template
  system ("cp './responses/templates/#{params[:filename]}' './responses/responses.json'")
end

def del_config_from_template
  system ("rm './responses/templates/#{params[:filename]}'")
end

def save_as_template
  name = params[:filename]
  system ("cp './responses/responses.json' './responses/templates/#{name}'")
end

def validate_json_reply
  alert = "Reply JSON is valid? = #{valid_json?(params[:jsonReply])}. "
  if (params[:replyType] == 'Merge json' || params[:replyType] == 'Delete json params')
    alert << "Pair for editing JSON is valid? = #{valid_json?(params[:jsonEditingPart])}"
  end
  alert
end

def reset_reply
  config_json = json_parser
  config_json['responseList'].clear
  write_to_responses(config_json)
end