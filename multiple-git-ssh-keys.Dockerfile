# Description:
# To use multiple git SSH keys for testing
# Rename this file to Dockerfile
# Replace username with actual username from github/gitlab for unique identification
# docker build -t username . 
# docker run -it username
# Example, for gitlab locally running instance with custom SSH port
# $ ssh -T git@172.17.0.1 -p 2222

FROM alpine/git

# Create user
RUN adduser -D username
USER username
WORKDIR /home/username

# Generate SSH key pair without passphrase
RUN ssh-keygen -t ed25519 -C "username@example.com" -f ~/.ssh/id_rsa -N "" 
# add ~/.ssh/id_rsa.pub to your profile

# Disable inherited ENTRYPOINT
ENTRYPOINT []
CMD ["sh"]
