FROM registry.access.redhat.com/ubi9/ubi:latest

USER root
RUN dnf update -y && \
    dnf install -y \
        python3 \
        python3-pip \
        python3-devel \
        openblas-devel \
        lapack-devel \
        hdf5-devel \
        glib2 \
        libSM \
        libXrender \
        libXext \
        git \
        curl \
        wget \
        unzip \
        ca-certificates \
        file \
        tree \
        openssh-server \
        nss_wrapper \
        shadow-utils \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# ── Skapa coder-användare
RUN useradd -m -u 1000 -s /bin/bash coder && \
    usermod -aG root coder

# ── Installera code-server via RPM
RUN CODESERVER_VERSION=$(curl -s https://api.github.com/repos/coder/code-server/releases/latest \
        | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/') && \
    curl -fsSL "https://github.com/coder/code-server/releases/download/v${CODESERVER_VERSION}/code-server_${CODESERVER_VERSION}_amd64.rpm" \
        -o /tmp/code-server.rpm && \
    dnf install -y /tmp/code-server.rpm && \
    rm /tmp/code-server.rpm

# ── SSH (port 2222)
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    echo 'Port 2222' >> /etc/ssh/sshd_config

# ── Python venv
ENV VENV=/opt/venv
RUN python3 -m venv $VENV
ENV PATH="$VENV/bin:$PATH"
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# ── VS Code extensions
ENV EXTENSIONS_DIR=/home/coder/.local/share/code-server/extensions
RUN mkdir -p $EXTENSIONS_DIR
RUN code-server --extensions-dir $EXTENSIONS_DIR --install-extension ms-python.python
COPY vnc-extension.vsix /tmp/vnc-extension.vsix
RUN code-server --extensions-dir $EXTENSIONS_DIR --install-extension /tmp/vnc-extension.vsix \
    && rm /tmp/vnc-extension.vsix

# ── SSH authorized_keys
RUN mkdir -p /home/coder/.ssh

# ── Workspace & config
RUN mkdir -p /home/coder/workspace /home/coder/.local/share/code-server/User
COPY settings.json /home/coder/.local/share/code-server/User/settings.json
COPY vnc.json /home/coder/.local/share/code-server/extensions/king2021.vnc-extension-0.0.3/vnc.json

RUN mkdir -p /home/coder/workspace/.vscode
RUN echo 'source /opt/venv/bin/activate' >> /home/coder/.bashrc && \
    echo 'export PATH="/opt/ants/bin:$VENV/bin:$PATH"' >> /home/coder/.bashrc && \
    echo 'export ANTSPATH=/opt/ants/bin' >> /home/coder/.bashrc

RUN chown -R coder:coder /home/coder $VENV && \
    chgrp -R 0 /home/coder $VENV && \
    chmod -R g=u /home/coder $VENV

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /home/coder/workspace
EXPOSE 8080 2222
ENTRYPOINT ["/entrypoint.sh"]
