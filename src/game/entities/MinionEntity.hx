
package game.entities;

import luxe.Vector;
import luxe.Sprite;
import luxe.Scene;
import luxe.Color;
import luxe.options.SpriteOptions;

import game.components.OnClick;

typedef MinionOptions = {
    minion :core.Minion,
    pos :Vector,
    scene :Scene
}

typedef ClickedEventData = {
    entity :MinionEntity,
    minion :core.Minion
}

class MinionEntity extends Sprite {
    var minion :core.Minion;

    public function new(options :MinionOptions) {
        super({
            pos: options.pos,
            color: new ColorHSV(100 * options.minion.player.id, 0.8, 0.8),
            geometry: Luxe.draw.circle({ r: 60 }),
            scene: options.scene
        });
        minion = options.minion;
    }

    override function init() {
        add(new OnClick(on_click));
    }

    function on_click() {
        events.fire('clicked', { entity: this, minion: minion });
    }
}
