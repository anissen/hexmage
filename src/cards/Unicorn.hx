
package cards;

import core.Player;
import core.Card;

class Unicorn extends Card {
    public function new() {
        super({ 
            name: 'Unicorn',
            cost: 3,
            type: MinionCard('Unicorn')
        });
    }
}
