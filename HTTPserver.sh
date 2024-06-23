#!/usr/bin/bash

# Define the HTML body for the index page
index_body="<!DOCTYPE html><html><head></head><body><h1>Bash Commands in a Web Page</h1><h2>Click on me for greeting!</h2><form action=''><input type='submit' value='Click'></form></body></html>"

# Define the response for the health check page
health_body="Welcome to health check"

not_found_body="Page not found!"
while true; do
  # Listen for incoming connections and capture the request
  request=$(nc -l -p 8080 -q 1)
  echo "Request is: $request"
  # Extract the requested path
  request_path=$(echo "$request" | head -n 1 | awk '{print $2}')
  echo "Request path is: $request_path"
  # Check the request and respond accordingly
  if [[ $request_path == "/health" ]]; then
    # Respond with the health check page
    response="HTTP/1.1 200 OK\nContent-Type: text/plain\n\n$health_body"
  elif [[ $request_path == "/index" ]]; then
    # Respond with the index page for any other request
    response="HTTP/1.1 200 OK\nContent-Type: text/html\n\n$index_body"
  else
   response="HTTP/1.1 404 Not Found\nContent-Type: text/html\n\n$not_found_body"
  fi

  # Send the response
  echo -e "$response" | nc -l -p 8080 -q 1
done
