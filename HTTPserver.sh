#!/usr/bin/bash

# Define the HTML body for the index page
index_body="<!DOCTYPE html><html><head></head><body><h1>Bash Commands in a Web Page</h1><h2>Click on me for greeting!</h2><form action=''><input type='submit' value='Click'></form></body></html>"

# Define the response for the health check page
health_body="Welcome to health check"

not_found_body="Page not found!"
while true; do
  #This line is used to capture an incoming HTTP request to a simple Bash HTTP server. It uses the nc (Netcat) command to listen for a connection on port 8080.
  #nc(Netcat) is a command-line utility that reads and writes data across network connections using the TCP or UDP protocols.
  #-l: This flag tells nc to listen for an incoming connection 
  #-q 1 means nc will wait 1 second after the client closes the connection before shutting down the server side of the connection. This ensures that the entire request is 
  #captured even if there are slight delays in network communication.
  request=$(nc -l -p 8080 -q 1)
  echo "Request is: $request"
  #head -n 1 takes the first line of the input. In the case of an HTTP request,this is the line that contains the method,path,and version.
  #For example, it extracts:GET /index HTTP/1.1
  #For the line GET /index HTTP/1.1, awk splits the line into fields:
  #$1: GET
  #$2: /index
  #$3: HTTP/1.1
  #awk '{print $2}' prints the second field, which is the requested path /index.
  request_path=$(echo "$request" | head -n 1 | awk '{print $2}')
  echo "Request path is: $request_path"
  # Check the request and respond accordingly
  if [[ $request_path == "/health" ]]; then
    # Respond with the health check page
    #The format HTTP/1.1 200 OK\nContent-Type: text/plain\n\n$health_body adheres to HTTP standards, ensuring compatibility with HTTP clients (such as web browsers or 
    #other HTTP-aware applications).
    #HTTP/1.1 specifies the version of the HTTP protocol.
    #200 is the status code, indicating that the request has succeeded.
    #OK is a textual description of the status code.
    response="HTTP/1.1 200 OK\nContent-Type: text/plain\n\n$health_body"
  elif [[ $request_path == "/index" ]]; then
    # Respond with the index page for any other request
    response="HTTP/1.1 200 OK\nContent-Type: text/html\n\n$index_body"
  else
   response="HTTP/1.1 404 Not Found\nContent-Type: text/html\n\n$not_found_body"
  fi

  # Send the response
  #Use echo -e "$response" to generate the HTTP response.
  #Pass this response to nc via the pipe operator.
  #nc listens on port 8080 for an incoming connection.
  #When a client connects, nc sends the response (received from echo) to the client.
  #After sending the response, nc waits 1 second before closing the connection, ensuring that the client has received the entire message.
  echo -e "$response" | nc -l -p 8080 -q 1
done
