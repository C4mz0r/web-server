require 'socket'
require 'colorize'
require 'json'

# Parse the request line into a hash containing
# :method -> GET, POST
# :uri	-> Will assume that path is not nested (e.g. can have /index.html, but not /my_dir/index.html)
# :http_version -> e.g. HTTP/x.x
#  Returns hash or exception if error is found
def parse_request(request_line)
	parsed_request = {}
	#puts "The request_line is #{request_line}"
	matches = request_line.match(/(GET|POST)\s(.*)\s(HTTP\/\d\.\d)/)
	raise "Error with input string" if matches.nil?
	
	#puts "matches is #{matches}.inspect"
	parsed_request[:method] = matches[1]
	parsed_request[:uri] = matches[2].match(/[[:alnum:]]+\.(html|htm)/)[0]
	parsed_request[:http_version] = matches[3]
	
	parsed_request
end

# Respond to a request
# Returns hash with the [:response_line], and [:content], if available
def respond_to_request(request)

	response = {}
	parsed_request = parse_request(request)
	#puts "parsed_request is " + parsed_request.inspect
	
	if parsed_request[:method] == "GET"
		if File.exist?(parsed_request[:uri])
			response[:content] = read_file(parsed_request[:uri])
			response[:response_line] = "HTTP/1.0 200 OK"
			response[:header] =  "Date: #{Time.new.ctime}\n"
			response[:header] += "Content-Type: text/html\n"
			response[:header] += "Content-Length: #{response[:content].length}\n"
		else
			puts "Requested content #{parsed_request[:uri]} does not exist"
			response[:response_line] = "HTTP/1.0 404 Not Found"
		end
	elsif parsed_request[:method] == "POST"
		
		data = JSON.parse(request)		
		params = JSON.parse( data['post_data'] )		
		replacement_html = "<li>#{params['viking']['name']}</li><li>#{params['viking']['email']}</li>"	
		
		content = read_file('thanks.html') 
		content.gsub!("<%= yield %>", replacement_html) # surely this can't be the right way...
		
		response[:content] = content
		response[:response_line] = "HTTP/1.0 200 OK"
		response[:header] =  "Date: #{Time.new.ctime}\n"
		response[:header] += "Content-Type: text/html\n"
		response[:header] += "Content-Length: #{response[:content].length}\n"
	else
		puts "Not sure how to deal with #{parsed_request[:method]}"
	end
	response
end

# Reads a file into a variable for return to requestor
def read_file(item)
	puts "Trying to return #{item} to requestor"
	content = ""
	File.open(item, "r") do |f|
		f.each_line do |line|
			content += line
		end
	end
	content
end

server = TCPServer.open(2000)					# listen on port 2000 for client to connect
loop do
	client = server.accept					# wait for a client to connect
	
	#request = ""
	#while request == "" 
		request = client.gets					# receive the request from the client
		
		puts "The request is #{request}".colorize(:blue)	# print it out for debugging purposes...
	#end

	response = respond_to_request(request)			# parse out the request and respond to it
	
	client.puts(response[:response_line])
	client.puts(response[:header])
	client.puts(response[:content])				# give the client back the response

	client.close
end


