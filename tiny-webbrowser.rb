require 'socket'
require 'colorize'
require 'json'

host = 'localhost'
port = 2000
path = "/index.html"

request = "GET #{path} HTTP/1.0\r\n\r\n"

def communicate(host, port, request)

	socket = TCPSocket.open(host, port)		# connect to the server
	socket.print(request)				# send request to the server	
	response = socket.read				# read the response from the server

	puts "Received response of :"
	puts "#{response}".colorize(:green)
	
	socket.close
end


command = ""

while command != 'q'

	puts "What type of request would you like to send? [GET/PUT/q (to quit)] "
	command = gets.chomp 	

	case command
		when 'q' then break

		when 'GET' then 
			request = "GET #{path} HTTP/1.0\r\n"
			communicate(host, port, request)
		when 'PUT' then 
			puts "Enter your name, Viking:"
			name = gets.chomp
			puts "Enter your email, Viking:"
			email = gets.chomp
			
			data = {}
			data[:request_line] = "POST /thanks.html HTTP/1.0"
			data[:from] = "From:  C4mz0r@nowhere.com"
			data[:user_agent] = "User-Agent: TinyWebBrowser/1.0"
			data[:post_data] = { :viking => {:name => name, :email => email } }.to_json
			data[:content_length] = "Content-Length: #{data[:post_data].length}"
			request = data.to_json + "\r\n"

			communicate(host, port, request)
		else
			puts "Sorry, I don't understand how to #{command}"
	end

end




