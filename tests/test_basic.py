"""
Basic health check tests for the application
"""
import pytest


def test_imports():
    """Test that all main modules can be imported"""
    try:
        import ai_engine.main
        import ai_engine.config
        assert True
    except ImportError as e:
        pytest.fail(f"Failed to import ai_engine modules: {e}")


def test_config_loads():
    """Test that configuration loads correctly"""
    try:
        from ai_engine.config import Settings
        settings = Settings()
        assert settings is not None
    except Exception as e:
        pytest.fail(f"Failed to load configuration: {e}")


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
