FROM ubuntu:24.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update packages and install required dependencies
RUN apt-get update && \
    apt-get install -y \
    sudo \
    curl \
    gnupg \
    lsb-release \
    ca-certificates \
    apt-transport-https && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Create user 'steampipeuser' with home directory
RUN useradd -m -s /bin/bash steampipeuser

# Add user to sudo group
RUN usermod -aG sudo steampipeuser

# Allow sudo without password
RUN echo "steampipeuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the new user
USER steampipeuser

# Set working directory to user's home
WORKDIR /home/steampipeuser

# Install Powerpipe and Steampipe
RUN sudo /bin/sh -c "$(curl -fsSL https://powerpipe.io/install/powerpipe.sh)"
RUN sudo /bin/sh -c "$(curl -fsSL https://steampipe.io/install/steampipe.sh)"

# Install plugins
RUN steampipe plugin install azure
RUN steampipe plugin install azuread

# Create dashboards directory and initialize
RUN mkdir -p /home/steampipeuser/dashboards
WORKDIR /home/steampipeuser/dashboards

RUN powerpipe mod init
RUN powerpipe mod install github.com/turbot/steampipe-mod-azure-compliance

# Create entrypoint script
RUN echo '#!/bin/bash\n\
steampipe service start\n\
echo "Steampipe service started..."\n\
exec "$@"' > /home/steampipeuser/entrypoint.sh && \
    chmod +x /home/steampipeuser/entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/home/steampipeuser/entrypoint.sh"]

# Default command (keeps container running)
CMD ["/bin/bash", "-c", "tail -f /dev/null"]
