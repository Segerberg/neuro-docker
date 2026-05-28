FROM codercom/code-server:latest

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-venv \
    python3-dev \
    libopenblas-dev \
    liblapack-dev \
    libhdf5-dev \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    git \
    curl \
    wget \
    unzip \
    ca-certificates \
    file\
    tree\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# ── SSH
RUN mkdir -p /var/run/sshd \
 && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
 && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
 && echo 'Port 2222' >> /etc/ssh/sshd_config

# ── Python venv
ENV VENV=/opt/venv
RUN python3 -m venv $VENV
ENV PATH="$VENV/bin:$PATH"
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# ── VS Code extensions ────────────────────────────────────────
ENV EXTENSIONS_DIR=/home/coder/.local/share/code-server/extensions
RUN mkdir -p $EXTENSIONS_DIR

RUN code-server --extensions-dir $EXTENSIONS_DIR --install-extension ms-python.python

COPY vnc-extension.vsix /tmp/vnc-extension.vsix
RUN code-server --extensions-dir $EXTENSIONS_DIR --install-extension /tmp/vnc-extension.vsix \
 && rm /tmp/vnc-extension.vsix

# ── SSH authkeys
RUN mkdir -p /home/coder/.ssh

# -- Workspace & config
RUN mkdir -p /home/coder/workspace /home/coder/.local/share/code-server/User

COPY settings.json /home/coder/.local/share/code-server/User/settings.json
COPY vnc.json /home/coder/.local/share/code-server/extensions/king2021.vnc-extension-0.0.3/vnc.json

# -- Dashboard
RUN mkdir -p /home/coder/workspace/.vscode


RUN echo 'source /opt/venv/bin/activate' >> /home/coder/.bashrc \
 && echo 'export PATH="/opt/ants/bin:$VENV/bin:$PATH"' >> /home/coder/.bashrc \
 && echo 'export ANTSPATH=/opt/ants/bin' >> /home/coder/.bashrc

RUN chown -R coder:coder /home/coder $VENV \
 && chgrp -R 0 /home/coder $VENV \
 && chmod -R g=u /home/coder $VENV

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /home/coder/workspace

EXPOSE 8080 2222

ENTRYPOINT ["/entrypoint.sh"]
