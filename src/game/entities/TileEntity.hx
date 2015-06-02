
package game.entities;

import snow.api.Promise;
import luxe.tween.Actuate;
import luxe.Visual;
import luxe.Vector;
import luxe.Scene;
import luxe.Color;
import luxe.Text;
import core.HexLibrary;

typedef HexTileOptions = {
    > luxe.options.VisualOptions,
    r :Float,
    hex :Hex
}

class HexTile extends luxe.Visual {
    public var hex :Hex;
    public var walkable :Bool;
    var text :Text;

    public function new(options :HexTileOptions) {
        super({
            pos: options.pos,
            color: new ColorHSV(0.55, 0.10, 0.55),
            geometry: Luxe.draw.ngon({ sides: 6, r: options.r, angle: 30, solid: true }),
            depth: -50
        });

        this.hex = options.hex;
        this.walkable = true;

        new Visual({
            pos: options.pos,
            color: new ColorHSV(0.85, 0.1, 0.85),
            geometry: Luxe.draw.ngon({ sides: 6, r: options.r, angle: 30 }),
            depth: -50
        });

        text = new Text({
            text: '',
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

        return new Promise(function(resolve, reject) {
            resolve();
        });
    }

    // public function flash(delay :Float = 0.0) {
    //     this.color
    //         .tween(0.8, { g: 0.9 })
    //         .reverse()
    //         .delay(delay);
    // }

    public function set_mana_text(mana :Int) {
        text.text = '$mana mana';
    }
}
