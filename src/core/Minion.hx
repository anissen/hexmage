

package core;

import core.Rules;

typedef MinionOptions = { 
    player: Player, 
    id :Int, 
    name :String, 
    attack :Int, 
    life :Int, 
    rules :Rules,
    movesLeft :Int,
    attacksLeft :Int
};

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
