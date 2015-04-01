
package core;

typedef MinionMovedEventData = { minionId :Int, from :Point, to :Point };
typedef MinionAttackedEventData = { minionId :Int, victimId :Int };
typedef MinionDiedEventData = { minionId :Int };

enum Event {
    TurnStarted;
    TurnEnded;
    GameOver;
    CardDrawn;
    SelfEntered;
    MinionMoved;
    MinionDied;
    MinionAttacked;
}

typedef Events = Array<Event>;
