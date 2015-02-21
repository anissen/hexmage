
package core;

import core.Minion;

enum CardType {
    MinionCard(minionClass :Class<Minion>);
}

typedef CardOptions = { 
    name :String,
    ?cost :Int,
    type :CardType
}

/*
new Card({ 
    name: 'Unicorn!',
    cost: 3,
    type: MinionCard(Unicorn)
});
*/

class Card {
    public var name :String; 
    public var cost :Int;
    public var type :CardType;

    public function new(options :CardOptions) {
        name = options.name;
        cost = (options.cost != null ? options.cost : 0);
        type = options.type;
    }

    // public function play(player :Player, ?targets :Array<Point>) {
    //     throw 'Cannot play an empty card';
    // }
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
