
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

// typedef Rule = { trigger :RuleTrigger, effect :RuleEffect };
typedef Rules = Array<Effect>;
