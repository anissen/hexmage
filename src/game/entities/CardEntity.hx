
package game.entities;

import luxe.Text;
import luxe.tween.Actuate;
import luxe.Vector;
import luxe.Sprite;
import luxe.Scene;
import luxe.Color;
import phoenix.Batcher;

import game.components.OnClick;

typedef CardOptions = {
    card :core.Card,
    pos :Vector,
    scene :Scene,
    secret :Bool,
    depth :Int,
    batcher :Batcher
}

class CardEntity extends Sprite {
    public var card :core.Card;
    var cardFaceColor :ColorHSV;
    var title :Text;
    var description :Text;
    var cardWidth :Int = 140;
    var cardHeight :Int = 200;
    var cardMargin :Int = 8;
    @:isVar public var secret (get, set) :Bool;

    public function new(options :CardOptions) {
        var baseHue = switch (options.card.type) {
            case MinionCard(_): 250;
            case SpellCard(_): 340;
        };
        var colorHue = baseHue + Math.random() * 50;
        super({
            batcher: options.batcher,
            pos: options.pos,
            size: new Vector(cardWidth, cardHeight),
            color: new ColorHSV(colorHue, 0.2, 1),
            scene: options.scene,
            depth: options.depth
        });
        card = options.card;

        cardFaceColor = new ColorHSV(colorHue, 0.8, 0.9);
        new Sprite({
            batcher: options.batcher,
            pos: new Vector(cardWidth / 2, cardHeight / 2),
            size: new Vector(cardWidth - cardMargin, cardHeight - cardMargin),
            color: cardFaceColor,
            scene: options.scene,
            depth: options.depth,
            parent: this
        });

        title = new Text({
            batcher: options.batcher,
            text: '',
            pos: new Vector(0, 0),
            bounds: new luxe.Rectangle(cardMargin, cardMargin, cardWidth - (cardMargin * 2), 40),
            bounds_wrap: true,
            color: new Color(1, 1, 1, 1),
            align: TextAlign.center,
            align_vertical: TextAlign.top,
            point_size: 18,
            scene: options.scene,
            parent: this,
            depth: options.depth
        });

        description = new Text({
            batcher: options.batcher,
            text: '',
            pos: new Vector(0, 0),
            bounds: new luxe.Rectangle(cardMargin, cardMargin + title.bounds.h + cardMargin, cardWidth - (cardMargin * 2), 60),
            bounds_wrap: true,
            color: new Color(1, 1, 1, 1),
            align: TextAlign.center,
            align_vertical: TextAlign.top,
            point_size: 12,
            scene: options.scene,
            parent: this,
            depth: options.depth
        });

        secret = options.secret;
    }

    public function set_color_value(value :Float) {
        cardFaceColor.tween(0.3, { s: value });
    }

    override function init() {
        add(new OnClick(on_click));
    }

    function on_click() {
        Luxe.events.fire('card_clicked', { entity: this, card: card });
    }

    function get_secret() :Bool {
        return secret;
    }

    function set_secret(val :Bool) {
        title.text = (val ? '???' : '${card.name} (${card.cost})');
        description.text = (val ? '???' : '${card.description}');
        return val;
    }
}
