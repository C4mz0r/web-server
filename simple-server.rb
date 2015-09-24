require 'socket'
require 'colorize'
require 'json'
CRLF = "\r\n"

# Parse the request line into a hash containing
# :method -> GET, POST
# :uri	-> Will assume that path is not nested (e.g. can have /index.html, but not /my_dir/index.html)
# :http_version -> e.g. HTTP/x.x
#  Returns hash or exception if error is found
def parse_request(request_line)
	parsed_request = {}
	matches = request_line.match(/(GET|POST)\s(.*)\s(HTTP\/\d\.\d)/)
	raise "Error with input string" if matches.nil?
	
	puts "#{matches}"

	parsed_request[:method] = matches[1]
	if (matches[2].include?"jpg" or matches[2].include?"jpeg")	
		parsed_request[:uri] = matches[2].match(/[[:alnum:]]+\/[[:alnum:]]+\.(jpg|jpeg)/)[0]
	else
		parsed_request[:uri] = matches[2].match(/[[:alnum:]]+\.(html|htm|jpg|jpeg)/)[0]
	end
	parsed_request[:http_version] = matches[3]

	puts "#{parsed_request[:method]}".colorize(:green)
	puts "#{parsed_request[:uri]}".colorize(:green)
	puts "#{parsed_request[:http_version]}".colorize(:green)
	puts "#{parsed_request.inspect}".colorize(:yellow)
	parsed_request
end

# Respond to a request
# Returns the response
def respond_to_request(request, body = "")

	response = ""
	parsed_request = parse_request(request)
	
	if parsed_request[:method] == "GET"
		if File.exist?(parsed_request[:uri])
			if ( parsed_request[:uri] == "picture.html" )
				puts "HERE".colorize(:red)
				body = read_file(parsed_request[:uri])
				image = select_random_image("images") # I'm calling my folder images
				image_str = "<img src=images/#{image}>"
				body.gsub!("<%= yield %>", image_str)
			else # the old get request of the file directly
				body = read_file(parsed_request[:uri])
			end
			response += "HTTP/1.0 200 OK" + CRLF
			if (parsed_request[:uri].include?(".jpg") )
				response += "Content-Type: image/gif"
			else
				response += "Content-Type: text/html" + CRLF
			end
			response += "Content-Length: #{body.length}" + CRLF
			response += CRLF # HTTP convention is a blank line between headers and body
			response += body			
		else
			puts "Requested content #{parsed_request[:uri]} does not exist"
			response += "HTTP/1.0 404 Not Found"
		end
	elsif parsed_request[:method] == "POST"	
		params = JSON.parse(body)
					
		replacement_html = "<li>#{params['viking']['name']}</li><li>#{params['viking']['email']}</li>"	
		
		content = read_file('thanks.html') 
		content.gsub!("<%= yield %>", replacement_html) # surely this can't be the right way...
		
		response = "HTTP/1.0 200 OK" + CRLF
		response += "Date: #{Time.new.ctime}" + CRLF
		response += "Content-Length: #{content.length}" + CRLF
		response += CRLF
		response += content
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

def select_random_image(folder)
	Dir.entries(folder).select {|f| !File.directory? f}.sample
end

server = TCPServer.open(2000)					# listen on port 2000 for client to connect
loop do
	client = server.accept					# wait for a client to connect
	request = ""
	while ( line = client.gets  )		
		request += line
		if request =~ /#{CRLF}#{CRLF}$/ 
			break
		end
	end
	
	# check for content length and get body
	md = request.match(/Content-Length: (\d+)/)
	content_length = md[1] if !md.nil?
	body = ""
	body = client.gets if !content_length.nil?	
	request += body

	puts "The request is #{request}".colorize(:blue)	# print it out for debugging purposes...

	response = respond_to_request(request, body)		# parse out the request and respond to it (body is optional)
	client.puts response
	client.close
end


