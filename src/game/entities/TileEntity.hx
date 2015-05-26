
package game.entities;

import luxe.Sprite;
import luxe.tween.Actuate;
import luxe.Vector;
import luxe.Scene;
import luxe.Color;
import luxe.Text;
import snow.api.Promise;

typedef TileOptions = {
    pos :Vector,
    scene :Scene,
    size :Vector,
    border :Vector
}

class TileEntity extends Sprite {
    var center :Sprite;
    var text :Text;

    public function new(options :TileOptions) {
        var hue = 360 * Math.random();
        super({
            pos: options.pos,
            // color: new ColorHSV(hue, 0.5, 1),
            color: new ColorHSV(hue, 0.15, 1),
            size: options.size,
            scale: new Vector(0, 0),
            scene: options.scene,
            depth: -50
        });
        center = new Sprite({
            pos: Vector.Divide(options.size, 2),
            size: Vector.Subtract(options.size, options.border),
            // color: new ColorHSV(hue, 0.5, 0.8),
            color: new ColorHSV(hue, 0.15, 0.8),
            scene: options.scene,
            parent: this,
            depth: -50
        });

        text = new Text({
            text: '',
            pos: new Vector(options.size.x / 2, options.size.y - 10), //Vector.Divide(options.size, 2),
            color: new Color(0, 0, 1, 1),
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            point_size: 20,
            scene: options.scene,
            parent: this,
            depth: -50
        });
    }

    public function claimed(playerId :Int) :Promise {
        this.color.tween(0.3, { h: 100 - playerId * 100, s: 0.6, v: 1 }); // HACK
        center.color.tween(0.3, { h: 100 - playerId * 100, s: 0.6, v: 0.8 }); // HACK

        return new Promise(function(resolve, reject) {
            resolve();
        });
    }

    public function set_mana_text(mana :Int) {
        text.text = '$mana mana';
    }
}
