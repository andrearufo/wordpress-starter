#!/bin/bash

# Let's start 🚀
echo "🚀 Let's start building with WordPress!"

# Check if Docker is running 🐳
if ! docker info >/dev/null 2>&1; then
  echo "🙈 Error: Docker is not running..." >&2
  exit 1
fi
echo "🐳 Docker is running! Proceeding..."

# Check if required commands are available 🔍
for cmd in docker composer yarn wget unzip; do
  if ! command -v $cmd &> /dev/null; then
    echo "❌ Error: $cmd is not installed. Please install it and try again."
    exit 1
  fi
done
echo "✅ All required commands are available."

# Check if project has already been initialized 🔒
if [ -f init.lock ]; then
  echo "🔒 Error: This project has already been initialized!" >&2
  exit 1
fi
echo "🔓 No initialization lock found. Continuing..."

# Confirm installation 🔍
read -p "🛠️ Are you sure you want to continue? (Y/n) " -n 1 -r
echo
if [[ -z "$REPLY" || "$REPLY" =~ ^[Yy]$ ]]; then
  echo "✅ Proceeding with initialization..."
else
  echo "❌ Initialization cancelled."
  exit 1
fi

# Check and copy the .env file if it doesn't exist 🗂️
if [ -f .env ]; then
  echo "ℹ️ .env file already exists. Skipping copy."
else
  if [ -f .env.example ]; then
    cp .env.example .env
    echo "✅ .env file created from .env.example."
  else
    echo "❌ Error: .env.example is missing. Please provide a .env file or an example file."
    exit 1
  fi
fi

# Load THEME_NAME from .env 🔍
THEME_NAME=$(grep -E "^THEME_NAME=" .env | cut -d '=' -f 2 | xargs)
if [ -z "$THEME_NAME" ]; then
  echo "❌ Error: THEME_NAME is not set in .env. Please configure it and try again."
  exit 1
fi
echo "🎨 Using theme: $THEME_NAME"

# Set permissions 🔒
chmod -R 777 ./_volumes
echo "✅ Permissions set for ./_volumes."

# Download and extract theme ZIP 📦
ZIP_URL=$(grep -E "^THEME_PACKAGE_URL=" .env | cut -d '=' -f 2 | xargs)
ZIP_FILE="theme.zip"
TEMP_DIR="bathe-main"

echo "📥 Downloading theme from $ZIP_URL..."
wget -O "$ZIP_FILE" "$ZIP_URL"

echo "📂 Extracting theme..."
unzip -q "$ZIP_FILE" -d .
if [ -d "$TEMP_DIR" ]; then
  echo "✅ Theme extracted to temporary directory: $TEMP_DIR"
else
  echo "❌ Error: Failed to extract theme."
  rm "$ZIP_FILE"
  exit 1
fi

# Move all files (including hidden) from temporary directory to root
echo "📂 Moving all theme files (including hidden files) to root directory..."
find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -exec mv -f {} . \;
rm -rf "$TEMP_DIR" "$ZIP_FILE"
echo "✅ Theme files moved to root directory."

# Start the containers 🛳️
docker compose build --no-cache --force-rm
docker compose up -d
echo "✅ Docker containers started successfully."

# Configure Git safe.directory in Docker 🐳
echo "📦 Configuring Git safe.directory in the container..."
docker compose exec web bash -c "
  git config --global --add safe.directory /var/www/html/wp-content/themes/$THEME_NAME
"
if [ $? -eq 0 ]; then
  echo "✅ Git safe.directory configured successfully."
else
  echo "❌ Error: Failed to configure Git safe.directory."
  exit 1
fi

# Run composer install in Docker 🐳
echo "📦 Running composer install in the container..."
docker compose exec web bash -c "
  cd wp-content/themes/$THEME_NAME &&
  composer install
"
if [ $? -eq 0 ]; then
  echo "✅ Composer dependencies installed successfully."
else
  echo "❌ Error: Composer install failed."
  exit 1
fi

# Run yarn install locally 🧶
echo "🧶 Installing Yarn dependencies locally..."
yarn install
if [ $? -eq 0 ]; then
  echo "✅ Yarn dependencies installed successfully."
else
  echo "❌ Error: Yarn install failed."
  exit 1
fi

# Create lock file 🔒
touch init.lock
echo "🔒 Initialization lock file created."

# Print completion message 🎉
echo "🚀 Initialization completed! Happy coding with WordPress!"

# Launch wordpress.sh after init
echo "⚙️ Running WordPress setup script..."
bash wordpress.sh
if [ $? -eq 0 ]; then
    echo "✅ WordPress setup completed successfully."
else
    echo "❌ Error: WordPress setup failed."
    exit 1
fi
