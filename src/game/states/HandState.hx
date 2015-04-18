
package game.states;

import luxe.Input.MouseEvent;
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
    var cards :Array<CardEntity>;
    var card_hovered :CardEntity;

    var card_depth = 5;
    var cards_y :Float;

    public function new() {
        super({ name: 'HandState' });
        scene = new Scene('HandScene');
        cards = [];

        cards_y = Luxe.screen.h - 20;
    }

    function add_card(card :core.Card) {
        var cardEntity = new CardEntity({ 
            pos: new Vector(Luxe.screen.w * Math.random(), cards_y),
            card: card,
            scene: scene,
            depth: card_depth++
        });
        cards.push(cardEntity);
        for (i in 0 ... cards.length) {
            var cardEntity = cards[i];
            var cardCount = cards.length;
            var startX :Float = (Luxe.screen.w / 2) - (cards.length * 120) / 2;
            var startRot :Float = -((cards.length - 1) * 3) / 2;
            Actuate.tween(cardEntity.pos, 0.3, { x: startX + i * 120 });
            Actuate.tween(cardEntity, 0.3, { rotation_z: startRot + i * 3 });
        }
    }

    override function onenabled<T>(_value :T) {
        // var bgHeight :Int = 50;
        // var bg = new Sprite({
        //     color: new Color(0, 0, 0, 0.2),
        //     size: new Vector(Luxe.screen.w, bgHeight),
        //     pos: new Vector(0, Luxe.screen.h - bgHeight),
        //     centered: false,
        //     scene: scene,
        //     depth: 5
        // });

        Luxe.events.listen('card_drawn', function(data :core.Events.CardDrawnData) {
            if (data.player.name == 'Human Player') {
                add_card(data.card);
            }
        });
    }

    override function onmousemove(event :MouseEvent) {
        for (cardEntity in cards) {
            var mouseover = Luxe.utils.geometry.point_in_geometry(event.pos, cardEntity.geometry);
            if (mouseover && card_hovered != cardEntity) {
                Actuate.tween(cardEntity.scale, 0.3, { x: 1.5, y: 1.5 });
                Actuate.tween(cardEntity.pos, 0.3, { y: cards_y - 70 });

                if (card_hovered != null) {
                    Actuate.tween(card_hovered.scale, 0.5, { x: 1.0, y: 1.0 });
                    Actuate.tween(card_hovered.pos, 0.5, { y: cards_y });
                }

                card_hovered = cardEntity;
            } else if (!mouseover && card_hovered == cardEntity) {
                Actuate.tween(cardEntity.scale, 0.5, { x: 1.0, y: 1.0 });
                Actuate.tween(cardEntity.pos, 0.5, { y: cards_y });
                card_hovered = null;
            }   
        }
    }

    override function ondisabled<T>(_value :T) {
        // trace('MinionActionState before scene empty');
        cards = [];
        scene.empty();
        // trace('MinionActionState after scene empty');
    }
}
