
package core.enums;

typedef MinionMovedData = { minion :Minion, from :Point, to :Point };
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
typedef ManaSpentData = { spent :Int, player :Player };
typedef TileClaimedData = { tileId :Point, minion :Minion };

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
    
    ManaSpent(data :ManaSpentData);
    TileClaimed(data :TileClaimedData);
    TileReclaimed(data :TileClaimedData);

    PlayerEntered(data :PlayerEnteredData); // also triggered on game start 
    MinionEntered(data :MinionEnteredData); // also triggered on game start (minions should be added *after* initial setup)
}

enum MinionEvent {
    Died;
}

typedef Events = Array<Event>;
