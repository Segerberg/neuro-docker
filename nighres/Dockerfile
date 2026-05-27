FROM registry.access.redhat.com/ubi9/python-39

USER root

RUN dnf update -y && dnf install -y \
    git \
    gcc \
    gcc-c++ \
    make \
    java-17-openjdk-devel \
    wget \
    && dnf clean all

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV JCC_JDK=/usr/lib/jvm/java-17-openjdk
ENV LDFLAGS="-L${JAVA_HOME}/lib -L${JAVA_HOME}/lib/server -Wl,-rpath,${JAVA_HOME}/lib -Wl,-rpath,${JAVA_HOME}/lib/server"

RUN mkdir -p /usr/lib/jvm && \
    ln -s $JAVA_HOME /usr/lib/jvm/temurin-17-jdk-amd64

RUN python3 -m pip install --upgrade pip wheel && \
    python3 -m pip install jcc nibabel psutil antspyx nilearn numpy matplotlib

RUN git clone https://github.com/nighres/nighres /nighres

WORKDIR /nighres
RUN ./build.sh && \
    python3 -m pip install .

ARG ANTS_VERSION=2.5.3
RUN curl -fsSL \
    "https://github.com/ANTsX/ANTs/releases/download/v${ANTS_VERSION}/ants-${ANTS_VERSION}-ubuntu-22.04-X64-gcc.zip" \
    -o /tmp/ants.zip \
    && unzip /tmp/ants.zip -d /tmp/ants_extract \
    && mv /tmp/ants_extract/ants-${ANTS_VERSION} /opt/ants \
    && rm -rf /tmp/ants.zip /tmp/ants_extract \
    && test -f /opt/ants/bin/antsRegistration   # sanity-check

ENV PATH="/opt/ants/bin:$PATH"
ENV ANTSPATH="/opt/ants/bin"
RUN chown -R 0:0 /opt/ants && chmod -R g=u /opt/ants
RUN mkdir -p /data/safe
RUN chown -R :0 /data/safe && chmod -R g+rwX /data/safe
USER 1001
