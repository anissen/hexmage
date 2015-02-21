
package core;

import core.Actions;

typedef PlayerOptions = { 
    ?id :Int,
    name :String,
    deck :Deck,
    ?take_turn :Game -> Array<Action>
};

typedef Players = Array<Player>;

class Player {
    static var Id :Int = 0;
    
    public var id :Int;
    public var name :String;
    public var deck :Deck;
    public var take_turn :Game -> Array<Action>;

    public function new(options :PlayerOptions) {
        id = (options.id != null ? options.id : Id++);

        name = options.name;
        deck = options.deck;
        take_turn = options.take_turn;
    }

    public function clone() {
        return new Player({ 
            id: this.id, 
            name: this.name, 
            deck: this.deck, 
            take_turn: this.take_turn
        });
    }
}
