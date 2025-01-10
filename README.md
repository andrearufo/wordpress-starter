Grazie per le informazioni aggiuntive! Ecco una versione aggiornata della descrizione della repository in inglese, includendo i dettagli sui file principali:

---

# WordPress Starter with Docker 🚀

This repository provides a collection of Bash scripts and configuration files to quickly set up a development environment for WordPress themes using Docker. It automates the initialization of a WordPress instance, theme setup, and plugin configuration, making it easy to develop and test themes in a containerized setup.

## Key Features ✨

- **Quick Setup**: Spin up a fully configured WordPress container with minimal effort.
- **Automation**: Automates theme setup, plugin configuration, and WordPress initialization.
- **Customizable**: Use the `.env` file to define custom settings for your WordPress instance.
- **Reproducibility**: Easily reset or rebuild the environment at any time with the included scripts.

## Repository Structure 📂

- **`.env`**: Defines environment variables for the WordPress setup, such as theme name, database credentials, and more.
- **`init.sh`**: Main script to create the Docker environment and fetch the standard theme defined in `.env`.
- **`reset.sh`**: Deletes everything and rebuilds the theme environment from scratch.
- **`wordpress.sh`**: Handles the installation of WordPress, theme setup, and plugin installation.

## Requirements 🛠️

- **Docker**: Ensure Docker (and Docker Compose, if needed) is installed on your system.
- **Bash**: Use a Bash-compatible terminal to run the scripts.

## Getting Started 🚀

1. Clone the repository:
   ```bash
   git clone https://github.com/andrearufo/wordpress-starter.git
   cd wordpress-starter
   ```
2. Configure your environment by editing the `.env` file.
3. Initialize the Docker environment and set up the theme:
   ```bash
   ./init.sh
   ```
4. Access your WordPress instance at [http://localhost:8888](http://localhost:8888).

## Key Scripts 🛠️

- **Initialize**: Use `init.sh` to set up the Docker environment and theme.
- **Reset**: Run `reset.sh` to completely wipe and rebuild the environment.
- **Install WordPress**: Use `wordpress.sh` to configure WordPress, install the theme, and set up plugins.

## Why Use This? 🤔

This project is ideal for WordPress developers who want to:
- Skip repetitive setup tasks.
- Quickly test and iterate on themes and plugins.
- Work in a clean, reproducible, and isolated environment.

## Contributing 🤝

Contributions, suggestions, and bug reports are welcome! Feel free to open an [issue](https://github.com/andrearufo/wordpress-starter/issues) or submit a pull request.