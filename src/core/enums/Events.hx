
package core.enums;

import core.TileId; // For TileId -- TODO: REMOVE

typedef MinionMovedData = { minion :Minion, from :TileId, to :TileId };
typedef MinionAttackedData = { minion :Minion, victim :Minion };
typedef MinionDiedData = { minion :Minion };
typedef MinionDamagedData = { minion :Minion, damage :Int };
typedef MinionEnteredData = { minion :Minion };
typedef PlayerEnteredData = { player :Player };
typedef TurnStartedData = { player :Player };
typedef TurnEndedData = { player :Player };
typedef PlayersTurnData = { player :Player };
typedef CardDrawnData = { card :Card, player :Player };
typedef CardPlayedData = { card :Card, player :Player };
typedef ManaGainedData = { gained :Int, total :Int, tileId :TileId, player :Player };
typedef ManaSpentData = { spent :Int, left :Int, tileId :TileId, player :Player };
typedef TileClaimedData = { tileId :TileId, minion :Minion };

enum Event {
    GameStarted;
    TurnStarted(data :TurnStartedData);
    TurnEnded(data :TurnEndedData);
    GameOver;
    CardDrawn(data :CardDrawnData);
    CardPlayed(data :CardPlayedData);
    // SelfEntered;
    MinionMoved(data :MinionMovedData);
    MinionDied(data :MinionDiedData);
    MinionAttacked(data :MinionAttackedData);
    MinionDamaged(data :MinionDamagedData);
    PlayersTurn(data :PlayersTurnData);
    
    ManaGained(data :ManaGainedData);
    ManaSpent(data :ManaSpentData);
    TileClaimed(data :TileClaimedData);
    TileReclaimed(data :TileClaimedData);

    PlayerEntered(data :PlayerEnteredData); // also triggered on game start 
    MinionEntered(data :MinionEnteredData); // also triggered on game start (minions should be added *after* initial setup)
}

enum MinionEvent {
    Always;
    Died;
}

typedef Events = Array<Event>;
