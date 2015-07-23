
package core;

import core.enums.Actions;
import core.Card;

typedef PlayerOptions = { 
    ?id :Int,
    name :String,
    ?deck :Deck,
    ?hand :Cards,
    ai :Bool,
    color :Int
    // ?baseMana :Int,
    // ?mana :Int
};

typedef Players = Array<Player>;

class Player {
    static var Id :Int = 0;
    
    public var id :Int;
    public var name :String;
    public var deck :Deck;
    public var hand :Cards;
    public var ai :Bool;
    public var color :Int;
    // public var baseMana :Int; // TEMP
    // public var mana :Int; // TEMP

    public function new(options :PlayerOptions) {
        id = (options.id != null ? options.id : Id++);

        name  = options.name;
        deck  = (options.deck != null ? options.deck : new Deck());
        hand  = (options.hand != null ? options.hand : []);
        ai    = options.ai;
        color = options.color;
        // baseMana = (options.baseMana != null ? options.baseMana : 0);
        // mana = (options.mana != null ? options.mana : 0);
    }

    public function clone() :Player {
        return new Player({
            id: id,
            name: name,
            deck: deck.clone(),
            hand: clone_hand(),
            ai: ai,
            color: color
            // baseMana: baseMana,
            // mana: mana
        });
    }

    function clone_hand() :Array<Card> {
        return [ for (card in hand) card.clone() ];
    }
}
