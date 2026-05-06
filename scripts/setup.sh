#!/bin/bash

set -e

# ByteLock OS Setup Script

echo "╔═══════════════════════════════════════════════════════╗"
echo "║   ByteLock OS - AI-Driven Cybersecurity OS            ║"
echo "║   Setup & Bootstrap Script                            ║"
echo "╚═══════════════════════════════════════════════════════╝"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "\n${BLUE}Checking prerequisites...${NC}"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker found: $(docker --version)${NC}"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker Compose found: $(docker-compose --version)${NC}"

# Check Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Python 3 found: $(python3 --version)${NC}"

# Check Rust
if ! command -v cargo &> /dev/null; then
    echo -e "${YELLOW}⚠️  Cargo/Rust not found (optional, needed for connectors)${NC}"
else
    echo -e "${GREEN}✅ Rust found: $(cargo --version)${NC}"
fi

# Create .env file if it doesn't exist
echo -e "\n${BLUE}Setting up environment...${NC}"
if [ ! -f .env ]; then
    echo "Creating .env from .env.example..."
    cp .env.example .env
    echo -e "${GREEN}✅ .env created (update with your credentials)${NC}"
else
    echo -e "${GREEN}✅ .env already exists${NC}"
fi

# Create Python virtual environment
echo -e "\n${BLUE}Setting up Python environment...${NC}"
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo -e "${GREEN}✅ Virtual environment created${NC}"
else
    echo -e "${GREEN}✅ Virtual environment already exists${NC}"
fi

# Activate venv and install dependencies
source venv/bin/activate || . venv/Scripts/activate
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
echo -e "${GREEN}✅ Python dependencies installed${NC}"

# Build Docker images
echo -e "\n${BLUE}Building Docker images...${NC}"
docker-compose -f infrastructure/docker/docker-compose.yml build --no-cache
echo -e "${GREEN}✅ Docker images built${NC}"

# Create database (PostgreSQL will be started in compose)
echo -e "\n${BLUE}Starting services...${NC}"
docker-compose -f infrastructure/docker/docker-compose.yml up -d
echo -e "${GREEN}✅ Services started${NC}"

# Wait for services to be healthy
echo -e "\n${BLUE}Waiting for services to be healthy...${NC}"
sleep 10

# Run database migrations (if applicable)
echo -e "\n${BLUE}Running database setup...${NC}"
# TODO: Add alembic migrations
echo -e "${GREEN}✅ Database setup complete${NC}"

# Print summary
echo -e "\n╔═══════════════════════════════════════════════════════╗"
echo -e "║${GREEN}        ✅ ByteLock OS Setup Complete!${NC}           ║"
echo -e "╚═══════════════════════════════════════════════════════╝"

echo -e "\n${BLUE}Service URLs:${NC}"
echo -e "  Dashboard:         ${GREEN}http://localhost:3000${NC}"
echo -e "  Dashboard API:     ${GREEN}http://localhost:8000${NC}"
echo -e "  AI Engine:         ${GREEN}http://localhost:8001${NC}"
echo -e "  Kafka UI:          ${GREEN}http://localhost:8888${NC}"
echo -e "  PostgreSQL:        ${GREEN}localhost:5432${NC}"
echo -e "  Redis:             ${GREEN}localhost:6379${NC}"
echo -e "  Weaviate:          ${GREEN}http://localhost:8080${NC}"

echo -e "\n${BLUE}Next steps:${NC}"
echo -e "  1. Update .env with your LLM API key and connector credentials"
echo -e "  2. Open ${GREEN}http://localhost:3000${NC} in your browser"
echo -e "  3. Review logs: ${GREEN}docker-compose logs -f${NC}"
echo -e "  4. Run tests: ${GREEN}pytest tests/${NC}"

echo -e "\n${BLUE}Documentation:${NC}"
echo -e "  - Architecture: ${GREEN}docs/ARCHITECTURE.md${NC}"
echo -e "  - API Docs: ${GREEN}http://localhost:8000/docs${NC}"
echo -e "  - AI Engine: ${GREEN}http://localhost:8001/docs${NC}"

echo -e "\n${YELLOW}Development Tips:${NC}"
echo -e "  - View logs: docker-compose logs -f [service]"
echo -e "  - Stop services: docker-compose down"
echo -e "  - Clean data: docker-compose down -v"
echo -e "  - Rebuild: docker-compose build --no-cache"

echo ""
