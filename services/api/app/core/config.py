from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    app_name: str = "sketchlab"
    DOCS_URL: str = "/docs"
    DATABASE_URL: str = ""
    CLIENT_URL: str = "http://localhost:3000"
    OPENAI_API_KEY: str = ""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()
