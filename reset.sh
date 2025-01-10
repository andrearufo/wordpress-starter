#!/bin/bash

# Clear terminal
clear

# Print starting message
echo "🔄 Starting reset process..."

# Check if required commands are available
for cmd in docker find rm; do
  if ! command -v $cmd &> /dev/null; then
    echo "❌ Error: $cmd is not installed. Please install it and try again."
    exit 1
  fi
done

# List of files/directories to keep
KEEP=(
  "README.md"
  ".env.example"
  ".git"
  "_volumes"
  "docker-compose.yml"
  "dockerfile"
  "init.sh"
  "reset.sh"
)

echo "ℹ️ The following files/directories will be preserved:"
for item in "${KEEP[@]}"; do
  echo "   - $item"
done

# Stop and remove Docker containers and volumes
echo "🛑 Stopping and removing Docker containers and volumes..."
docker compose down -v
if [ $? -eq 0 ]; then
  echo "✅ Docker containers and volumes removed."
else
  echo "❌ Error: Failed to remove Docker containers or volumes. Please check Docker."
fi

# Clean up _volumes directory, preserving .gitignore
if [ -d "_volumes" ]; then
  echo "🗑️ Cleaning up mounted directories in _volumes, preserving .gitignore..."
  find ./_volumes -mindepth 1 \( ! -name '.gitignore' \) -exec rm -rf {} + || {
    echo "❌ Error: Failed to clean up _volumes directory."
    exit 1
  }
  echo "✅ Mounted directories cleaned, but .gitignore preserved."
else
  echo "ℹ️ _volumes directory not found. Skipping mounted directory cleanup."
fi

# Convert the list into a find-compatible expression
FIND_EXPRESSION=""
for item in "${KEEP[@]}"; do
  FIND_EXPRESSION+="! -path './$item' "
done

# Execute the clean-up, preserving the listed files/directories
echo "🧹 Cleaning up the directory, preserving essential files..."
eval "find . -mindepth 1 -maxdepth 1 $FIND_EXPRESSION -exec rm -rf {} +" || {
  echo "❌ Error: Failed to clean up the directory."
  exit 1
}

# Remove init.lock if it exists
if [ -f init.lock ]; then
  rm init.lock
  echo "🔒 Removed initialization lock."
fi

# Print completion message
echo "🎉 Reset process completed! The environment has been restored to its initial state."
