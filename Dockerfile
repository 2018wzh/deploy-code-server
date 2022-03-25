# Start from the code-server Debian base image
FROM codercom/code-server:4.0.2

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below
# -----------
RUN sudo apt-get install -y build-essential llvm clang lldb cmake gdb gcc g++ python3 wget

# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
RUN code-server --install-extension ms-ceintl.vscode-language-pack-zh-hans
RUN code-server --install-extension  ms-python.python
RUN code-server --install-extension  zhuangtongfa.material-theme
RUN code-server --install-extension  pkief.material-icon-theme
# Install apt packages:
# RUN sudo apt-get install -y ubuntu-make

# Copy files: 
# COPY deploy-container/myTool /home/coder/myTool

#Install cpptools intellicode
#COPY deploy-container/cpptools.vsix /tmp/cpptools.vsix
COPY deploy-container/icode.vsix /tmp/icode.vsix
RUN curl "https://objects.githubusercontent.com/github-production-release-asset-2e65be/54800346/97626cf7-8584-4612-86f1-24fc9a0d1a9e?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20220325%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220325T031422Z&X-Amz-Expires=300&X-Amz-Signature=885a1252615c204780c0d89335c75ae439fc1affb33018c2de83e0c6ffc213b8&X-Amz-SignedHeaders=host&actor_id=41959076&key_id=0&repo_id=54800346&response-content-disposition=attachment%3B%20filename%3Dcpptools-linux.vsix&response-content-type=application%2Foctet-stream" -o /tmp/cpptools.vsix
RUN code-server --install-extension /tmp/icode.vsix
RUN code-server --install-extension /tmp/cpptools.vsix
# -----------

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
