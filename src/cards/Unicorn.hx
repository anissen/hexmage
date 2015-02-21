
package cards;

typedef UnicornOptions = {
    player :Player,
    ?id :Int
}

class Unicorn extends Minion {
    public function new(options :UnicornOptions) {
        super({
            player: options.player,
            id: options.id,
            name: 'Unicorn',
            attack: 1,
            life: 6
        });
    }
});
