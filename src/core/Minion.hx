

package core;

import core.Tag;
import core.enums.Events;
import core.enums.Commands;

typedef MinionOptions = {
    ?id :Int,
    name :String,
    tags :Tags,
    ?on_event :Map<MinionEvent, Void -> Commands>
};

class Minion {
    public var id :Int;

    public var name :String;
    public var tags :Tags;
    public var playerId (get, set) :Int;
    public var attack (get, null) :Int;
    public var life (get, set) :Int;
    public var baseMoves (get, null) :Int;
    public var moves (get, set) :Int;
    public var baseAttacks (get, null) :Int;
    public var attacks (get, set) :Int;
    public var hero (get, null) :Bool;
    public var can_be_damaged (get, null) :Bool;
    public var can_move (get, null) :Bool;
    public var can_attack (get, null) :Bool;

    var default_tags = [
        BaseMoves => 1,
        BaseAttacks => 1,
        Moves => 0,
        Attacks => 0,
        CanMove => 1,
        CanAttack => 1
    ];

    public var on_event :Map<MinionEvent, Void -> Commands>;

    public function new(options :MinionOptions) {
        id       = options.id; // What if id is null??
        name     = options.name;
        tags     = default_tags;
        for (tag in options.tags.keys()) {
            tags[tag] = options.tags[tag];
        }
        on_event = (options.on_event != null ? options.on_event : new Map<MinionEvent, Void -> Commands>());
    }

    public function handle_event(event :MinionEvent) :Commands {
        var event_func = on_event.get(event);
        if (event_func == null) return [];
        return event_func();
    }

    public function clone() :Minion {
        return new Minion({
            id: this.id,
            name: this.name,
            tags: this.tags, //.clone(),
            on_event: this.on_event // TODO: Not cloned!
        });
    }

    function get_playerId() {
        return tags[PlayerId];
    }

    function set_playerId(v) {
        tags[PlayerId] = v;
        return v;
    }

    function get_attack() {
        return tags[Attack];
    }

    function get_life() {
        return tags[Life];
    }

    function set_life(v) {
        tags[Life] = v;
        return v;
    }

    function get_baseMoves() {
        return tags[BaseMoves];
    }

    function get_moves() {
        return tags[Moves];
    }

    function set_moves(v) {
        tags[Moves] = v;
        return v;
    }

    function get_baseAttacks() {
        return tags[BaseAttacks];
    }

    function get_attacks() {
        return tags[Attacks];
    }

    function set_attacks(v) {
        tags[Attacks] = v;
        return v;
    }

    function get_hero() {
        return tags.enabled(Hero);
    }

    function get_can_be_damaged() {
        return tags.enabled(CanBeDamaged);
    }

    function get_can_move() {
        return tags.enabled(CanMove);
    }

    function get_can_attack() {
        return tags.enabled(CanAttack);
    }

}
