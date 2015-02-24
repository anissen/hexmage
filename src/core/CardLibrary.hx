
package core;

import core.Card;

class CardLibrary {
    static var cards = new Map<String, Card>();

    static public function add(card :Card) {
        if (card.name.length == 0)
            throw 'Cannot add card with empty name';
        if (cards.exists(card.name))
            throw 'Card with ID: ${card.name} already exists!';
        cards.set(card.name, card);
    }

    static public function create(id :String) {
        trace(cards);
        var card = cards.get(id);
        if (card == null)
            throw 'Card with ID: $id does not exist!';
        return card.clone();
    }
}
