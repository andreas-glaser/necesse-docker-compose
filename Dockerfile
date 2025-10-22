# Necesse Dedicated Server Dockerfile
FROM debian:bullseye-slim

ARG BUILD_VERSION=dev
ARG BUILD_REVISION=unknown

# Create necesse user with specified UID/GID for proper permissions
ARG user=necesse
ARG group=necesse
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group} && \
    useradd -u ${uid} -g ${group} -s /bin/bash -m ${user}

# Install dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        ca-certificates-java \
        lib32gcc-s1 \
        curl \
        gosu \
        openjdk-17-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install SteamCMD
RUN mkdir -p /steamapps && \
    curl -sqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxvf - -C /steamapps

WORKDIR /steamapps

# OCI metadata for the built image
LABEL org.opencontainers.image.title="Necesse Dedicated Server" \
      org.opencontainers.image.description="Containerised Necesse dedicated server with SteamCMD-managed updates and admin-friendly automation." \
      org.opencontainers.image.source="https://github.com/andreas-glaser/necesse-docker-server" \
      org.opencontainers.image.url="https://github.com/andreas-glaser/necesse-docker-server" \
      org.opencontainers.image.version="${BUILD_VERSION}" \
      org.opencontainers.image.revision="${BUILD_REVISION}"

# Create SteamCMD update script
RUN echo '@ShutdownOnFailedCommand 1' > update_necesse.txt && \
    echo '@NoPromptForPassword 1' >> update_necesse.txt && \
    echo 'force_install_dir /app/' >> update_necesse.txt && \
    echo 'login anonymous' >> update_necesse.txt && \
    echo 'app_update 1169370 validate' >> update_necesse.txt && \
    echo 'quit' >> update_necesse.txt

# Download Necesse server files via SteamCMD
RUN ./steamcmd.sh +runscript update_necesse.txt

# Set up proper ownership
RUN chown -R ${uid}:${gid} /app && \
    mkdir -p /home/necesse/.config/Necesse && \
    chown -R ${uid}:${gid} /home/necesse

# Copy entrypoint script
WORKDIR /app
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x entrypoint.sh && chown ${uid}:${gid} entrypoint.sh

# Switch to root; entrypoint will drop privileges
USER root
ENV CONTAINER_USER=${user} \
    CONTAINER_GROUP=${group} \
    CONTAINER_UID=${uid} \
    CONTAINER_GID=${gid}

# Expose default Necesse port (UDP)
EXPOSE 14159/udp

# Set default environment variables
ENV WORLD_NAME=world \
    SERVER_PORT=14159 \
    SERVER_SLOTS=10 \
    SERVER_OWNER= \
    SERVER_MOTD= \
    SERVER_PASSWORD= \
    PAUSE_WHEN_EMPTY=0 \
    GIVE_CLIENTS_POWER=0 \
    ENABLE_LOGGING=1 \
    ZIP_SAVES=1 \
    SERVER_LANGUAGE=en \
    SETTINGS_FILE= \
    BIND_IP= \
    MAX_CLIENT_LATENCY= \
    LOCAL_DIR=0 \
    DATA_DIR= \
    LOGS_DIR= \
    UPDATE_ON_START=false \
    AUTO_UPDATE_INTERVAL_MINUTES=0 \
    JAVA_OPTS=

# Server data volume
VOLUME ["/home/necesse/.config/Necesse"]

CMD ["./entrypoint.sh"]
