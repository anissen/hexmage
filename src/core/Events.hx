
package core;

typedef MinionMovedEventData = { minionId :Int, from :Point, to :Point };

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
