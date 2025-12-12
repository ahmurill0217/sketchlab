from sqlmodel import SQLModel, Session, create_engine
from app.core.config import settings

engine = create_engine(str(settings.DATABASE_URL))

def get_db() -> Session:
    with Session(engine) as session:
        yield session


def init_db(session: Session) -> None:

    # SQLModel.metadata.drop_all(engine)
    SQLModel.metadata.create_all(engine)
