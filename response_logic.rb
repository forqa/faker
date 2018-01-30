require_relative 'params_manager'

def get_config_templates
  templates = `ls -C './responses/templates/'`.split
end

def size_include_params_request_query(config_query)
	request_params = params
	request_params.delete("captures")
	request_params.delete("splat")
	if nil_or_empty?(config_query)
		return 0
	else
		if request_params.empty?
			request_params_size = 0
		else
			request_params_size = request_params.size
		end
		json_config_query = convert_string_query_to_json(config_query)
		difference_size = request_params_size - json_config_query.size
		size_array_include = (request_params.to_a - json_config_query.to_a).size
		if (size_array_include == difference_size && difference_size >= 0)
			return request_params_size - difference_size
		else
			return -1
		end
	end
end

def convert_string_query_to_json(string_query)
  if string_query.include?('&')
    string_query.gsub!('&', '","')
  end
  string_format_for_convert = '{"' + string_query.gsub!('=', '":"') + '"}'
  json_config_query = JSON.parse(string_format_for_convert)
end

def get_index_fake_responce
	@query_array = [[-1, -1]]
	if @config_json['responseList'].any?
		@config_json['responseList'].each.with_index do |value, i|
			@include_params = size_include_params_request_query(value['query'])
			if (value['path'] == @path && @include_params != -1)
				if (@query_array[@query_array.size - 1][1] < @include_params)
					@query_array[@query_array.size - 1] = [i, @include_params]
				elsif (@query_array[@query_array.size - 1][1] == @include_params)
					(@query_array[@query_array.size] = [i, @include_params])
				end
			end
		end
	end
	@query_array.sample[0]
end

def response_if_no_reply_config
	delay(@config_json['globalDelayFrom'], @config_json['globalDelayTo'], "#{@path}?#{@string_param}")
	if (!nil_or_empty?(@images_name) && @images_name.include?('FAKE_'))
		puts "FAKE IMAGE".colorize(:green)
		send_file "./responses/img/#{@images_name}"
	else
		resp = curl("#{@config_json['serverAddress']}/#{@path}?#{@string_param}")
		log_original_resp(resp)
		return resp
	end
end

