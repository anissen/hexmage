
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
    scene :Scene,
    depth :Int
}

class CardEntity extends Sprite {
    public var card :core.Card;
    var text :Text;
    var cardWidth :Int = 140;
    var cardHeight :Int = 200;
    var cardMargin :Int = 8;

    public function new(options :CardOptions) {
        var baseHue = switch (options.card.type) {
            case MinionCard(_): 250;
            case SpellCard(_): 340;
        };
        var colorHue = baseHue + Math.random() * 50;
        super({
            pos: options.pos,
            size: new Vector(cardWidth, cardHeight),
            color: new ColorHSV(colorHue, 0.2, 1),
            scene: options.scene,
            depth: options.depth
        });
        card = options.card;

        new Sprite({
            pos: new Vector(cardWidth / 2, cardHeight / 2),
            size: new Vector(cardWidth - cardMargin, cardHeight - cardMargin),
            color: new ColorHSV(colorHue, 0.8, 0.9),
            scene: options.scene,
            depth: options.depth,
            parent: this
        });

        text = new Text({
            text: '${card.name}', //  (${card.cost})
            pos: new Vector(cardWidth / 2, cardMargin + 15),
            color: new Color(1, 1, 1, 1),
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            point_size: 18,
            scene: options.scene,
            parent: this,
            depth: options.depth
        });
    }

    override function init() {
        add(new OnClick(on_click));
    }

    function on_click() {
        Luxe.events.fire('card_clicked', { entity: this, card: card });
    }
}
