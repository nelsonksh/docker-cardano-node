FROM ghcr.io/blinklabs-io/haskell:9.6.3-3.10.2.0-2 AS cardano-node-build
# Install cardano-node
ARG NODE_VERSION=8.9.2
ENV NODE_VERSION=${NODE_VERSION}
RUN echo "Building tags/${NODE_VERSION}..." \
    && echo tags/${NODE_VERSION} > /CARDANO_BRANCH \
    && git clone https://github.com/input-output-hk/cardano-node.git \
    && cd cardano-node \
    && git fetch --all --recurse-submodules --tags \
    && git tag \
    && git checkout tags/${NODE_VERSION} \
    && echo "with-compiler: ghc-${GHC_VERSION}" >> cabal.project.local \
    && echo "tests: False" >> cabal.project.local \
    && cabal update \
    && cabal build all \
    && mkdir -p /root/.local/bin/ \
    && cp -p "$(./scripts/bin-path.sh cardano-node)" /root/.local/bin/ \
    && rm -rf /root/.cabal/packages \
    && rm -rf /usr/local/lib/ghc-${GHC_VERSION}/ /usr/local/share/doc/ghc-${GHC_VERSION}/ \
    && rm -rf /code/cardano-node/dist-newstyle/ \
    && rm -rf /root/.cabal/store/ghc-${GHC_VERSION}

FROM ghcr.io/blinklabs-io/cardano-cli:8.22.0.0 AS cardano-cli
FROM ghcr.io/blinklabs-io/mithril-client:0.8.0-1 AS mithril-client
FROM ghcr.io/blinklabs-io/nview:0.9.4 AS nview
FROM ghcr.io/blinklabs-io/txtop:0.8.0 AS txtop

# Use the official Debian Bookworm slim base image
FROM debian:bookworm-slim AS base

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package repository and install necessary packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-venv \
    python3-pip \
    bash && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the Flask app
COPY sys-call-api/app.py /app/

# Copy the bash scripts
COPY sys-call-api/hello_world.sh /scripts/hello_world.sh
COPY sys-call-api/greet.sh /scripts/greet.sh

# Ensure the bash scripts are executable
RUN chmod +x /scripts/hello_world.sh /scripts/greet.sh

# Create a virtual environment and install Flask and Gunicorn
RUN python3 -m venv venv && \
    ./venv/bin/pip install --upgrade pip && \
    ./venv/bin/pip install Flask gunicorn

# Expose the ports the app runs on
EXPOSE 3001 12788 12798 5000

# Activate the virtual environment and run the application with Gunicorn
CMD ["./venv/bin/gunicorn", "--bind", "0.0.0.0:5000", "app:app"]

# Combine the stages
FROM base AS cardano-node
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

COPY --from=cardano-node-build /usr/local/lib/ /usr/local/lib/
COPY --from=cardano-node-build /usr/local/include/ /usr/local/include/
COPY --from=cardano-node-build /root/.local/bin/cardano-* /usr/local/bin/
COPY --from=cardano-cli /usr/local/bin/cardano-cli /usr/local/bin/
COPY --from=mithril-client /bin/mithril-client /usr/local/bin/
COPY --from=nview /bin/nview /usr/local/bin/
COPY --from=txtop /bin/txtop /usr/local/bin/
COPY bin/ /usr/local/bin/
COPY config/ /opt/cardano/config/

RUN apt-get update -y && \
    apt-get install -y \
    bc \
    curl \
    iproute2 \
    jq \
    libffi8 \
    libgmp10 \
    liblmdb0 \
    libncursesw5 \
    libnuma1 \
    libsystemd0 \
    libssl3 \
    libtinfo6 \
    llvm-14-runtime \
    netbase \
    pkg-config \
    procps \
    sqlite3 \
    wget \
    zlib1g && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x /usr/local/bin/*

# Copy over the Flask app and the bash scripts
COPY sys-call-api/app.py /app/
COPY sys-call-api/hello_world.sh /scripts/hello_world.sh
COPY sys-call-api/greet.sh /scripts/greet.sh
COPY sys-call-api/tx.sh /scripts/tx.sh

# Ensure the bash scripts are executable
RUN chmod +x /scripts/hello_world.sh /scripts/greet.sh /scripts/tx.sh

EXPOSE 3001 12788 12798 5000

RUN apt-get update && apt-get install -y supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]