
package game.states;

import luxe.Scene;
import luxe.States;
import luxe.Sprite;
import luxe.Text;
import luxe.tween.Actuate;
import luxe.Vector;
import luxe.Color;

import core.Game;
import game.entities.CardEntity;
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
        var cardEntity = new CardEntity({ 
            pos: new Vector(Luxe.screen.w * Math.random(), Luxe.screen.h - 120),
            card: card,
            scene: scene
        });
        cards.push(cardEntity);
        for (i in 0 ... cards.length) {
            var cardEntity = cards[i];
            var cardCount = cards.length;
            var startX = (Luxe.screen.w / 2) - (cards.length * 100) / 2;
            var startRot = -(cards.length * 3) / 2;
            Actuate.tween(cardEntity.pos, 0.3, { x: startX + i * 100 }, true);
            Actuate.tween(cardEntity, 0.3, { rotation_z: startRot + i * 3 }, true);
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
            depth: 5
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
