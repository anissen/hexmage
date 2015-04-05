
package core;

typedef MinionMovedData = { minionId :Int, from :Point, to :Point };
typedef MinionAttackedData = { minionId :Int, victimId :Int };
typedef MinionDiedData = { minionId :Int };

enum Event {
    TurnStarted;
    TurnEnded;
    GameOver;
    CardDrawn;
    SelfEntered;
    MinionMoved(data :MinionMovedData);
    MinionDied(data :MinionDiedData);
    MinionAttacked(data :MinionAttackedData);

    PlayerEntered; // also triggered on game start 
    MinionEntered; // also triggered on game start (minions should be added *after* initial setup)
}

typedef Events = Array<Event>;
