#!/bin/bash

# Function to validate a port number
is_valid_port() {
  local port=$1
  if [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -ge 1 ] && [ "$port" -le 65535 ]; then
    return 0  
  else
    return 1  
  fi
}

# Function to read a value from an .env file
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

# Function to write or update a value in an .env file
write_to_env() {
  local file=$1
  local key=$2
  local value=$3
  local file_updated_var=$4
  local hide_value=$5  # New parameter to control visibility

  if [ ! -f "$file" ]; then
    touch "$file"
  fi

  if [ ! -w "$file" ]; then
    echo "❌ Error: No write permission for $file. Please check permissions and try again."
    exit 1
  fi

  if grep -q "^$key=" "$file"; then
    current_value=$(awk -F= -v key="$key" '$1 == key {print $2}' "$file" | tr -d '\r')
    if [ "$current_value" == "$value" ]; then
      return # No update needed
    fi
    # Update existing value (cross-platform sed)
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s|^$key=.*|$key=$value|" "$file"
    else
      sed -i "s|^$key=.*|$key=$value|" "$file"
    fi
  else
    echo "$key=$value" >> "$file"
  fi

  eval "$file_updated_var=true"

  # Avoid printing the actual value if hide_value is set
  if [ "$hide_value" = "true" ]; then
    echo "✅ Saved '$key' to $file."
  else
    echo "✅ Saved '$key=$value' to $file."
  fi
}


# Define environment files
server_env="server/.env"
client_env="client/.env"

# Track changes per file
server_env_updated=false
client_env_updated=false

### Step 1: Get Client Port ###  
echo ""
clientPort=$(read_env_value "$client_env" "PORT")
if [ -n "$clientPort" ]; then
  echo "ℹ️  Client port $clientPort already set in $client_env. Skipping input."
  echo ""
else
  while [ -z "$clientPort" ]; do
    read -p "Enter port number (1-65535) for the client (default: 3000): " clientPort
    clientPort=${clientPort:-3000}
    if is_valid_port "$clientPort"; then
      write_to_env "$client_env" "PORT" "$clientPort" "client_env_updated"
  echo ""
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
  echo ""
else
  while [ -z "$serverPort" ]; do
    read -p "Enter port number (1-65535) for the server (default: 3001): " serverPort

    serverPort=${serverPort:-3001}

    if is_valid_port "$serverPort" && [ "$serverPort" -ne "$clientPort" ]; then
      write_to_env "$server_env" "PORT" "$serverPort" "server_env_updated"
  echo ""
    else
      echo "❌ Invalid port or matches client port ($clientPort). Please enter a different port."
  echo ""
      serverPort=""
    fi
  done
fi

### Step 3: Get Database Port ###
dbPort=$(read_env_value "$server_env" "DATABASE_PORT")
if [ -n "$dbPort" ]; then
  echo "ℹ️  Database port $dbPort already set in $server_env. Skipping input."
  echo ""
else
  while [ -z "$dbPort" ]; do
    read -p "Enter database port (1-65535, default: 3002): " dbPort

    dbPort=${dbPort:-3002}

    if is_valid_port "$dbPort" && [ "$dbPort" -ne "$clientPort" ] && [ "$dbPort" -ne "$serverPort" ]; then
      write_to_env "$server_env" "DATABASE_PORT" "$dbPort" "server_env_updated"
  echo ""
    else
      echo "❌ Invalid port or matches client/server port. Please enter a different port."
  echo ""
      dbPort=""
    fi
  done
fi

### Step 4: Get Database Username ###
dbUser=$(read_env_value "$server_env" "USER_NAME")
if [ -n "$dbUser" ]; then
  echo "ℹ️  Database username already set in $server_env. Skipping input."
  echo ""
else
  while [ -z "$dbUser" ]; do
    read -p "Enter database username (default: admin): " dbUser

    dbUser=${dbUser:-admin}

    if [ -n "$dbUser" ]; then
      write_to_env "$server_env" "USER_NAME" "$dbUser" "server_env_updated"
  echo ""
    else
      echo "❌ Username cannot be empty. Please enter a valid username."
  echo ""
    fi
  done
fi

### Step 5: Get Database Password ###
dbPassword=$(read_env_value "$server_env" "USER_PASSWORD")
if [ -n "$dbPassword" ]; then
  echo "ℹ️  Database password already set in $server_env. Skipping input."
  echo ""
else
  while [ -z "$dbPassword" ]; do
    read -s -p "Enter database password (default: password): " dbPassword
    echo ""  
    dbPassword=${dbPassword:-password}

    if [ -n "$dbPassword" ]; then
      write_to_env "$server_env" "USER_PASSWORD" "$dbPassword" "server_env_updated" "true"
      echo ""
    else
      echo "❌ Password cannot be empty. Please enter a valid password."
      echo ""
    fi
  done
fi

# Display which files were updated

if [ "$server_env_updated" = true ] || [ "$client_env_updated" = true ]; then
  echo "✅ Configuration updated successfully in:"
  [ "$server_env_updated" = true ] && echo "   - $server_env"
  [ "$client_env_updated" = true ] && echo "   - $client_env"
else
  echo "ℹ️  No changes were made to the configuration files."
fi
  echo ""

### Install Dependencies ###
read -p "Would you like to install the dependencies for the server and client? (y/n) (default: y): " installDeps
installDeps=${installDeps:-y}
if [[ "$installDeps" =~ ^[Yy]$ ]]; then
  echo ""
  echo "📦 Installing dependencies for the server..."
  npm install --prefix ./server && npm audit fix --prefix ./server

  echo ""
  echo "📦 Installing dependencies for the client..."
  npm install --prefix ./client && npm audit fix --prefix ./client

  echo ""
  echo "✅ Dependencies installed and security fixes applied."
else
  echo "⏭ Skipping dependency installation."
fi

echo ""
echo "✅ Setup complete. You can now start the server and client."
