
package core;

import core.enums.Actions;
import core.Card;

typedef PlayerOptions = { 
    ?id :Int,
    name :String,
    ?deck :Deck,
    ?hand :Cards,
    ai :Bool
};

typedef Players = Array<Player>;

class Player {
    static var Id :Int = 0;
    
    public var id :Int;
    public var name :String;
    public var deck :Deck;
    public var hand :Cards;
    public var ai :Bool;

    public function new(options :PlayerOptions) {
        id = (options.id != null ? options.id : Id++);

        name = options.name;
        deck = (options.deck != null ? options.deck : new Deck());
        hand = (options.hand != null ? options.hand : []);
        ai   = options.ai;
    }
}