def get_response
	accumulateDelay 						#accumulation delay monitor
	@path = request.path.gsub(/^\//, '')
	@request_query = params.delete("captures").delete("splat")
	@string_param = request.query_string.gsub('%20', '+')
	@config_json = json_parser
	@images_name = params[:imageName].to_s
	@index =get_index_fake_responce
	if (@index.nil? || @index == -1)
		response_if_no_reply_config
	else
		delay_for_custom_reply
		content_type_for_custom_reply
		fake_error_for_custom_reply
		reply_type = type_custom_reply
		fake_image_reply
		case reply_type
		when 'Do not fake response'
			do_not_fake_response
		when 'Fake json'
			fake_json
		when 'Merge json'
			merge_json
		when 'As Is'
			as_is
		when 'Delete json params'
			delete_json_params
		end
	end
end

def delete_json_params
	json_before_redact_param =JSON.parse(curl ("#{@config_json['serverAddress']}/#{@path}?#{@string_param}"))
	redact_param = @config_json['responseList'][@index]['reply']
	find_editing_part = @config_json['responseList'][@index]['findEditingPart']
	if find_editing_part.any?
		puts "DELETE PARAMS #{redact_param} IF JSON INCLUDE #{find_editing_part}".colorize(:yellow)
		resp = json_editor(json_before_redact_param, find_editing_part, redact_param, 'delete').to_json
	else
		puts "DELETE PARAMS #{redact_param}".colorize(:yellow)
		resp = delete_pair_from_json(json_before_redact_param, redact_param).to_json
	end
	puts "JSON AFTER DELETING PARAMS #{resp}".colorize(:green)
	return resp
end

def merge_json
	json_before_redact_param =JSON.parse(curl ("#{@config_json['serverAddress']}/#{@path}?#{@string_param}"))
	redact_param = @config_json['responseList'][@index]['reply']
	find_editing_part = @config_json['responseList'][@index]['findEditingPart']
	if find_editing_part.any?
		puts "MERGE WITH #{redact_param}".colorize(:yellow)
		puts "IF JSON INCLUDE PART #{find_editing_part}".colorize(:red)
		resp = json_editor(json_before_redact_param, find_editing_part, redact_param, 'merge').to_json
	else
		puts "MERGE WITH JSON #{redact_param}".colorize(:yellow)
		resp = json_before_redact_param.deep_merge(redact_param).to_json
	end
	puts "MODIFIED JSON #{resp}".colorize(:green)
	return resp
end

def json_editor(source_json, source_object, new_object, action)
	if is_array?(source_json)
	  source_json.each do |json|
		json_editor(json, source_object, new_object, action)
	  end
	elsif is_hash?(source_json)
	  if json_contains_pair?(source_json, source_object)
		case action
		  when 'merge'
			source_json.merge!(new_object)
		  when 'delete'
			delete_pair_from_json(source_json, new_object)
		  end
	  else
		source_json.each_value do |json|
		  json_editor(json, source_object, new_object, action)
		end
	  end
	end
  end
  
  def json_contains_pair?(hash_in_which_pair, hash_pair)
	size_before_diff = hash_in_which_pair.size
	size_after_diff = (hash_in_which_pair.to_a - hash_pair.to_a).size	
	size_before_diff != size_after_diff && hash_pair.size == (size_before_diff - size_after_diff)
  end
  
  def is_array?(val)
	val.kind_of?(Array)
  end
  
  def is_hash?(val)
	val.is_a?(Hash)
  end
  
  def delete_pair_from_json(from, what)
	if json_contains_pair?(from, what)
	  what.each_key do |key|
		from.delete(key)
	  end
	end
  end

def do_not_fake_response
	resp = curl ("#{@config_json['serverAddress']}/#{@path}?#{@string_param}")
	log_original_resp(resp)
	return resp
end

def fake_json
	send_request = @config_json['responseList'][@index]['dontSendRequest']
	if not (send_request.nil?)
		curl ("#{@config_json['serverAddress']}/#{@path}?#{@string_param}")
	end
	resp = @config_json['responseList'][@index]['reply'].to_json
	puts "FAKE JSON #{resp}".colorize(:green)
	return resp
end

def as_is
	send_request = @config_json['responseList'][@index]['dontSendRequest']
	if not (send_request.nil?)
		curl ("#{@config_json['serverAddress']}/#{@path}?#{@string_param}")
	end
	resp = @config_json['responseList'][@index]['reply']
	puts "FAKE JSON #{resp}".colorize(:green)
	return resp
end

def delay_for_custom_reply
	custom_delay_from = @config_json['responseList'][@index]['customDelayFrom']
	custom_delay_to = @config_json['responseList'][@index]['customDelayTo']
	accamulate = @config_json['responseList'][@index]['accumulationDelay']
	if not (nil_or_empty?(custom_delay_from) || nil_or_empty?(custom_delay_to))
		if not nil_or_empty?(accamulate)
			startAccumulateDelay(custom_delay_from, custom_delay_to, "#{@path}?#{@string_param}")
		else
			delay(custom_delay_from, custom_delay_to, "#{@path}?#{@string_param}")
		end
	else
		delay(@config_json['globalDelayFrom'], @config_json['globalDelayTo'], "#{@path}?#{@string_param}")
	end
end
  
def content_type_for_custom_reply
	custom_content_type = @config_json['responseList'][@index]['customContentType']
	content_type = @config_json['responseList'][@index]['contentType']
	if not nil_or_empty?(content_type)
		puts "FAKE CONTENT_TYPE #{content_type}".colorize(:yellow)
		content_type content_type
	end
	if not nil_or_empty?(custom_content_type)
		puts "FAKE CONTENT_TYPE #{custom_content_type}".colorize(:yellow)
		content_type custom_content_type
	end
end
  
def fake_error_for_custom_reply
	http_code = @config_json['responseList'][@index]['httpCode']
	if not nil_or_empty?(http_code)
		puts "FAKE HTTP STATUS #{status} FOR #{@path}?#{@string_param}".colorize(:green)
		status http_code.to_i
	end
end

def type_custom_reply
	reply_type = @config_json['responseList'][@index]['replyType']
	puts "REPLY TYPE: #{reply_type}".colorize(:green)
	reply_type
end

def fake_image_reply
	if @images_name.include?('FAKE_')
		puts "FAKE IMAGE, REPLY TYPE IS IGNORE".colorize(:green)
		return send_file "./responses/img/#{@images_name}"
	end
end
  
def curl(url)
	http = Curl.get(url) do |http|
		cook = request.cookies.to_s.gsub!(/[\/\"\>\"\{\}]/, '')
		http.headers['Cookie'] = "#{cook}"
	end
	@body_str = http.body_str
	http_response, *http_headers = http.header_str.split(/[\r\n]+/).map(&:strip)
	http_headers = Hash[http_headers.flat_map{ |s| s.scan(/^(\S+): (.+)/) }]
	headers http_headers
	headers['Transfer-Encoding'] = ''
	status http.status
	if not headers['Content-Type'].to_s.include?('image')
		puts "FROM SERVER: #{@body_str}".colorize(:blue)
		puts "HEADERS: #{headers}".colorize(:green)
	end
	@body_str
end
  
def json_parser
	file = File.read(File.dirname(__FILE__) + $responses_path)
	JSON.parse(file)
end

def write_to_responses(json_form)
	File.write(File.dirname(__FILE__) + $responses_path, JSON.dump(json_form))
end

def json_response
	File.open(File.dirname(__FILE__) + $responses_path, 'rb').read
end
  
def startAccumulateDelay(delayFrom, delayTo, reply)
	rnd = Random.new
	sec = rnd.rand(delayFrom.to_i..delayTo.to_i)
	puts "START ACCUMULATE DELAY #{sec} BY #{reply}".colorize(:yellow)
	$waitTime = Time.now + sec
end
  
def accumulateDelay
	unless $waitTime.nil?
		while Time.now < $waitTime do
			sec = Time.now - $waitTime
			puts "ACCUMULATE DELAY #{sec}".colorize(:yellow)
			sleep 1
		end
	end
end
  
def delay(delayFrom, delayTo, reply)
    unless (nil_or_empty?(delayFrom) || nil_or_empty?(delayTo))
      rnd = Random.new
      sec = rnd.rand(delayFrom.to_i..delayTo.to_i)
      puts "SLEEP #{sec} FOR #{reply}".colorize(:yellow)
      sleep sec
    end
end

def valid_json?(json)
    JSON.parse(json)
    return true
  rescue JSON::ParserError => e
    return false
end

def nil_or_empty?(obj)
  if (obj.nil? || obj == '')
    return true
  else
    return false
  end
end

def log_original_resp(resp)
  if not headers['Content-Type'].to_s.include?('image')
      puts "ORIGINAL #{resp}".colorize(:green)
  end
end

def reset_config
  system ("cp './responses/responsesTemplate.json' './responses/responses.json'")
end

def get_config_json
	@configure = JSON.pretty_generate(json_parser)
	if (@configure.size > 20000)
		'File is very big. Download the file for editing'
	else
		@configure
	end
end