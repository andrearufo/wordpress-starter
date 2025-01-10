#!/bin/bash

# Check if reset flag is passed
if [[ "$1" == "--reset" ]]; then
  read -p "⚠️ Are you sure you want to reset the environment? This will delete all data. (Y/n) " -n 1 -r
  echo
  if [[ -z "$REPLY" || "$REPLY" =~ ^[Yy]$ ]]; then
    echo "🔄 Starting reset process..."
    ./reset.sh

    read -p "⚠️ Reset completed. Do you want to proceed with the installation? (Y/n) " -n 1 -r
    echo
    if [[ -z "$REPLY" || "$REPLY" =~ ^[Yy]$ ]]; then
      echo "❌ Installation cancelled after reset."
      exit 1
    fi
  else
    echo "❌ Reset cancelled."
    exit 1
  fi
fi

# Cleanup on exit
cleanup() {
  echo "🩹 Cleaning up..."
  rm -f "$ZIP_FILE"
  rm -rf "$TEMP_DIR"
  # docker compose down --volumes --remove-orphans
}
trap cleanup EXIT

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

# Check and copy the .env file if it doesn't exist 💂️
if [ -f .env ]; then
  read -p "⚠️ .env file already exists. Do you want to overwrite it? (y/N) " -n 1 -r
  echo
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    cp .env.example .env
    echo "✅ .env file overwritten with .env.example."
  else
    echo "ℹ️ Using existing .env file."
  fi
else
  cp .env.example .env
  echo "✅ .env file created from .env.example."
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
TEMP_DIR="temp_theme"

echo "📥 Downloading theme from $ZIP_URL..."
if ! wget -O "$ZIP_FILE" "$ZIP_URL"; then
  echo "❌ Error: Failed to download theme."
  exit 1
fi

echo "🗂 Extracting theme..."
if unzip -q "$ZIP_FILE" -d "$TEMP_DIR"; then
  echo "✅ Theme extracted successfully to $TEMP_DIR."
else
  echo "❌ Error: Failed to extract theme."
  exit 1
fi

EXTRACTED_DIR=$(find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)
if [ -d "$EXTRACTED_DIR" ]; then
  echo "📂 Moving files from $EXTRACTED_DIR to the project root..."
  find "$EXTRACTED_DIR" -mindepth 1 -maxdepth 1 -exec mv -f {} . \;
else
  echo "⚠️ No valid directory found in $TEMP_DIR. Assuming files are directly extracted."
  find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -exec mv -f {} . \;
fi

rm -rf "$TEMP_DIR" "$ZIP_FILE"

# Start the containers 🚢
docker compose build --no-cache --force-rm
docker compose up -d

echo "⏳ Waiting for database to be ready..."
until docker compose exec db mysqladmin ping -h db --silent; do
    echo "🛠️ Database not ready. Retrying..."
    sleep 3
done
echo "✅ Database is ready!"

# Clean database
DB_NAME="${DB_MYSQL_DATABASE:-wordpress}"
DB_USER="${DB_MYSQL_USER:-wordpress}"
DB_PASS="${DB_MYSQL_PASSWORD:-wordpress}"
DB_HOST="db:${DOCKER_DB_PORT:-3306}"
docker compose exec db mysql -u${DB_USER} -p${DB_PASS} -e "DROP DATABASE IF EXISTS ${DB_NAME}; CREATE DATABASE ${DB_NAME};"

echo "🗑️ Removing existing wp-config.php..."
docker compose exec web bash -c "if [ -f /var/www/html/wp-config.php ]; then rm -f /var/www/html/wp-config.php; fi"

# Create wp-config.php
docker compose run --rm cli config create \
    --dbname="$DB_NAME" \
    --dbuser="$DB_USER" \
    --dbpass="$DB_PASS" \
    --dbhost="$DB_HOST" \
    --skip-check --allow-root

echo "⚙️ Installing WordPress..."
SITE_URL="http://localhost:${DOCKER_WORDPRESS_PORT:-8000}"
ADMIN_USER="${WP_ADMIN_USER:-admin}"
ADMIN_PASSWORD="${WP_ADMIN_PASSWORD:-password}"
ADMIN_EMAIL="${WP_ADMIN_EMAIL:-admin@example.com}"
SITE_TITLE="${WP_SITE_TITLE:-My WordPress Site}"
docker compose run --rm cli core install \
    --url="$SITE_URL" \
    --title="$SITE_TITLE" \
    --admin_user="$ADMIN_USER" \
    --admin_password="$ADMIN_PASSWORD" \
    --admin_email="$ADMIN_EMAIL" \
    --allow-root

# Install and activate plugins
if [ -z "${PLUGINS}" ]; then
  PLUGINS=("wp-mail-smtp") # Default plugin
fi

PLUGINS=($(grep -E "^PLUGINS=" .env | cut -d '=' -f 2 | tr ',' ' '))
for PLUGIN in "${PLUGINS[@]}"; do
    docker compose run --rm cli plugin install "$PLUGIN" --activate --allow-root
done

# Configure SMTP plugin
SMTP_HOST="${SMTP_HOST:-mailpit}"
SMTP_PORT="${SMTP_PORT:-1025}"
SMTP_FROM_EMAIL="${SMTP_FROM_EMAIL:-noreply@localhost}"
SMTP_FROM_NAME="${SMTP_FROM_NAME:-WordPress}"
docker compose run --rm cli option update wp_mail_smtp \
    "{\"mailer\":\"smtp\",\"from_email\":\"$SMTP_FROM_EMAIL\",\"from_name\":\"$SMTP_FROM_NAME\",\"smtp\":{\"host\":\"$SMTP_HOST\",\"port\":$SMTP_PORT,\"encryption\":\"none\",\"auth\":false}}" \
    --format=json --allow-root

echo "🚀 WordPress setup completed!"
