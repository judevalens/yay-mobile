from dataclasses import dataclass
from typing import List

from data.Room import Room


@dataclass
class User:
    email: str
    isActive: bool
    activeRoomID: str
    rooms: List[Room]
