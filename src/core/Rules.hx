
package core;

// enum RuleTrigger {
//     OwnTurnStart;
// }
// enum RuleEffect {
//     Scripted(f :Board->Void);
// }
typedef Effect = {
    ?turn_ends :Minion -> Void
}

enum Command {
    DrawCards(count :Int);
    Print(s :String);
}
typedef Commands = Array<Command>;

typedef MoveEventData = { minionId :Int, from :Point, to :Point };

enum Event {
    TurnStarted;
    TurnEnded;
    GameOver;
    CardDrawn;
    SelfEntered;
    MinionMoved(?data :MoveEventData);
}
typedef Events = Array<Event>;

// typedef Rule = { trigger :RuleTrigger, effect :RuleEffect };
typedef Rules = Array<Effect>;
