
package core;

typedef MinionMovedData = { minionId :Int, from :Point, to :Point };
typedef MinionAttackedData = { minionId :Int, victimId :Int };
typedef MinionDiedData = { minionId :Int };
typedef MinionDamagedData = { minionId :Int, damage :Int };
typedef MinionEnteredData = { minionId :Int };
typedef PlayerEnteredData = { playerId :Int };

enum Event {
    GameStarted;
    TurnStarted;
    TurnEnded;
    GameOver;
    CardDrawn;
    SelfEntered;
    MinionMoved(data :MinionMovedData);
    MinionDied(data :MinionDiedData);
    MinionAttacked(data :MinionAttackedData);
    MinionDamaged(data :MinionDamagedData);
    PlayersTurn;

    PlayerEntered(data :PlayerEnteredData); // also triggered on game start 
    MinionEntered(data :MinionEnteredData); // also triggered on game start (minions should be added *after* initial setup)
}

typedef Events = Array<Event>;
