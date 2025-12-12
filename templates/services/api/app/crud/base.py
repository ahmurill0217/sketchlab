from typing import Generic, Type, TypeVar

from sqlmodel import Session, select

from app.models import Base

ModelType = TypeVar("ModelType", bound=Base)


class CRUDBase(Generic[ModelType]):
    def __init__(self, model: Type):
        self.model = model

    def add(self, db: Session, obj_in: ModelType) -> ModelType:
        db.add(obj_in)
        db.commit()
        db.refresh(obj_in)
        return obj_in

    def get(self, db: Session, id: int) -> ModelType:
        return db.get(self.model, id)

    def get_by(self, db: Session, params: dict) -> ModelType:
        statement = select(self.model)

        for k, v in params.items():
            statement = statement.where(getattr(self.model, k) == v)

        return db.exec(statement).first()

    def all(
        self,
        db: Session,
        params: dict = None,
        sort: str = None,
        offset: int = 0,
        limit: int = 100,
    ) -> list[ModelType]:
        statement = select(self.model).limit(limit).offset(offset)
        if params:
            for k, v in params.items():
                statement = statement.where(getattr(self.model, k) == v)

        if sort:
            sort_keys = sort.split(",")
            for sort_key in sort_keys:
                if sort_key[0] == "-":
                    statement = statement.order_by(
                        getattr(self.model, sort_key[1:]).desc()
                    )
                else:
                    statement = statement.order_by(getattr(self.model, sort_key))

        return db.exec(statement).all()

    def delete(self, db: Session, id: int) -> ModelType:
        obj = db.get(self.model, id)
        db.delete(obj)
        db.commit()
        return obj
