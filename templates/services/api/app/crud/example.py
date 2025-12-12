from sqlmodel import Session, select
from app.crud.base import CRUDBase
from app.models import Example


class CRUDExample(CRUDBase[Example]):

    def get_all(self, db: Session) -> Example:
        statement = select(Example)
        result = db.execute(statement).scalars().all()
        return result

example = CRUDExample(Example)
