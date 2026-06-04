from pydantic_settings import BaseSettings, SettingsConfigDict
from functools import lru_cache


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file="../.env",
        extra="ignore",
        protected_namespaces=("settings_",),
    )

    supabase_url: str = ""
    supabase_anon_key: str = ""
    supabase_service_key: str = ""

    gemini_api_key: str = ""

    secret_key: str = "change-me"
    allowed_origins: str = "http://localhost,http://10.0.2.2"

    model_path: str = "./models/salary_model.pkl"
    encoder_path: str = "./models/label_encoders.pkl"
    hf_dataset: str = "azrai99/job-dataset"

    chroma_persist_dir: str = "./chroma_db"
    chroma_collection: str = "wagewise_legal_docs"

    app_env: str = "development"
    log_level: str = "info"

    @property
    def cors_origins(self) -> list[str]:
        return [o.strip() for o in self.allowed_origins.split(",")]


@lru_cache
def get_settings() -> Settings:
    return Settings()
