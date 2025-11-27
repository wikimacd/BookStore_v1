#!/bin/bash

# Quick Docker Compose Fix Script
# Kills port 9092 process and restarts all services

echo "🔧 Quick Fix: Restarting Docker Compose services..."

# Kill process on port 9092 (Kafka port)
echo "📌 Freeing port 9092..."
lsof -ti:9092 | xargs kill -9 2>/dev/null || echo "   Port 9092 already free"

# Stop all services
echo "🛑 Stopping services..."
docker-compose down

# Start all services
echo "🚀 Starting all services..."
docker-compose up -d

# Show status
echo ""
echo "✅ Services started! Checking status..."
sleep 3
docker-compose ps

echo ""
echo "📝 View logs: docker-compose logs -f"
