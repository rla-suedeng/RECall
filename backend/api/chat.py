from fastapi import FastAPI, HTTPException, Depends, Header
from typing import Annotated

from RECall import schemas
from RECall.api.deps import get_current_user

CurrentUser = Annotated[schemas.UserInfo, Depends(get_current_user)]