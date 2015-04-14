
package game.states;

import luxe.Scene;
import luxe.States;
import luxe.Sprite;
import luxe.Text;
import luxe.tween.Actuate;
import luxe.Vector;
import luxe.Color;

import core.Game;
import game.components.OnClick;

class HandState extends State {
    var scene :Scene;
    var cards :Array<Sprite>;

    public function new() {
        super({ name: 'HandState' });
        scene = new Scene('HandScene');
        cards = [];
    }

    function add_card(card :core.Card) {
        var cardSize = 100;
        var cardSprite = new Sprite({
            color: new Color(0.0, 0.2, 0.3),
            size: new Vector(cardSize, cardSize),
            pos: new Vector(Luxe.screen.w * Math.random(), Luxe.screen.h - (cardSize / 2) - 10),
            // geometry: Luxe.draw.box({
            //     w: cardSize,
            //     h: cardSize
            // }),
            scene: scene,
            depth: 10
        });
        new Text({
            text: card.name,
            pos: new Vector(cardSize / 2, cardSize / 2),
            color: new Color(1, 1, 1, 1),
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            point_size: 20,
            // scene: scene,
            parent: cardSprite,
            depth: 15
        });
        cards.push(cardSprite);
        for (i in 0 ... cards.length) {
            var cardSprite = cards[i];
            var cardCount = cards.length; 
            Actuate.tween(cardSprite.pos, 0.3, { x: ((i + 1) / (cardCount + 1)) * Luxe.screen.w }, true);
        }
    }

    override function onenabled<T>(_value :T) {
        var bgHeight :Int = 50;
        var bg = new Sprite({
            color: new Color(0, 0, 0, 0.2),
            size: new Vector(Luxe.screen.w, bgHeight),
            pos: new Vector(0, Luxe.screen.h - bgHeight),
            centered: false,
            scene: scene,
            depth: 10
        });

        Luxe.events.listen('card_drawn', function(data :core.Events.CardDrawnData) {
            if (data.player.name == 'Human Player') {
                add_card(data.card);
            }
        });
    }

    override function ondisabled<T>(_value :T) {
        // trace('MinionActionState before scene empty');
        cards = [];
        scene.empty();
        // trace('MinionActionState after scene empty');
    }
}
