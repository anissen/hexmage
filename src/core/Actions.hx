
package core;

typedef MoveAction = { 
    minionId :Int,
    pos :Point
}

typedef AttackAction = {
    minionId :Int,
    victimId :Int
}

typedef PlayCardAction = {
    card :Card,
    target :Point
    //targets :Array<Point>
}

typedef Actions = Array<Action>;

enum Action {
    NoAction();
    Move(p :MoveAction);
    Attack(a :AttackAction);
    PlayCard(c :PlayCardAction);
}
