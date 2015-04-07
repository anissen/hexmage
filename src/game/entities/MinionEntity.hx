
package game.entities;

import luxe.Text;
import luxe.Vector;
import luxe.Sprite;
import luxe.Scene;
import luxe.Color;
import luxe.options.SpriteOptions;

import game.components.OnClick;
import snow.api.Promise;

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
    var text :Text;

    public function new(options :MinionOptions) {
        super({
            pos: options.pos,
            color: new ColorHSV(100 * options.minion.player.id, 0.8, 0.8),
            geometry: Luxe.draw.circle({ r: 60 }),
            scene: options.scene
        });
        minion = options.minion;

        text = new Text({
            text: '${minion.name}\n${minion.attack}/${minion.life}',
            color: new Color(1, 1, 1, 1),
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            point_size: 20,
            scene: options.scene,
            parent: this
        });
    }

    override function init() {
        add(new OnClick(on_click));
    }

    public function damage(amount :Int) :Promise {
        Luxe.camera.shake(amount);
        text.text = '${minion.name}\n${minion.attack}/${minion.life}';
        return new Promise(function(resolve, reject) {
            luxe.tween.Actuate
                .tween(this.color, 0.6, { s: 0 })
                .reverse()
                .onComplete(resolve);
        });
    }

    function on_click() {
        events.fire('clicked', { entity: this, minion: minion });
    }
}
