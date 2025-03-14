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
  if [ -f "$file" ] && [ -s "$file" ]; then
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
  echo "✅ Saved '$key=$value' to $file."
}

server_env="server/.env"
client_env="client/.env"

# Ensure directories exist
mkdir -p server client

### Step 1: Get Client Port ###
clientPort=$(read_env_value "$client_env" "PORT")
if [ -n "$clientPort" ]; then
  echo "ℹ️  Client port $clientPort already set in $client_env. Skipping input."
else
  while [ -z "$clientPort" ]; do
    echo ""
    read -p "Enter port number (1-65535) for the client (default: 3001): " clientPort
    clientPort=${clientPort:-3001}

    if is_valid_port "$clientPort"; then
      write_to_env "$client_env" "PORT" "$clientPort"
    else
      echo "❌ Invalid port. Please enter a number between 1 and 65535."
      clientPort=""
    fi
  done
fi

### Step 2: Get Server Port ###
serverPort=$(read_env_value "$server_env" "PORT")
if [ -n "$serverPort" ]; then
  echo "ℹ️  Server port $serverPort already set in $server_env. Skipping input."
else
  while [ -z "$serverPort" ]; do
    echo ""
    read -p "Enter port number (1-65535) for the server (default: 3000): " serverPort
    serverPort=${serverPort:-3000}

    if is_valid_port "$serverPort" && [ "$serverPort" -ne "$clientPort" ]; then
      write_to_env "$server_env" "PORT" "$serverPort"
    else
      echo "❌ Invalid port or matches client port ($clientPort). Please enter a different port."
      serverPort=""
    fi
  done
fi

### Step 3: Get Database Port ###
dbPort=$(read_env_value "$server_env" "DATABASE_PORT")
if [ -n "$dbPort" ]; then
  echo "ℹ️  Database port $dbPort already set in $server_env. Skipping input."
else
  while [ -z "$dbPort" ]; do
    echo ""
    read -p "Enter database port (1-65535, default: 3002): " dbPort
    dbPort=${dbPort:-3002}

    if is_valid_port "$dbPort" && [ "$dbPort" -ne "$clientPort" ] && [ "$dbPort" -ne "$serverPort" ]; then
      write_to_env "$server_env" "DATABASE_PORT" "$dbPort"
    else
      echo "❌ Invalid port or matches client/server port. Please enter a different port."
      dbPort=""
    fi
  done
fi

### Step 4: Get Database Username ###
dbUser=$(read_env_value "$server_env" "USER_NAME")
if [ -n "$dbUser" ]; then
  echo "ℹ️  Database username already set in $server_env. Skipping input."
else
  while [ -z "$dbUser" ]; do
    echo ""
    read -p "Enter database username (default: admin): " dbUser
    dbUser=${dbUser:-admin}

    if [ -n "$dbUser" ]; then
      write_to_env "$server_env" "USER_NAME" "$dbUser"
    else
      echo "❌ Username cannot be empty. Please enter a valid username."
    fi
  done
fi

### Step 5: Get Database Password ###
dbPassword=$(read_env_value "$server_env" "USER_PASSWORD")
if [ -n "$dbPassword" ]; then
  echo "ℹ️  Database password already set in $server_env. Skipping input."
else
  while [ -z "$dbPassword" ]; do
    echo ""
    read -s -p "Enter database password (default: password): " dbPassword
    echo ""
    dbPassword=${dbPassword:-password}

    if [ -n "$dbPassword" ]; then
      write_to_env "$server_env" "USER_PASSWORD" "$dbPassword"
    else
      echo "❌ Password cannot be empty. Please enter a valid password."
    fi
  done
fi

echo ""
echo "✅ Configuration saved in $server_env and $client_env."
echo ""

### Install Dependencies ###
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
echo "✅ Setup complete. You can now start the server and client."
