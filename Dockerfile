# Runner image for the rack cluster (ARC, arm64): the stock runner plus the
# PHP toolchain, so jobs skip the apt install setup-php would otherwise do.
# Base images are pinned by digest; Dependabot proposes the bumps.
FROM ghcr.io/actions/actions-runner:2.337.0@sha256:e5496277be5d09bc968b3d64911b74e219ac4a3f2edce956a3ecf9271bea1ef4

ARG NODE_VERSION=22.23.2
ARG NODE_SHA256=fff4078c5def658577f92c88db7db3bc0072924bfb93fe52c1e744a54e94abb8

USER root

# setup-php treats a version as installed once php<ver> and php-config<ver>
# (the -dev package) exist, and then only switches the alternatives to it.
# php stays 8.4 until a job asks for 8.5.
RUN apt-get update \
    && apt-get upgrade -y --no-install-recommends \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg software-properties-common unzip xz-utils \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get install -y --no-install-recommends \
        $(for version in 8.4 8.5; do \
            for extension in bcmath cli curl dev gd intl mbstring mysql opcache pgsql readline sqlite3 xml zip; do \
                printf 'php%s-%s ' "$version" "$extension"; \
            done; \
        done) \
    && for tool in php phar phar.phar php-config phpize; do update-alternatives --set "$tool" "/usr/bin/${tool}8.4"; done \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# setup-node ignores PATH and looks in the runner tool cache, which by default
# sits on the job's empty work volume. A tool cache outside it, in the layout
# @actions/tool-cache expects, makes setup-node a no-op.
ENV RUNNER_TOOL_CACHE=/opt/hostedtoolcache
RUN mkdir -p "$RUNNER_TOOL_CACHE/node/$NODE_VERSION/arm64" \
    && curl -fsSLo /tmp/node.tar.xz "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-arm64.tar.xz" \
    && echo "$NODE_SHA256  /tmp/node.tar.xz" | sha256sum -c - \
    && tar -xJf /tmp/node.tar.xz -C "$RUNNER_TOOL_CACHE/node/$NODE_VERSION/arm64" --strip-components=1 \
    && rm /tmp/node.tar.xz \
    && touch "$RUNNER_TOOL_CACHE/node/$NODE_VERSION/arm64.complete" \
    && ln -s "$RUNNER_TOOL_CACHE/node/$NODE_VERSION/arm64/bin/"* /usr/local/bin/ \
    && chown -R runner:runner "$RUNNER_TOOL_CACHE"

COPY --from=composer:2.9.8@sha256:b09bccd91a78fe8a9ab4b33d707b862e8fe54fec17782e32683ad2a69c46867d /usr/bin/composer /usr/local/bin/composer

USER runner
