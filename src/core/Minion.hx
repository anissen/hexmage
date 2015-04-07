

package core;

import core.Events;

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
    ?id :Int,
    ?player :Player,
    name :String,
    ?attack :Int,
    ?life :Int,
    //?rules :Rules,
    ?moves: Int,
    ?movesLeft :Int,
    ?attacks: Int,
    ?attacksLeft :Int,
    ?can_be_damaged :Bool,
    ?can_move :Bool,
    ?can_attack :Bool,
    //?on_death :Void -> Commands,
    ?on_event :Map<Event, Void -> Commands>
};

class Minion {
    static var Id :Int = 0;
    public var id :Int;

    public var player :Player;
    public var name :String;
    public var attack :Int;
    public var life :Int;
    //public var rules :Rules;
    public var moves: Int;
    public var movesLeft :Int;
    public var attacks: Int;
    public var attacksLeft :Int;
    public var can_be_damaged :Bool;
    public var can_move :Bool;
    public var can_attack :Bool;
    //public var on_death :Void -> Commands;

    public var on_event :Map<Event, Void -> Commands>;

    public function new(options :MinionOptions) {
        id               = (options.id != null ? options.id : Id++);

        player           = options.player;
        name             = options.name;
        attack           = (options.attack != null ? options.attack : 1);
        life             = (options.life != null ? options.life : 1);
        moves            = (options.moves != null ? options.moves : 1);
        movesLeft        = (options.movesLeft != null ? options.movesLeft : moves);
        attacks          = (options.attacks != null ? options.attacks : 1);
        attacksLeft      = (options.attacksLeft != null ? options.attacksLeft : attacks);
        can_be_damaged   = (options.can_be_damaged != null ? options.can_be_damaged : true);
        can_move         = (options.can_move != null ? options.can_move : true);
        can_attack       = (options.can_attack != null ? options.can_attack : true);

        on_event = (options.on_event != null ? options.on_event : new Map<Event, Void -> Commands>());
    }

    public function handle_event(event :Event) :Commands {
        var event_func = on_event.get(event);
        if (event_func == null) return [];
        return event_func();
    }

    public function createNew(player :Player) :Minion {
        var minion = clone();
        minion.id = Id++;
        minion.player = player;
        return minion;
    }

    public function clone() :Minion {
        return new Minion({
            id: this.id,
            player: this.player, // TODO: Is clone() necessesary here?
            name: this.name,
            attack: this.attack,
            life: this.life,
            moves: this.moves,
            movesLeft: this.movesLeft,
            attacks: this.attacks,
            attacksLeft: this.attacksLeft,
            can_be_damaged: this.can_be_damaged,
            can_move: this.can_move,
            can_attack: this.can_attack,
            on_event: this.on_event
        });
    }

    public function equals(other :Minion) :Bool {
        return (other != null && other.id == id);
    }

    // public function toString() :String {
    //     return '[$name ($attack/$life, $attacksLeft/$attacks attacks and $movesLeft/$moves moves) owner: ${player.name}]';
    // }
}
