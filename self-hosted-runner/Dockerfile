# ─────────────────────────────────────────────────────────────
# Minimal Debian 13 (trixie) + GitHub Actions runner
# Tailored for libp2p website workflows
# ─────────────────────────────────────────────────────────────
FROM debian:13-slim

ENV DEBIAN_FRONTEND=noninteractive \
    RUNNER_ALLOW_RUNASROOT=1

# 1. Base packages + GitHub CLI repo
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg && \
    # GitHub CLI repo
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) \
      signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] \
      https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list && \
    # Install all packages
    apt-get update && \
    apt-get install -y --no-install-recommends \
        coreutils \
        gh \
        git \
        jq \
        libicu76 \
        libkrb5-3 \
        liblttng-ust1 \
        libssl3 \
        libunwind8 \
        libuuid1 \
        nodejs \
        npm \
        python3 \
        python3-yaml \
        tar \
        unzip \
        util-linux \
        wget \
        xmlstarlet && \
    rm -rf /var/lib/apt/lists/*

# 2. AWS CLI v2
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
      -o /tmp/awscli.zip && \
    unzip -q /tmp/awscli.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/awscli.zip /tmp/aws

# 3. Zola static site generator
ENV ZOLA_VERSION=0.22.1
RUN curl -fsSL -o /tmp/zola.tar.gz \
      "https://github.com/getzola/zola/releases/download/v${ZOLA_VERSION}/zola-v${ZOLA_VERSION}-x86_64-unknown-linux-gnu.tar.gz" && \
    tar xzf /tmp/zola.tar.gz -C /usr/local/bin zola && \
    chmod +x /usr/local/bin/zola && \
    rm /tmp/zola.tar.gz

# 4. GitHub Actions runner
ARG RUNNER_VERSION=2.330.0
WORKDIR /actions-runner
RUN curl -fsSL -o runner.tar.gz \
      "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" && \
    tar xzf runner.tar.gz && \
    rm runner.tar.gz && \
    ./bin/installdependencies.sh && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
