#!/bin/bash

is_valid_port() {
  local port=$1
  if [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -ge 1 ] && [ "$port" -le 65535 ]; then
    return 0  
  else
    return 1  
  fi
}

read_port_from_env() {
  local file=$1
  if [ -f "$file" ]; then
    port=$(grep -E "^PORT=" "$file" | cut -d'=' -f2)
    echo "$port"
  else
    echo ""  
  fi
}

serverPort=$(read_port_from_env "server/.env")

if [ -z "$serverPort" ]; then
  while true; do
    echo ""
    read -p "Enter port number (1-65535) for the server: " serverPort

    if is_valid_port "$serverPort"; then
      echo "Port: $serverPort is valid."
      echo "Setting the server port in the .env file to: $serverPort..."
      echo "PORT=$serverPort" | sudo tee server/.env > /dev/null  
      break 
    else
      echo "Port: $serverPort is invalid. Please enter a valid port number between 1 and 65535."
    fi
  done
else
  echo "Server port already set to $serverPort in the .env file."
fi

clientPort=$(read_port_from_env "client/.env")

if [ -z "$clientPort" ]; then
  while true; do
    echo ""
    read -p "Enter port number (1-65535) for the client: " clientPort

    if is_valid_port "$clientPort"; then
      if [ "$clientPort" -eq "$serverPort" ]; then
        echo "The client port: $clientPort is the same as the server port: $serverPort. Please enter a different port number."
        continue 
      fi
      echo "Port: $clientPort is valid."
      echo "Setting the client port in the .env file to: $clientPort..."
      echo "PORT=$clientPort" | sudo tee client/.env > /dev/null  
      break 
    else
      echo "Port: $clientPort is invalid. Please enter a valid port number between 1 and 65535."
    fi
  done
else
  echo "Client port already set to $clientPort in the .env file."
fi

read -p "Would you like to install the dependencies for the server and client? (y/n): " installDeps
if [ "$installDeps" == "y" ]; then
  echo ""
  echo "Running npm install for the server..."
  npm install --prefix ./server

  echo ""
  echo "Running npm install for the client..."
  npm install --prefix ./client
else
  echo "Skipping npm install for the server and client."
fi
