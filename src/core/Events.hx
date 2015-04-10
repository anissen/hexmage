
package core;

typedef MinionMovedData = { minion :Minion, from :Point, to :Point };
typedef MinionAttackedData = { minion :Minion, victim :Minion };
typedef MinionDiedData = { minion :Minion };
typedef MinionDamagedData = { minion :Minion, damage :Int };
typedef MinionEnteredData = { minion :Minion };
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
