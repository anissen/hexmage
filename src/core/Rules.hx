
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

enum Event {
    CardDrawn;
    SelfEntered;
}
typedef Events = Array<Event>;

// typedef Rule = { trigger :RuleTrigger, effect :RuleEffect };
typedef Rules = Array<Effect>;
