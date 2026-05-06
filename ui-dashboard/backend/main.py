"""
Dashboard Backend - FastAPI REST API for UI
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import logging
from contextlib import asynccontextmanager

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events."""
    logger.info("🚀 Dashboard Backend starting...")
    yield
    logger.info("🛑 Dashboard Backend shutdown")


app = FastAPI(
    title="ByteLock OS - Dashboard API",
    description="REST API for threat dashboard UI",
    version="0.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health():
    """Health check."""
    return {"status": "healthy"}


@app.get("/api/v1/dashboard")
async def get_dashboard_summary():
    """Get dashboard summary metrics."""
    return {
        "threats": {
            "critical": 2,
            "high": 5,
            "medium": 12,
            "low": 34,
        },
        "threat_actors": 3,
        "response_rate": 0.94,
        "uptime": 0.9999,
    }


@app.get("/api/v1/threats")
async def list_threats(status: str = "active"):
    """List threats with optional status filter."""
    # TODO: Query from database/Kafka
    return {
        "threats": [],
        "total": 0,
    }


@app.post("/api/v1/actions")
async def submit_action(action: dict):
    """Submit response action."""
    # TODO: Publish to Kafka and wait for result
    return {
        "action_id": "action-12345",
        "status": "pending_approval",
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
