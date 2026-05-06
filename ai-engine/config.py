"""
Configuration management for AI Engine.
"""

from pydantic_settings import BaseSettings
from typing import List
import os


class Settings(BaseSettings):
    """Application settings from environment variables."""
    
    # Kafka
    kafka_bootstrap_servers: str = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092")
    
    # Database
    database_url: str = os.getenv("DATABASE_URL", "postgresql://postgres:password@localhost:5432/bytelock_os")
    redis_url: str = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    
    # Vector DB
    vector_db_url: str = os.getenv("VECTOR_DB_URL", "http://localhost:8080")
    vector_db_api_key: str = os.getenv("VECTOR_DB_API_KEY", "")
    
    # LLM
    llm_provider: str = os.getenv("LLM_PROVIDER", "anthropic")
    llm_api_key: str = os.getenv("LLM_API_KEY", "")
    llm_model: str = os.getenv("LLM_MODEL", "claude-3-haiku-20240307")
    llm_temperature: float = float(os.getenv("LLM_TEMPERATURE", "0.7"))
    llm_max_tokens: int = int(os.getenv("LLM_MAX_TOKENS", "2048"))
    
    # Safety & Cost
    cost_threshold: float = float(os.getenv("COST_THRESHOLD", "50"))
    enable_multi_agent_debate: bool = os.getenv("ENABLE_MULTI_AGENT_DEBATE", "true").lower() == "true"
    debate_turn_limit: int = int(os.getenv("DEBATE_TURN_LIMIT", "2"))
    enable_memory_poisoning_defense: bool = os.getenv("ENABLE_MEMORY_POISONING_DEFENSE", "true").lower() == "true"
    
    # API
    api_port: int = int(os.getenv("API_PORT", "8001"))
    cors_origins: List[str] = [
        "http://localhost:3000",
        "http://localhost:3001",
        "http://localhost:8000",
    ]
    
    # Logging
    log_level: str = os.getenv("LOG_LEVEL", "INFO")
    debug_mode: bool = os.getenv("DEBUG_MODE", "false").lower() == "true"
    
    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()
