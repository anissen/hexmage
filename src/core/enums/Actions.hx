
package core.enums;

typedef MoveActionData = { 
    minionId :Int,
    pos :Point
}

typedef AttackActionData = {
    minionId :Int,
    victimId :Int
}

typedef PlayCardActionData = {
    card :Card,
    target :Card.Target
}

typedef Actions = Array<Action>;

enum Action {
    // NoAction();
    MoveAction(p :MoveActionData);
    AttackAction(a :AttackActionData);
    PlayCardAction(c :PlayCardActionData);
}
