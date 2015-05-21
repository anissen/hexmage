
package core;

import core.Card;

typedef DeckOptions = {
    name :String,
    cards :Array<Card>
}

class Deck {
    public var name :String; 
    var cards :Array<Card>;
    public var length(get, null) :Int;

    public function new(?options :DeckOptions) {
        if (options == null) {
            name = 'No name';
            cards = [];
            return;
        }
        name = options.name;
        cards = options.cards;
    }

    public function shuffle() :Void {
        var t = [ for (i in 0 ... cards.length) i ];
        var array = [];
        while (t.length > 0) {
            var pos = Std.random(t.length),
            index = t[pos];
            t.splice(pos, 1);
            array.push(cards[index]);
        }
        cards = array;
    }

    public function draw() :Null<Card> {
        return cards.pop();
    }

    public function clone() :Deck {
        return new Deck({
            name: name,
            cards: clone_cards()
        });
    }

    function get_length() :Int {
        return cards.length;
    }

    function clone_cards()  :Array<Card> {
        return [ for (card in cards) card.clone() ];
    }
}
