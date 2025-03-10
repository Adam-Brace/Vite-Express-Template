#!/bin/bash

#SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Function to check if port is valid
is_valid_port() {
  local port=$1
  if [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -ge 1 ] && [ "$port" -le 65535 ]; then
    return 0  # Valid port
  else
    return 1  # Invalid port
  fi
}

# Function to read port from the .env file
read_port_from_env() {
  local file=$1
  # Extract the PORT value from the .env file (if it exists)
  if [ -f "$file" ]; then
    port=$(grep -E "^PORT=" "$file" | cut -d'=' -f2)
    echo "$port"
  else
    echo ""  # Return an empty string if .env doesn't exist
  fi
}

# Check if the server port is already set in the .env file
serverPort=$(read_port_from_env "server/.env")

if [ -z "$serverPort" ]; then
  # Ask for server port if not set
  while true; do
    echo ""
    read -p "Enter port number (1-65535) for the server: " serverPort

    # Check if port is valid
    if is_valid_port "$serverPort"; then
      echo "Port: $serverPort is valid."
      echo "Setting the server port in the .env file to: $serverPort..."
      echo "PORT=$serverPort" | sudo tee server/.env > /dev/null  # Avoid extra output
      break  # Exit the loop if the port is valid
    else
      echo "Port: $serverPort is invalid. Please enter a valid port number between 1 and 65535."
    fi
  done
else
  echo "Server port already set to $serverPort in the .env file."
fi

# Check if the client port is already set in the .env file
clientPort=$(read_port_from_env "client/.env")

if [ -z "$clientPort" ]; then
  # Ask for client port if not set
  while true; do
    echo ""
    read -p "Enter port number (1-65535) for the client: " clientPort

    # Check if port is valid
    if is_valid_port "$clientPort"; then
      if [ "$clientPort" -eq "$serverPort" ]; then
        echo "The client port: $clientPort is the same as the server port: $serverPort. Please enter a different port number."
        continue  # Skip the rest of the loop and start from the beginning
      fi
      echo "Port: $clientPort is valid."
      echo "Setting the client port in the .env file to: $clientPort..."
      echo "PORT=$clientPort" | sudo tee client/.env > /dev/null  # Avoid extra output
      break  # Exit the loop if the port is valid
    else
      echo "Port: $clientPort is invalid. Please enter a valid port number between 1 and 65535."
    fi
  done
else
  echo "Client port already set to $clientPort in the .env file."
fi

read -p "Would you like to install the dependencies for the server and client? (y/n): " installDeps
if [ "$installDeps" == "y" ]; then
  # Running npm install for the server
  echo ""
  echo "Running npm install for the server..."
  npm install --prefix ./server

  # Running npm install for the client
  echo ""
  echo "Running npm install for the client..."
  npm install --prefix ./client
else
  echo "Skipping npm install for the server and client."
fi
