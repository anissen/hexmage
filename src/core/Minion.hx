

package core;

import core.enums.Events;
import core.enums.Commands;

typedef MinionOptions = {
    ?id :Int,
    ?playerId :Int,
    name :String,
    ?attack :Int,
    ?life :Int,
    ?moves: Int,
    ?movesLeft :Int,
    ?attacks: Int,
    ?attacksLeft :Int,
    ?can_be_damaged :Bool,
    ?can_move :Bool,
    ?can_attack :Bool,
    ?on_event :Map<Event, Void -> Commands>
};

class Minion {
    public var id :Int;

    public var playerId :Int;
    public var name :String;
    public var attack :Int;
    public var life :Int;
    public var moves: Int;
    public var movesLeft :Int;
    public var attacks: Int;
    public var attacksLeft :Int;
    public var can_be_damaged :Bool;
    public var can_move :Bool;
    public var can_attack :Bool;

    public var on_event :Map<Event, Void -> Commands>;

    public function new(options :MinionOptions) {
        id               = options.id;
        playerId         = options.playerId;
        name             = options.name;
        attack           = (options.attack != null ? options.attack : 1);
        life             = (options.life != null ? options.life : 1);
        moves            = (options.moves != null ? options.moves : 1);
        movesLeft        = (options.movesLeft != null ? options.movesLeft : 0);
        attacks          = (options.attacks != null ? options.attacks : 1);
        attacksLeft      = (options.attacksLeft != null ? options.attacksLeft : 0);
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

    public function clone() :Minion {
        return new Minion({
            id: this.id,
            playerId: this.playerId,
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
}
