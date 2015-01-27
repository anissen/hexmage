
package core;

typedef MoveAction = { minionId :Int, pos :Point };
typedef AttackAction = { minionId :Int, victimId :Int };

enum Action {
    // EndTurn();
    Move(p :MoveAction);
    Attack(a :AttackAction);
}