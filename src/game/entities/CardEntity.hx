
package game.entities;

import luxe.Text;
import luxe.tween.Actuate;
import luxe.Vector;
import luxe.Sprite;
import luxe.Scene;
import luxe.Color;
import luxe.Visual;
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
    var costVisual :Visual;
    var costText :Text;
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
        var cardFace = new Sprite({
            batcher: options.batcher,
            pos: new Vector(cardWidth / 2, cardHeight / 2),
            size: new Vector(cardWidth - cardMargin, cardHeight - cardMargin),
            color: cardFaceColor,
            scene: options.scene,
            depth: options.depth,
            parent: this
        });

        costVisual = new Visual({
            batcher: options.batcher,
            pos: new Vector(4, 7),
            geometry: Luxe.draw.ngon({ sides: 6, r: 20, solid: true, angle: 30, depth: options.depth, batcher: options.batcher }),
            color: new ColorHSV(colorHue, 0.2, 1),
            scene: options.scene,
            depth: options.depth,
            parent: this
        });

        var is_minion_card = switch (options.card.type) {
            case MinionCard(_): true;
            case _: false;
        };
        if (is_minion_card) {
            new Sprite({
                batcher: options.batcher,
                pos: new Vector(cardWidth / 2 - cardMargin / 2, 80),
                texture: Luxe.resources.texture('assets/images/monkey.png'),
                size: new Vector(100, 100),
                color: cardFaceColor,
                scene: options.scene,
                depth: options.depth,
                parent: cardFace
            });
        }

        costText = new Text({
            batcher: options.batcher,
            text: '',
            color: cardFaceColor,
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            point_size: 24,
            scene: options.scene,
            parent: costVisual,
            depth: options.depth
        });

        title = new Text({
            batcher: options.batcher,
            text: '',
            shader: Main.text_shader,
            pos: new Vector(0, 0),
            bounds: new luxe.Rectangle(cardMargin, cardMargin + 5 /* + 5 to make room for cost visual */, cardWidth - (cardMargin * 2), 40),
            bounds_wrap: true,
            color: new Color(1, 1, 1, 1),
            align: TextAlign.center,
            align_vertical: TextAlign.top,
            point_size: 18,
            scene: options.scene,
            parent: this,
            depth: options.depth
        });

        // TODO: Make a OutlinedText class

        // title.color = new Color().rgb(0x131313);
        title.outline_color = new Color(0,0,0,1); //.rgb(0xfefefe);
        title.outline = 0.75;
        title.smoothness = 0.8;
        title.thickness = 1.0;
        // title.glow_amount = 0.4;
        // title.glow_color = new Color(1,0,0,1); //.rgb(0xffde00);
        // title.glow_threshold = 0.8;

        description = new Text({
            batcher: options.batcher,
            text: '',
            shader: Main.text_shader,
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

        description.outline_color = new Color(0,0,0,1); //.rgb(0xfefefe);
        description.outline = 0.75;
        description.smoothness = 0.8;
        description.thickness = 1.0;

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
        costText.text = (val ? '?' : '${card.cost}');
        title.text = (val ? '???' : '${card.name}');
        description.text = (val ? '' : '${card.description}');
        return val;
    }
}
