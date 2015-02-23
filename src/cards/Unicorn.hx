
package cards;

import core.Player;
import core.Card;
import core.Minion;

class Unicorn extends Card {
    public function new() {
        var minion = new Minion({
            name: 'Unicorn',
            attack: 1,
            life: 6
        });
        super({ 
            name: 'Unicorn!',
            cost: 3,
            type: MinionCard(minion) // TODO: Should be class<Minion> instead of Minion
        });
    }
}
