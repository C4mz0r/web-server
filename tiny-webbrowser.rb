require 'socket'
require 'colorize'

host = 'localhost'
port = 2000
path = "/index.html"

request = "GET #{path} HTTP/1.0\r\n\r\n"

socket = TCPSocket.open(host, port)		# connect to the server
socket.print(request)				# send request to the server	
response = socket.read				# read the response from the server

puts "Received response of :"
puts "#{response}".colorize(:green)

socket.close
