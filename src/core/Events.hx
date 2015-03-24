
package core;

typedef MinionMovedEventData = { minionId :Int, from :Point, to :Point };
typedef MinionDiedEventData = { minionId :Int };

enum Event {
    TurnStarted;
    TurnEnded;
    GameOver;
    CardDrawn;
    SelfEntered;
    MinionMoved;
    MinionDied;
}

typedef Events = Array<Event>;
