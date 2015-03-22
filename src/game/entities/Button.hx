
package game.entities;

import luxe.Color;
import luxe.Sprite;
import luxe.Text;
import luxe.Vector;

import game.components.OnClick;

typedef ButtonOptions = {
    > luxe.options.SpriteOptions,
    text :String,
    text_color :Color,
    callback :Void->Void
}

class Button extends Sprite {
    var text :Text;

    public function new(options :ButtonOptions) {
        super(options);

        text = new Text({
            pos: Vector.Multiply(this.size, 0.5),
            text: options.text,
            color: options.text_color,
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            parent: this
        });
        text.add(new OnClick(options.callback));
    }
}
