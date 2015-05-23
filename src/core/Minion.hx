

package core;

import core.enums.Events;
import core.enums.Commands;

typedef MinionOptions = {
    ?id :Int,
    ?playerId :Int,
    name :String,
    ?attack :Int,
    ?life :Int,
    ?baseMoves: Int,
    ?moves :Int,
    ?baseAttacks: Int,
    ?attacks :Int,
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
    public var baseMoves: Int;
    public var moves :Int;
    public var baseAttacks: Int;
    public var attacks :Int;
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
        baseMoves        = (options.baseMoves != null ? options.baseMoves : 1);
        moves            = (options.moves != null ? options.moves : 0);
        baseAttacks      = (options.baseAttacks != null ? options.baseAttacks : 1);
        attacks          = (options.attacks != null ? options.attacks : 0);
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
            baseMoves: this.baseMoves,
            moves: this.moves,
            baseAttacks: this.baseAttacks,
            attacks: this.attacks,
            can_be_damaged: this.can_be_damaged,
            can_move: this.can_move,
            can_attack: this.can_attack,
            on_event: this.on_event
        });
    }
}
