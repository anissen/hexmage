
package core;

enum RuleTrigger {
    OwnTurnStart;
}
enum RuleEffect {
    Scripted(f :Board->Void);
}
typedef Rule = { trigger :RuleTrigger, effect :RuleEffect };
typedef Rules = Array<Rule>;
