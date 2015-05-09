
package core;

import core.Card;

class CardLibrary {
    static var cards = new Map<String, Card>();

    static public function add(card :Card) {
        if (card.name.length == 0)
            throw 'Cannot add card with empty name';
        if (cards.exists(card.name))
            throw 'Card with name "${card.name}"" already exists!';
        cards.set(card.name, card);
    }

    public var nextCardId(default, null) :Int;

    public function new(nextId :Int) {
        nextCardId = nextId;
    }

    public function create(name :String) {
        var cardPrototype = cards.get(name);
        if (cardPrototype == null)
            throw 'Card with name "$name" does not exist!';
        
        var card = cardPrototype.clone();
        card.id = nextCardId++;
        return card;
    }
}
