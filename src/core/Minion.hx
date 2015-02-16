

package core;

import core.Rules;

// enum Property {
//     Life;
//     Attack;
//     Moves;
//     CanMove;
//     CanBeDamaged;
// }

typedef Properties = {
    ?life :Int,
    ?attack :Int,
    ?can_be_damaged :Bool,
    ?can_move :Bool
    // ...
};

// There should be a default Property map defined in the ruleset!

typedef MinionOptions = { 
    player :Player, 
    id :Int, 
    name :String, 
    attack :Int, 
    life :Int, 
    rules :Rules,
    moves: Int,
    movesLeft :Int,
    attacks: Int,
    attacksLeft :Int,
    properties :Properties
};

@:forward
abstract Minion(MinionOptions) from MinionOptions to MinionOptions {
    inline public function new(m :MinionOptions) {
        this = m;
    }

    inline public function clone() :Minion {
        return new Minion({ 
            id: this.id, 
            player: this.player.clone(), 
            name: this.name, 
            attack: this.attack, 
            life: this.life, 
            rules: this.rules,
            moves: this.moves,
            movesLeft: this.movesLeft,
            attacks: this.attacks,
            attacksLeft: this.attacksLeft,
            properties: this.properties
        });
    }
    
    @:op(A == B)
    inline static public function equals(lhs :Minion, rhs :Minion) :Bool {
        return (lhs == null && rhs == null) || (lhs != null && rhs != null && lhs.id == rhs.id);
    }

    @:toString
    inline public function toString() :String {
        return '[${this.name} (${this.attack}/${this.life}, ${this.attacksLeft}/${this.attacks} attacks and ${this.movesLeft}/${this.moves} moves) owner: ${this.player.name}]';
    }
}
