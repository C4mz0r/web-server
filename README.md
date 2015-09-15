# web-server
Implement a simple webserver / client
Then write a "web browser" client which can send GET or POST requests to the simple server
Simple server simulates GET and POST

Examples:

To start the webserver:
	ruby simple-server.rb 

To start the browser:
	ruby tiny-webbrowser.rb

In the browser, you can type: GET, BAD-GET, or PUT.
	GET simulates asking the server for a file.  Server will open the file from disk and return the contents to browser.
	BAD-GET simulates asking the server for a file that does not exist.  Server will return 404 error to browser.
	PUT simulates sending a POST to a form with data (e.g. name/email).  Server will open the template file from disk, and return the contents to the browser with the user's details filled in.
