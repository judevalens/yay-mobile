from dataclasses import dataclass
from typing import List

from data.user import User


@dataclass
class Room:
    roomId: str
    roomLeader: str
    members: List[str]
    socketID: str
    currentSong: str
    currentSongPosition: str
