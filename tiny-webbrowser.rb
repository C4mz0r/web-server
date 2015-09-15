require 'socket'
require 'colorize'
require 'json'

CRLF = "\r\n"

host = 'localhost'
port = 2000
path = "/index.html"

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

	puts "What type of request would you like to send?\r\n[GET/BAD-GET/PUT/q (to quit)] "
	command = gets.chomp 	

	case command
		when 'q' then break

		when 'GET' then 
			request = "GET #{path} HTTP/1.0" + CRLF
			request += "From:  C4mz0r@nowhere.com" + CRLF
			request += CRLF
			communicate(host, port, request)
		when 'BAD-GET' then
			request = "GET /some_non_existant_file.html HTTP/1.0" + CRLF + CRLF
			communicate(host, port, request)
		when 'PUT' then 
			puts "Enter your name, Viking:"
			name = gets.chomp
			puts "Enter your email, Viking:"
			email = gets.chomp

			submission_data = { :viking => {:name => name, :email => email } }.to_json
			
			request = ""
			request += "POST /thanks.html HTTP/1.0" + CRLF
			request += "From:  C4mz0r@nowhere.com" + CRLF
			request += "User-Agent: TinyWebBrowser/1.0" + CRLF
			request += "Content-Length: #{submission_data.length}" + CRLF
			request += CRLF
			request += submission_data + CRLF
						
			communicate(host, port, request)
		else
			puts "Sorry, I don't understand how to #{command}"
	end

end




