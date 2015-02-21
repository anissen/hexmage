
package core;

import core.Card;

typedef DeckOptions = {
    name :String,
    cards :Array<Card>
}

class Deck {
    public var name :String; 
    var cards :Array<Card>;

    public function new(options :DeckOptions) {
        name = options.name;
        cards = options.cards;
    }

    public function shuffle() :Void {
        
    }

    public function draw() :Null<Card> {
        return null;
    }

    public function clone() :Deck {
        return new Deck({
            name: name,
            cards: cards
        });
    }
}
