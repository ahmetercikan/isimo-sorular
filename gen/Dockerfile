# Günlük soru üreticisi: Node + Claude Code komut satırı (archiva-ai ile aynı sürüm, sabit; yeniden derleme davranışı değiştirmesin).
FROM node:22-bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && rm -rf /var/lib/apt/lists/*
ARG CLAUDE_CODE_VERSION=2.1.323
USER node
RUN curl -fsSL https://claude.ai/install.sh | bash -s ${CLAUDE_CODE_VERSION}
ENV CLAUDE_CODE_BIN=/home/node/.local/bin/claude PATH=/home/node/.local/bin:$PATH
WORKDIR /w
