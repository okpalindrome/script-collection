# Built image - https://hub.docker.com/r/okpalindrome/az-steampipe-powerpipe
# docker run -it --rm -p 9033:9033 test:1 /bin/bash
# Start Steampipe as the data source cmd (it will download and install db): steampipe service start
# Start the dashboard server cmd: powerpipe server --listen network

FROM ubuntu:24.04

# Install dependencies for az-cli
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates git curl gnupg lsb-release

# Add Microsoft key and repository for az-cli
RUN mkdir -p /etc/apt/keyrings && \
    curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/keyrings/microsoft.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/microsoft.gpg

# Add az-cli source list
RUN AZ_DIST=$(lsb_release -cs) && \
    echo "Types: deb\nURIs: https://packages.microsoft.com/repos/azure-cli/\nSuites: ${AZ_DIST}\nComponents: main\nArchitectures: $(dpkg --print-architecture)\nSigned-by: /etc/apt/keyrings/microsoft.gpg" | tee /etc/apt/sources.list.d/azure-cli.sources

# Install steampipe
RUN /bin/sh -c "$(curl -fsSL https://steampipe.io/install/steampipe.sh)"

# Install Powerpipe
RUN /bin/sh -c "$(curl -fsSL https://powerpipe.io/install/powerpipe.sh)"

# Create a non-root user and set up the environment
RUN useradd -m -s /bin/bash steampipeuser && \
    chown -R steampipeuser:steampipeuser /home/steampipeuser

# Switch to the non-root user
USER steampipeuser
WORKDIR /home/steampipeuser

# Install Steampipe Azure plugin and Azure compliance mod (includes CIS, NIST, etc.)
RUN steampipe plugin install azure azuread && mkdir dashboards

WORKDIR /home/steampipeuser/dashboards

RUN powerpipe mod init && powerpipe mod install github.com/turbot/steampipe-mod-azure-compliance 

# Expose Powerpipe dashboard port
EXPOSE 9033

# Default command for interactive shell
CMD ["/bin/bash"]
