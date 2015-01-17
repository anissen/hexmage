

package core;

enum RuleTrigger {
    OwnTurnStart;
}
enum RuleEffect {
    Scripted(f :Board->Void);
}
typedef Rule = { trigger :RuleTrigger, effect :RuleEffect };
typedef Rules = Array<Rule>;

typedef Point = { x :Int, y :Int };

typedef MinionOptions = { player: Player, id :Int, name :String, attack :Int, life :Int, rules :Rules };

@:forward
abstract Minion(MinionOptions) from MinionOptions to MinionOptions {
    inline public function new(m :MinionOptions) {
        this = m;
    }
    
    @:op(A == B)
    inline static public function equals(lhs :Minion, rhs :Minion) :Bool {
        return (lhs == null && rhs == null) || (lhs != null && rhs != null && lhs.id == rhs.id);
    }

    @:toString
    inline public function toString() :String {
        return '[${this.name} (${this.attack}/${this.life}) owner: ${this.player.name}]';
    }
}
