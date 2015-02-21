
package cards;

import core.Player;
import core.Minion;

typedef UnicornOptions = {
    player :Player
}

class Unicorn extends Minion {
    public function new(options :UnicornOptions) {
        super({
            player: options.player,
            name: 'Unicorn',
            attack: 1,
            life: 6
        });
    }
}
