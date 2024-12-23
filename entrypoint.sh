#!/bin/sh
set -e

# Check if the signal-api user exists, if not, create it
if ! id "signal-api" >/dev/null 2>&1; then
    useradd -m -u 1000 signal-api
fi

# Modify the user ID only if the user exists
if id "signal-api" >/dev/null 2>&1; then
    usermod -u 1000 signal-api
fi

# Proceed with the rest of the script
if [ -z "$SIGNAL_CLI_HOME" ]; then
    SIGNAL_CLI_HOME=/home/.local/share/signal-cli
fi

# Add any other necessary commands here
if [ -n "$SIGNAL_CLI_HOME" ]; then
    /usr/bin/jsonrpc2-helper
    if [ -n "$JAVA_OPTS" ] ; then
        echo "export JAVA_OPTS='$JAVA_OPTS'" >> /etc/default/supervisor
    fi
    service supervisor start
    supervisorctl start all
fi

export HOST_IP=$(hostname -I | awk '{print $1}')

# Start API as signal-api user
exec setpriv --reuid=1000 --regid=1000 --init-groups --inh-caps=$caps signal-cli-rest-api -signal-cli-config=${SIGNAL_CLI_CONFIG_DIR}
