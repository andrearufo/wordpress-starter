# WordPress Starter Project

This project provides a complete setup for WordPress development using Docker, WP-CLI, and custom scripts to automate workflows.

---

## Features

- **Docker-based environment**: Includes WordPress, MariaDB, and Mailpit.
- **Theme setup**: Automatically downloads and configures a theme from a provided URL.
- **Plugin management**: Installs and activates plugins defined in the `.env` file.
- **SMTP configuration**: Pre-configures WP Mail SMTP for email testing in development.
- **Reset functionality**: Resets the environment while preserving specific files.

---

## Prerequisites

Ensure the following tools are installed on your system:

- [Docker](https://www.docker.com/)
- [Composer](https://getcomposer.org/)
- [Yarn](https://yarnpkg.com/)
- `wget`
- `unzip`

---

## Setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd <repository-folder>
```

### 2. Configure the `.env` file

Copy the example `.env` file and customize it to your needs:

```bash
cp .env.example .env
```

A typical `.env` file:

```env
THEME_NAME=starter
THEME_PACKAGE_URL=https://github.com/wp-bathe/bathe/archive/master.zip

DOCKER_WORDPRESS_PORT=8888
DOCKER_DB_PORT=3306
DOCKER_MAILPIT_PORT=1025
DOCKER_MAILPIT_DASHBOARD_PORT=8025

DB_MYSQL_ROOT_PASSWORD=rootpassword
DB_MYSQL_DATABASE=wordpress
DB_MYSQL_USER=wordpress
DB_MYSQL_PASSWORD=wordpress

WP_ADMIN_USER=axiostudio
WP_ADMIN_PASSWORD=powerfull
WP_ADMIN_EMAIL=noreply@axio.studio
WP_SITE_TITLE=WordPress Starter

SMTP_HOST=mailpit
SMTP_PORT=1025
SMTP_FROM_EMAIL=noreply@localhost
SMTP_FROM_NAME=WordPress

PLUGINS=bottom-admin-toolbar,disable-comments,force-regenerate-thumbnails,intuitive-custom-post-order,limit-login-attempts-reloaded,redirection,show-current-template,wp-mail-smtp
```

---

## Usage

### Initialize the Project

Run the following command to initialize the project:

```bash
bash init.sh
```

This script will:
1. Download and extract the theme.
2. Build and start Docker containers.
3. Install WordPress.
4. Install and configure plugins.
5. Configure SMTP settings.

### Reset the Environment

To reset the environment, run:

```bash
bash init.sh --reset
```

This will:
1. Stop and remove all Docker containers and volumes.
2. Clean up the project directory, preserving specific files.
3. Ask if you want to continue with the setup.

### Start the Development Server

Run the following command to start the development server:

```bash
docker compose up -d
```

---

## Files and Directories

- **`init.sh`**: Automates the initialization process.
- **`reset.sh`**: Resets the environment while preserving essential files.
- **`docker-compose.yml`**: Defines the Docker services.
- **`_volumes/`**: Contains persistent data for the database, plugins, and uploads.
- **`.env`**: Configuration file for environment variables.

---

## Troubleshooting

1. **Docker is not running:**
   Ensure Docker is installed and running on your system.

   ```bash
   sudo service docker start
   ```

2. **Permission errors:**
   Ensure the scripts have execute permissions:

   ```bash
   chmod +x init.sh reset.sh
   ```

3. **SMTP not working:**
   Check the SMTP settings in `.env` and verify that Mailpit is running.

---

## Customization

- Update the `PLUGINS` variable in `.env` to define the plugins to be installed.
- Modify `THEME_PACKAGE_URL` to use a different theme zip file.
- Adjust SMTP settings for custom email providers.

---

## Contributing

Feel free to open issues or submit pull requests for improvements or bug fixes.

---

## License

This project is licensed under the MIT License.

