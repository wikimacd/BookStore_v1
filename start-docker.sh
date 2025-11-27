#!/bin/bash

# BookStore Docker Compose Startup Script
# This script handles port conflicts and ensures proper service startup order

set -e

echo "🚀 Starting BookStore Application..."
echo ""

# Function to check if port is in use
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        return 0  # Port is in use
    else
        return 1  # Port is free
    fi
}

# Function to kill process on port
kill_port() {
    local port=$1
    echo "⚠️  Port $port is in use. Attempting to free it..."
    local pid=$(lsof -ti:$port)
    if [ ! -z "$pid" ]; then
        echo "   Killing process $pid on port $port"
        kill -9 $pid 2>/dev/null || true
        sleep 2
    fi
}

# Check and free critical ports
echo "📋 Checking port availability..."
PORTS=(3000 5432 6379 8080 9092 9093)
for port in "${PORTS[@]}"; do
    if check_port $port; then
        echo "   Port $port is in use"
        read -p "   Kill process on port $port? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kill_port $port
        else
            echo "   ⚠️  Warning: Port $port conflict may cause startup issues"
        fi
    else
        echo "   ✅ Port $port is available"
    fi
done

echo ""
echo "🧹 Cleaning up existing containers..."
docker-compose down

echo ""
echo "🏗️  Building images (this may take a few minutes)..."
docker-compose build

echo ""
echo "🚀 Starting services in order..."

# Start infrastructure services
echo "   📦 Starting infrastructure (PostgreSQL, Redis, Zookeeper)..."
docker-compose up -d postgres-db redis zookeeper postgres-client pgadmin
sleep 5

# Start Kafka
echo "   📨 Starting Kafka..."
docker-compose up -d kafka
echo "   ⏳ Waiting for Kafka to be healthy (30 seconds)..."
sleep 30

# Start application services
echo "   ☕ Starting Spring Boot backend..."
docker-compose up -d bookstore_springboot_app
echo "   ⏳ Waiting for backend to start (20 seconds)..."
sleep 20

# Start frontend and monitoring
echo "   🌐 Starting frontend and monitoring services..."
docker-compose up -d frontend prometheus grafana alertmanager

echo ""
echo "✅ All services started!"
echo ""
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "🌐 Access URLs:"
echo "   Frontend:        http://localhost:3000"
echo "   Backend API:     http://localhost:8080/api"
echo "   Backend Health:  http://localhost:8080/actuator/health"
echo "   pgAdmin:         http://localhost:5050 (admin@example.com / admin123)"
echo "   Grafana:         http://localhost:3001 (admin / admin123)"
echo "   Prometheus:      http://localhost:9090"
echo ""
echo "📝 Useful commands:"
echo "   View logs:       docker-compose logs -f"
echo "   Stop services:   docker-compose stop"
echo "   Restart:         docker-compose restart"
echo "   Clean shutdown:  docker-compose down"
echo ""
