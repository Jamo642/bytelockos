"""
ByteLock OS - AI Engine Main Application

Orchestrates correlation, multi-agent debate, and threat analysis.
"""

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
import logging
from contextlib import asynccontextmanager

from .config import settings
from .kafka_bus import KafkaBus
from .correlation import CorrelationEngine
from .multi_agent import MultiAgentDebate

# Configure logging
logging.basicConfig(level=settings.log_level)
logger = logging.getLogger(__name__)

# Global instances
kafka_bus = None
correlation_engine = None
multi_agent_debate = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events."""
    global kafka_bus, correlation_engine, multi_agent_debate
    
    # Startup
    logger.info("🚀 Starting ByteLock OS AI Engine...")
    kafka_bus = KafkaBus(settings.kafka_bootstrap_servers)
    correlation_engine = CorrelationEngine(kafka_bus)
    multi_agent_debate = MultiAgentDebate(settings.llm_provider)
    
    await kafka_bus.connect()
    await correlation_engine.start()
    
    logger.info("✅ AI Engine initialized successfully")
    
    yield
    
    # Shutdown
    logger.info("🛑 Shutting down AI Engine...")
    await correlation_engine.stop()
    await kafka_bus.disconnect()
    logger.info("✅ AI Engine shutdown complete")


# Create FastAPI app
app = FastAPI(
    title="ByteLock OS - AI Engine",
    description="Central AI orchestration for threat correlation and multi-agent debate",
    version="0.1.0",
    lifespan=lifespan,
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Routes
@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "service": "ai-engine",
        "version": "0.1.0",
    }


@app.get("/threats")
async def get_active_threats():
    """Get currently active threats from correlation engine."""
    if not correlation_engine:
        raise HTTPException(status_code=503, detail="Correlation engine not initialized")
    
    threats = await correlation_engine.get_active_threats()
    return {
        "count": len(threats),
        "threats": threats,
    }


@app.post("/analyze")
async def analyze_event(event: dict):
    """Submit raw event for analysis and correlation."""
    if not correlation_engine:
        raise HTTPException(status_code=503, detail="Correlation engine not initialized")
    
    result = await correlation_engine.analyze(event)
    return result


@app.post("/debate")
async def trigger_debate(analysis: dict):
    """Trigger multi-agent debate on high-confidence threat."""
    if not multi_agent_debate:
        raise HTTPException(status_code=503, detail="Multi-agent debate not initialized")
    
    debate_result = await multi_agent_debate.debate(analysis)
    return debate_result


@app.get("/metrics")
async def get_metrics():
    """Get AI engine performance metrics."""
    if not correlation_engine:
        raise HTTPException(status_code=503, detail="Correlation engine not initialized")
    
    metrics = await correlation_engine.get_metrics()
    return metrics


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
