
package core;

import core.Minion;

typedef CastFunction = Target -> Array<core.enums.Commands.Command>;

enum CardType {
    MinionCard(minionId :String);
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
    Tile(tileId :TileId);
    Global;
}

typedef CardOptions = { 
    ?id: Int,
    name :String,
    ?cost :Int,
    type :CardType,
    ?targetType :TargetType
}

/*
new Card({ 
    name: 'Unicorn!',
    cost: 3,
    type: MinionCard(Unicorn)
});
*/

typedef Cards = Array<Card>;

class Card {
    public var id :Int; 
    public var name :String; 
    public var cost :Int;
    public var type :CardType;
    public var targetType :TargetType;

    public function new(options :CardOptions) {
        id   = options.id;
        name = options.name;
        cost = (options.cost != null ? options.cost : 0);
        type = options.type;
        targetType = (options.targetType != null ? options.targetType : TargetType.Tile);
    }

    public function clone() {
        return new Card({
            id: id,
            name: name,
            cost: cost,
            type: type,
            targetType : targetType
        });
    }
}

/*
typedef MinionCardOptions = {
    > CardOptions, 
    minion :Minion
}

class MinionCard extends Card {
    public var minion :Minion; 

    public function new(options :MinionCardOptions) {
        super(options);
        minion = options.minion;
    }

    override public function play(player :Player, ?targets :Array<Point>) {
        if (player == null) throw 'Player is null';
        if (targets == null) throw 'No targets';
        // 
    }
}
*/
