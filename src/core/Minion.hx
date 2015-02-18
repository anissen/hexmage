

package core;

import core.Rules;

// enum Property {
//     Life;
//     Attack;
//     Moves;
//     CanMove;
//     CanBeDamaged;
// }

/*
class Tag {
    var _value :Int;
    public var value(get, set) :Int;
    
    var _enabled :Bool;
    public var enabled(get, set) :Bool;
    
    var listeners :List<Int -> Void>;

    public function new(_value :Int, _enabled :Bool = true) {
        this._value = _value;
        this._enabled = _enabled;
        listeners = new List<Int -> Void>();
    }
    
    public function get_value() :Int {
        return (_enabled ? _value : 0);
    }

    public function set_value(_value :Int) :Int {
        if (this._value == _value) return _value;
        this._value = _value;
        for (listener in listeners)
            listener(value);
        return _value;
    }

    public function get_enabled() :Bool {
        return this._enabled;
    }

    public function set_enabled(_enabled :Bool) :Bool {
        if (this._enabled == _enabled) return enabled;
        this._enabled = _enabled;
        for (listener in listeners)
            listener(value);
        return _enabled;
    }

    public function listen(listener :Int -> Void) {
        listeners.add(listener);
    }
}

typedef Properties = {
    ?life :Int,
    ?attack :Int,
    ?can_be_damaged :Bool,
    ?can_move :Bool,
    // ...
    moves: Tag
};
*/

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
    can_be_damaged :Bool,
    can_move :Bool,
    can_attack :Bool
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
            can_be_damaged: this.can_be_damaged,
            can_move: this.can_move,
            can_attack: this.can_attack
            // properties: this.properties
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
