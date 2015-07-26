
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
    var attack :Sprite;
    var attackText :Text;
    var life :Sprite;
    var lifeText :Text;

    public function new(options :MinionOptions) {
        super({
            pos: options.pos,
            geometry: Luxe.draw.circle({ r: 50 }),
            // no_geometry: true,
            scene: options.scene
        });
        minion = options.minion;

        new Sprite({
            color: new ColorHSV(100 - options.minion.playerId * 100, 0.7, 0.8),
            texture: Luxe.resources.texture('assets/images/minion_base.png'),
            size: new Vector(100, 100),
            scene: options.scene,
            parent: this,
            depth: 1
        });

        new Sprite({
            color: new ColorHSV(100 - options.minion.playerId * 100, 0.7, 0.2),
            texture: Luxe.resources.texture('assets/images/monkey.png'),
            size: new Vector(100, 100),
            scene: options.scene,
            parent: this,
            depth: 1.1
        });

        if (minion.hero) {
            new Sprite({
                pos: new Vector(0, -60),
                texture: Luxe.resources.texture('assets/images/crown.png'),
                scene: options.scene,
                scale: new Vector(0.14, 0.14),
                parent: this,
                depth: 1.2
            });
        }

        text = new Text({
            text: '${minion.name}', //'${minion.name}\n${minion.attack}/${minion.life}',
            color: new Color(1, 1, 1, 1),
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            point_size: 20,
            scene: options.scene,
            parent: this,
            depth: 1.3,
            visible: false // test
        });

        attack = new Sprite({
            pos: new Vector(-28, 40),
            size: new Vector(30, 30),
            // texture: Luxe.resources.texture('assets/images/attack_icon.png'),
            color: new Color(0, 0.45, 0.85, 1),
            scene: options.scene,
            parent: this,
            depth: 1.4
        });

        attackText = new Text({
            text: '${minion.attack}',
            pos: new Vector(15, 15),
            color: new Color(1, 1, 1, 1),
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            point_size: 20,
            scene: options.scene,
            parent: attack,
            depth: 1.5
        });

        life = new Sprite({
            pos: new Vector(28, 40),
            size: new Vector(30, 30),
            // texture: Luxe.resources.texture('assets/images/life_icon.png'),
            color: new Color(1, 0.25, 0.21, 1),
            scene: options.scene,
            parent: this,
            depth: 1.6
        });

        lifeText = new Text({
            text: '${minion.life}',
            pos: new Vector(15, 15),
            color: new Color(1, 1, 1, 1),
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            point_size: 20,
            scene: options.scene,
            parent: life,
            depth: 1.7
        });
    }

    override function init() {
        add(new OnClick({ callback: on_click }));
    }

    public function damage(amount :Int) :Promise {
        Luxe.camera.shake(amount);
        text.text = '${minion.name}'; //'${minion.name}\n${minion.attack}/${minion.life}';
        attackText.text = '${minion.attack}';
        lifeText.text = '${minion.life}';
        return new Promise(function(resolve, reject) {
            Actuate
                .tween(this.color, 0.6 * Settings.TweenFactor, { r: 1, g: 1, b: 1 })
                .reverse()
                .onComplete(resolve);
        });
    }

    function on_click() {
        events.fire('clicked', { entity: this, minion: minion });
    }
}
