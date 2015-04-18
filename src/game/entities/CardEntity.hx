
package game.entities;

import luxe.Text;
import luxe.tween.Actuate;
import luxe.Vector;
import luxe.Sprite;
import luxe.Scene;
import luxe.Color;

import game.components.OnClick;

typedef CardOptions = {
    card :core.Card,
    pos :Vector,
    scene :Scene
}

class CardEntity extends Sprite {
    var card :core.Card;
    var text :Text;
    var cardWidth :Int = 120;
    var cardHeight :Int = 150;

    public function new(options :CardOptions) {
        super({
            pos: options.pos,
            geometry: Luxe.draw.box({
                w: cardWidth,
                h: cardHeight
            }),
            color: new ColorHSV(275 + Math.random() * 50, 1, 1),
            scene: options.scene
        });
        card = options.card;

        text = new Text({
            text: '${card.name}', //  (${card.cost})
            pos: new Vector(cardWidth / 2, cardHeight / 3),
            color: new Color(1, 1, 1, 1),
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            point_size: 20,
            scene: options.scene,
            parent: this,
            depth: 15
        });
    }

    override function init() {
        add(new OnClick(on_click));
    }

    function on_click() {
        events.fire('clicked', { entity: this, card: card });
    }
}
