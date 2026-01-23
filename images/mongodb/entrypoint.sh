#!/bin/bash
set -eo pipefail

# Map Bitnami environment variables to standard MongoDB ones
export MONGO_INITDB_ROOT_USERNAME="${MONGODB_ROOT_USER:-root}"
export MONGO_INITDB_ROOT_PASSWORD="${MONGODB_ROOT_PASSWORD}"

# Validate required password
if [ -z "$MONGO_INITDB_ROOT_PASSWORD" ]; then
    echo "ERROR: MONGODB_ROOT_PASSWORD environment variable is required but not set"
    exit 1
fi

# Default values
MONGODB_PORT="${MONGODB_PORT_NUMBER:-27017}"
MONGODB_REPLICA_SET="${MONGODB_REPLICA_SET_NAME:-replicaset}"
MONGODB_REPLICA_KEY="${MONGODB_REPLICA_SET_KEY:-defaultkey}"
MONGODB_HOSTNAME="${MONGODB_ADVERTISED_HOSTNAME:-localhost}"
MONGODB_ADVERTISED_PORT="${MONGODB_ADVERTISED_PORT_NUMBER:-$MONGODB_PORT}"

# Timeouts
STARTUP_TIMEOUT=60
REPLICA_SET_TIMEOUT=30

DATA_DIR="/bitnami/mongodb/data/db"
KEYFILE="/bitnami/mongodb/keyfile"
INIT_MARKER="/bitnami/mongodb/.initialized"

# Create keyfile for replica set authentication
echo "$MONGODB_REPLICA_KEY" > "$KEYFILE" || { echo "ERROR: Failed to create keyfile"; exit 1; }
chmod 600 "$KEYFILE" || { echo "ERROR: Failed to set keyfile permissions"; exit 1; }
chown mongodb:mongodb "$KEYFILE" || { echo "ERROR: Failed to set keyfile ownership"; exit 1; }

# Ensure directories exist and have correct ownership
mkdir -p "$DATA_DIR" || { echo "ERROR: Failed to create data directory"; exit 1; }
chown -R mongodb:mongodb /bitnami/mongodb || { echo "ERROR: Failed to set directory ownership"; exit 1; }

# Wait for MongoDB to be ready with timeout
wait_for_mongodb() {
    local port=$1
    local timeout=$2
    local count=0

    echo "Waiting for MongoDB to start (timeout: ${timeout}s)..."
    until mongosh --port "$port" --eval "db.adminCommand('ping')" > /dev/null 2>&1; do
        sleep 1
        count=$((count + 1))
        if [ $count -ge $timeout ]; then
            echo "ERROR: MongoDB failed to start within ${timeout} seconds"
            return 1
        fi
    done
    echo "MongoDB is ready"
    return 0
}

# Wait for MongoDB with auth to be ready
wait_for_mongodb_auth() {
    local port=$1
    local timeout=$2
    local count=0

    echo "Waiting for MongoDB with auth (timeout: ${timeout}s)..."
    until mongosh --port "$port" \
        -u "$MONGO_INITDB_ROOT_USERNAME" \
        -p "$MONGO_INITDB_ROOT_PASSWORD" \
        --authenticationDatabase admin \
        --eval "db.adminCommand('ping')" > /dev/null 2>&1; do
        sleep 1
        count=$((count + 1))
        if [ $count -ge $timeout ]; then
            echo "ERROR: MongoDB auth connection failed within ${timeout} seconds"
            return 1
        fi
    done
    return 0
}

# Initialize MongoDB if not already done
if [ ! -f "$INIT_MARKER" ]; then
    echo "Initializing MongoDB..."

    # Start MongoDB temporarily without auth to initialize
    mongod --dbpath "$DATA_DIR" --port "$MONGODB_PORT" --bind_ip_all &
    MONGOD_PID=$!

    if ! wait_for_mongodb "$MONGODB_PORT" "$STARTUP_TIMEOUT"; then
        kill $MONGOD_PID 2>/dev/null || true
        exit 1
    fi

    # Create root user using environment variables in JavaScript to avoid injection
    echo "Creating root user..."
    mongosh --port "$MONGODB_PORT" --eval '
        db = db.getSiblingDB("admin");
        db.createUser({
            user: process.env.MONGO_INITDB_ROOT_USERNAME,
            pwd: process.env.MONGO_INITDB_ROOT_PASSWORD,
            roles: ["root"]
        });
    '

    # Shutdown temporary instance
    echo "Stopping temporary instance..."
    kill $MONGOD_PID 2>/dev/null || true
    wait $MONGOD_PID 2>/dev/null || true
    sleep 2

    touch "$INIT_MARKER"
fi

# Function to initialize replica set (runs in background)
init_replica_set() {
    # Wait for MongoDB with authentication to be ready
    if ! wait_for_mongodb_auth "$MONGODB_PORT" "$REPLICA_SET_TIMEOUT"; then
        echo "WARNING: Could not connect to MongoDB for replica set initialization"
        return 1
    fi

    echo "Checking replica set status..."
    REPLICA_SET_STATUS=$(mongosh --port "$MONGODB_PORT" \
        -u "$MONGO_INITDB_ROOT_USERNAME" \
        -p "$MONGO_INITDB_ROOT_PASSWORD" \
        --authenticationDatabase admin \
        --quiet \
        --eval "try { rs.status().ok } catch(e) { 0 }" 2>/dev/null || echo "0")

    if [ "$REPLICA_SET_STATUS" != "1" ]; then
        echo "Initializing replica set..."
        # Use environment variables in JavaScript to avoid injection
        export MONGODB_REPLICA_SET MONGODB_HOSTNAME MONGODB_ADVERTISED_PORT
        mongosh --port "$MONGODB_PORT" \
            -u "$MONGO_INITDB_ROOT_USERNAME" \
            -p "$MONGO_INITDB_ROOT_PASSWORD" \
            --authenticationDatabase admin \
            --eval '
                rs.initiate({
                    _id: process.env.MONGODB_REPLICA_SET,
                    members: [{
                        _id: 0,
                        host: process.env.MONGODB_HOSTNAME + ":" + process.env.MONGODB_ADVERTISED_PORT
                    }]
                });
            '
        echo "Replica set initialized"
    else
        echo "Replica set already initialized"
    fi
}

# Start replica set init in background
init_replica_set &

# Start MongoDB in foreground with replica set configuration
echo "Starting MongoDB with replica set '$MONGODB_REPLICA_SET' on port $MONGODB_PORT..."
exec mongod \
    --dbpath "$DATA_DIR" \
    --port "$MONGODB_PORT" \
    --bind_ip_all \
    --replSet "$MONGODB_REPLICA_SET" \
    --keyFile "$KEYFILE"
