#!/bin/bash

is_valid_port() {
  local port=$1
  if [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -ge 1 ] && [ "$port" -le 65535 ]; then
    return 0  
  else
    return 1  
  fi
}

read_env_value() {
  local file=$1
  local key=$2
  if [ -f "$file" ]; then
    value=$(awk -F= -v key="$key" '$1 == key {print $2}' "$file" | tr -d '\r')
    echo "$value"
  else
    echo ""
  fi
}

write_to_env() {
  local file=$1
  local key=$2
  local value=$3

  if [ ! -f "$file" ]; then
    touch "$file"
  fi

  if [ ! -w "$file" ]; then
    echo "❌ Error: No write permission for $file. Please check permissions and try again."
    exit 1
  fi

  if grep -q "^$key=" "$file"; then
    sed -i "s|^$key=.*|$key=$value|" "$file"
  else
    echo "$key=$value" >> "$file"
  fi
}

server_env="server/.env"
client_env="client/.env"

# Ensure directories exist
mkdir -p server client

# Get client port first
clientPort=$(read_env_value "$client_env" "PORT")

if [ -z "$clientPort" ]; then
  while true; do
    echo ""
    read -p "Enter port number (1-65535) for the client (default: 3001): " clientPort
    clientPort=${clientPort:-3001}

    if is_valid_port "$clientPort"; then
      echo "✅ Client port set to $clientPort."
      write_to_env "$client_env" "PORT" "$clientPort"
      break 
    else
      echo "❌ Invalid port. Please enter a number between 1 and 65535."
    fi
  done
else
  echo "✅ Client port already set to $clientPort in $client_env."
fi

# Now ask for server port
serverPort=$(read_env_value "$server_env" "PORT")

if [ -z "$serverPort" ]; then
  while true; do
    echo ""
    read -p "Enter port number (1-65535) for the server (default: 3000): " serverPort
    serverPort=${serverPort:-3000}

    if is_valid_port "$serverPort"; then
      if [ "$clientPort" -eq "$serverPort" ]; then
        echo "❌ Server port $serverPort cannot be the same as client port $clientPort. Enter a different port."
        continue 
      fi
      echo "✅ Server port set to $serverPort."
      write_to_env "$server_env" "PORT" "$serverPort"
      break 
    else
      echo "❌ Invalid port. Please enter a number between 1 and 65535."
    fi
  done
else
  echo "✅ Server port already set to $serverPort in $server_env."
fi
echo ""

# Read existing database credentials
dbUser=$(read_env_value "$server_env" "USER_NAME")
dbPassword=$(read_env_value "$server_env" "USER_PASSWORD")
dbPort=$(read_env_value "$server_env" "DATABASE_PORT")

# Prompt for database credentials only if they are not set
if [ -z "$dbUser" ]; then
  read -p "Enter database username (default: admin): " dbUser
  dbUser=${dbUser:-admin}
  write_to_env "$server_env" "USER_NAME" "$dbUser"
  echo "✅ Database username set to $dbUser."
else
  echo "✅ Database username already set in $server_env."
fi
echo ""
if [ -z "$dbPassword" ]; then
  echo -n "Enter database password (default: password): "
  read -s dbPassword
  echo ""
  dbPassword=${dbPassword:-password}
  write_to_env "$server_env" "USER_PASSWORD" "$dbPassword"
  echo "✅ Database password set."
else
  echo "✅ Database password already set in $server_env."
fi
echo ""
if [ -z "$dbPort" ]; then
  read -p "Enter database port (default: 3002): " dbPort
  dbPort=${dbPort:-3002}
  write_to_env "$server_env" "DATABASE_PORT" "$dbPort"
  echo "✅ Database port set to $dbPort."
else
  echo "✅ Database port already set in $server_env."
fi
echo ""
echo "✅ Database configuration saved in $server_env."
echo ""

read -p "Would you like to install the dependencies for the server and client? (y/n) (default: n): " installDeps
if [[ "$installDeps" =~ ^[Yy]$ ]]; then
  echo ""
  echo "📦 Installing dependencies for the server..."
  npm install --prefix ./server

  echo ""
  echo "📦 Installing dependencies for the client..."
  npm install --prefix ./client
  echo ""
  echo "✅ Dependencies installed."
else
  echo "⏭ Skipping dependency installation."
fi

echo ""
echo "✅ Setup complete. You can now start the server and client"