
package game.entities;

import luxe.Sprite;
import luxe.Text;
import luxe.tween.Actuate;
import luxe.Vector;
import luxe.Visual;
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

class MinionEntity extends Visual {
    var minion :core.Minion;
    var text :Text;

    public function new(options :MinionOptions) {
        super({
            pos: options.pos,
            color: new ColorHSV(100 - options.minion.playerId * 100, 0.7, 0.8),
            geometry: Luxe.draw.circle({ r: 50 }),
            depth: 10,
            scene: options.scene
        });
        minion = options.minion;

        if (minion.hero) {
            Luxe.resources.load_texture('assets/images/crown.png').then(function(texture) {
                new Sprite({
                    pos: new Vector(0, -50),
                    texture: texture,
                    scene: options.scene,
                    scale: new Vector(0.14, 0.14),
                    depth: 11,
                    parent: this
                });
            });
        }

        text = new Text({
            text: '${minion.name}\n${minion.attack}/${minion.life}',
            color: new Color(1, 1, 1, 1),
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            point_size: 20,
            scene: options.scene,
            depth: 11,
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
            Actuate
                .tween(this.color, 0.6 * Settings.TweenFactor, { s: 0 })
                .reverse()
                .onComplete(resolve);
        });
    }

    function on_click() {
        events.fire('clicked', { entity: this, minion: minion });
    }
}
