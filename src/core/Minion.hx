

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
    can_attack :Bool,
    ?on_death: Minion -> Void
};

class Minion {
    public var player :Player; 
    public var id :Int; 
    public var name :String; 
    public var attack :Int; 
    public var life :Int; 
    public var rules :Rules;
    public var moves: Int;
    public var movesLeft :Int;
    public var attacks: Int;
    public var attacksLeft :Int;
    public var can_be_damaged :Bool;
    public var can_move :Bool;
    public var can_attack :Bool;
    public var on_death :Minion -> Void;

    public function new(options :MinionOptions) {
        player = options.player;
        id = options.id;
        name = options.name;
        attack = options.attack;
        life = options.life;
        rules = options.rules;
        moves = options.moves;
        movesLeft = options.movesLeft;
        attacks = options.attacks;
        attacksLeft = options.attacksLeft;
        can_be_damaged = options.can_be_damaged;
        can_move = options.can_move;
        can_attack = options.can_attack;
        on_death = options.on_death;
    }

    public function damage(amount :Int, source :Minion /* TODO: Should be supertype, Entity */) :Bool {
        if (!can_be_damaged) return false;
        life -= amount;
        return true;
    }

    public function clone() :Minion {
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
            can_attack: this.can_attack,
            on_death: this.on_death
        });
    }
    
    public function equals(other :Minion) :Bool {
        return (other != null && other.id == id);
    }

    public function toString() :String {
        return '[${this.name} (${this.attack}/${this.life}, ${this.attacksLeft}/${this.attacks} attacks and ${this.movesLeft}/${this.moves} moves) owner: ${this.player.name}]';
    }
}
