
package core;

import core.Actions;
import core.Card;

typedef PlayerOptions = { 
    ?id :Int,
    name :String,
    deck :Deck,
    ?take_turn :Game -> Actions,
    ?hand :Cards
};

typedef Players = Array<Player>;

class Player {
    static var Id :Int = 0;
    
    public var id :Int;
    public var name :String;
    public var deck :Deck;
    public var hand :Cards;
    public var take_turn :Game -> Actions;

    public function new(options :PlayerOptions) {
        id = (options.id != null ? options.id : Id++);

        name = options.name;
        deck = options.deck;
        take_turn = options.take_turn;
        hand = (options.hand != null ? options.hand : []);
    }

    public function clone() {
        return new Player({ 
            id: id, 
            name: name, 
            deck: deck.clone(), // TODO: This is probably not enough 
            take_turn: take_turn,
            hand: hand.copy() // TODO: This is probably not enough
        });
    }
}
