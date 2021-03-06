
package core;

import core.enums.Events;
import core.enums.Commands;
import core.Query;
import core.Tag;
import core.Tags;

typedef CastFunction = Target -> Array<core.enums.Commands.Command>;

enum CardType {
    MinionCard;
    SpellCard(castFunc :CastFunction);
    // SpellCard(func :Event->Array<Command>); // TODO: Should *probably* be spellId :String
    // SingleMinionTargetSpellCard(func :String->Array<core.enums.Commands.Command>);
}

// targets: Minion, Hero, Character (Minion or Hero), Tile (empty), Global

enum TargetType {
    Minion;
    // Hero;
    // Character;
    Tile;
    Global;
}

enum Target {
    Character(characterId :Int);
    Tile(tileId :TileId, ?manaTileId :TileId);
    Global;
}

// @:enum
// abstract Zone(Int) {
enum ZoneType {
    Library;
    Deck;
    Hand;
    Board;
    Graveyard;
}

typedef CardOptions = { 
    ?id: Int,
    name :String,
    ?cost :Int,
    ?type :CardType,
    ?targetType :TargetType,
    ?description :String,
    ?tags :Tags,
    ?on_event :Map<MinionEvent, MinionQuery->Commands>
}

typedef Cards = Array<Card>;

class Card implements HasTags {
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
    public var pos (get, set) :String;
    public var zone (get, set) :ZoneType;

    public var cost :Int;
    public var type :CardType;
    public var targetType :TargetType;
    public var description :String;

    public var on_event :Map<MinionEvent, MinionQuery->Commands>;

    var default_tags :Tags = [
        BaseMoves => 1,
        BaseAttacks => 1,
        Moves => 0,
        Attacks => 0,
        CanMove => 1,
        CanAttack => 1,
        Zone => Deck.getIndex()
    ];

    public function new(options :CardOptions) {
        id   = options.id;
        name = options.name;
        cost = (options.cost != null ? options.cost : 0);
        type = (options.type != null ? options.type : MinionCard);
        targetType = (options.targetType != null ? options.targetType : TargetType.Tile);
        description = (options.description != null ? options.description : '');

        tags = default_tags;
        if (options.tags != null) {
            for (tag in options.tags.keys()) {
                tags[tag] = options.tags[tag];
            }
        }
        on_event = (options.on_event != null ? options.on_event : new Map<MinionEvent, MinionQuery->Commands>());
    }

    public function clone() {
        return new Card({
            id: id,
            name: name,
            cost: cost,
            type: type,
            targetType : targetType,
            description: description,
            tags: tags, //.clone(),
            on_event: on_event // TODO: Not cloned!
        });
    }

    public function handle_event(event :MinionEvent) :Commands {
        var event_func = on_event.get(event);
        if (event_func == null) return [];
        return event_func(new MinionQuery(this, game.states.PlayScreenState.game.minions())); // HACK
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

    function get_pos() {
        return tags[PosX] + ',' + tags[PosY];
    }

    function set_pos(v :String) {
        var parts = v.split(',');
        tags[PosX] = Std.parseInt(parts[0]);
        tags[PosY] = Std.parseInt(parts[1]);
        return v;
    }

    function get_zone() :ZoneType {
        return ZoneType.createByIndex(tags[Zone]);
    }

    function set_zone(v :ZoneType) :ZoneType {
        tags[Zone] = v.getIndex();
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
