"""
Kafka Event Bus - Central Nervous System
"""

import asyncio
from kafka import KafkaConsumer, KafkaProducer
from kafka.errors import KafkaError
import json
import logging

logger = logging.getLogger(__name__)


class KafkaBus:
    """Manages Kafka connectivity and pub/sub."""
    
    def __init__(self, bootstrap_servers: str):
        self.bootstrap_servers = bootstrap_servers
        self.producer = None
        self.consumers = {}
        
    async def connect(self):
        """Initialize Kafka producer."""
        try:
            self.producer = KafkaProducer(
                bootstrap_servers=self.bootstrap_servers,
                value_serializer=lambda v: json.dumps(v).encode('utf-8'),
                acks='all',
                retries=3,
            )
            logger.info(f"✅ Connected to Kafka: {self.bootstrap_servers}")
        except Exception as e:
            logger.error(f"❌ Failed to connect to Kafka: {e}")
            raise
    
    async def disconnect(self):
        """Shutdown Kafka producer."""
        if self.producer:
            self.producer.close()
            logger.info("Kafka producer closed")
    
    async def publish(self, topic: str, event: dict):
        """Publish event to Kafka topic."""
        if not self.producer:
            raise RuntimeError("Kafka producer not initialized")
        
        try:
            future = self.producer.send(topic, value=event)
            await asyncio.to_thread(future.get, timeout=10)
            logger.debug(f"📤 Published to {topic}: {event.get('event_id', 'unknown')}")
        except KafkaError as e:
            logger.error(f"❌ Failed to publish to {topic}: {e}")
            raise
    
    async def subscribe(self, topic: str, callback):
        """Subscribe to Kafka topic and call callback for each message."""
        def message_handler():
            consumer = KafkaConsumer(
                topic,
                bootstrap_servers=self.bootstrap_servers,
                value_deserializer=lambda m: json.loads(m.decode('utf-8')),
                group_id='bytelock-ai-engine',
                auto_offset_reset='earliest',
            )
            
            for message in consumer:
                asyncio.create_task(callback(message.value))
        
        # Run consumer in background thread
        await asyncio.to_thread(message_handler)
