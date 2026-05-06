# Makefile for ByteLock OS Development

.PHONY: help setup install test lint format clean docker docker-up docker-down k8s-deploy

help:
	@echo "ByteLock OS - Development Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup          - Complete environment setup"
	@echo "  make install        - Install Python & Rust dependencies"
	@echo ""
	@echo "Development:"
	@echo "  make dev            - Start development environment"
	@echo "  make test           - Run all tests"
	@echo "  make test-python    - Run Python tests only"
	@echo "  make test-rust      - Run Rust tests only"
	@echo "  make lint           - Lint all code"
	@echo "  make format         - Format code (black, cargo fmt)"
	@echo ""
	@echo "Docker:"
	@echo "  make docker         - Build Docker images"
	@echo "  make docker-up      - Start Docker Compose services"
	@echo "  make docker-down    - Stop Docker Compose services"
	@echo "  make docker-logs    - View Docker logs"
	@echo ""
	@echo "Kubernetes:"
	@echo "  make k8s-deploy     - Deploy to Kubernetes"
	@echo "  make k8s-status     - Check deployment status"
	@echo "  make k8s-logs       - View K8s logs"
	@echo ""
	@echo "Cleaning:"
	@echo "  make clean          - Remove build artifacts"
	@echo "  make clean-docker   - Remove Docker containers/volumes"
	@echo ""

setup:
	@echo "🚀 Setting up ByteLock OS..."
	./scripts/setup.sh
	@echo "✅ Setup complete!"

install:
	@echo "📦 Installing dependencies..."
	python3 -m venv venv
	. venv/bin/activate && pip install -r requirements.txt
	cargo build --release --workspace
	@echo "✅ Dependencies installed!"

dev:
	@echo "🔧 Starting development environment..."
	docker-compose -f infrastructure/docker/docker-compose.yml up -d
	@echo "✅ Services running at:"
	@echo "   - Dashboard: http://localhost:3000"
	@echo "   - Dashboard API: http://localhost:8000"
	@echo "   - AI Engine: http://localhost:8001"
	@echo "   - Kafka UI: http://localhost:8888"

test: test-python test-rust
	@echo "✅ All tests passed!"

test-python:
	@echo "🧪 Running Python tests..."
	pytest tests/ -v --cov=ai_engine --cov=ui_dashboard

test-rust:
	@echo "🦀 Running Rust tests..."
	cargo test --workspace

test-integration:
	@echo "🔗 Running integration tests..."
	docker-compose -f infrastructure/docker/docker-compose.yml up -d
	sleep 10
	pytest tests/integration/ -v
	docker-compose -f infrastructure/docker/docker-compose.yml down

lint:
	@echo "🔍 Linting code..."
	flake8 ai-engine ui-dashboard
	cargo clippy --workspace --all-targets

format:
	@echo "✨ Formatting code..."
	black ai-engine ui-dashboard
	isort ai-engine ui-dashboard
	cargo fmt --all

clean:
	@echo "🧹 Cleaning up..."
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	rm -rf build/ dist/ *.egg-info
	cargo clean --release
	@echo "✅ Cleaned!"

docker:
	@echo "🐳 Building Docker images..."
	docker-compose -f infrastructure/docker/docker-compose.yml build --no-cache
	@echo "✅ Images built!"

docker-up:
	@echo "▶️  Starting Docker Compose..."
	docker-compose -f infrastructure/docker/docker-compose.yml up -d
	@echo "✅ Services running!"

docker-down:
	@echo "⏹️  Stopping Docker Compose..."
	docker-compose -f infrastructure/docker/docker-compose.yml down
	@echo "✅ Services stopped!"

docker-logs:
	@echo "📋 Docker logs..."
	docker-compose -f infrastructure/docker/docker-compose.yml logs -f

docker-clean:
	@echo "🧹 Removing Docker data..."
	docker-compose -f infrastructure/docker/docker-compose.yml down -v
	docker system prune -f
	@echo "✅ Cleaned!"

k8s-deploy:
	@echo "🚀 Deploying to Kubernetes..."
	kubectl apply -f infrastructure/kubernetes/deployment.yaml
	@echo "✅ Deployed!"

k8s-status:
	@echo "📊 Kubernetes deployment status..."
	kubectl get all -n bytelock-os

k8s-logs:
	@echo "📋 Kubernetes logs..."
	kubectl logs -n bytelock-os -l app=ai-engine -f

k8s-delete:
	@echo "❌ Deleting Kubernetes deployment..."
	kubectl delete -f infrastructure/kubernetes/deployment.yaml
	@echo "✅ Deleted!"

docs:
	@echo "📚 Building documentation..."
	cd docs && sphinx-build -b html . _build
	@echo "✅ Docs built! Open docs/_build/index.html"

docs-serve:
	@echo "🌐 Serving documentation..."
	python -m http.server --directory docs/_build 8888

.DEFAULT_GOAL := help
