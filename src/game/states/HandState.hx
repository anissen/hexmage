
package game.states;

import core.Card;
import core.enums.Events.CardDrawnData;
import core.enums.Events.CardPlayedData;
import luxe.Input.MouseEvent;
import luxe.Scene;
import luxe.States;
import luxe.Sprite;
import luxe.Text;
import luxe.tween.Actuate;
import luxe.Vector;
import luxe.Color;
import snow.api.Promise;


import core.Game;
import game.entities.CardEntity;
import game.components.OnClick;

class HandState extends State {
    static public var StateId = 'HandState';

    var scene :Scene;
    var cards :Array<CardEntity>;
    var card_hovered :CardEntity;

    var card_depth = 5;
    var cards_y :Float;

    public function new() {
        super({ name: StateId });
        scene = new Scene('HandScene');
        cards = [];

        cards_y = Luxe.screen.h - 20;
    }

    public function add_card(card :Card) :Promise {
        var cardEntity = new CardEntity({ 
            pos: new Vector(Luxe.screen.w * Math.random(), cards_y),
            card: card,
            scene: scene,
            depth: card_depth++
        });
        cards.push(cardEntity);
        return position_cards();
    }

    public function play_card(card :Card) :Promise {
        return new Promise(function(resolve, reject) {
            for (cardEntity in cards) {
                if (cardEntity.card.name == card.name) {
                    Actuate.tween(cardEntity, 0.3, { rotation_z: 0 });
                    Actuate
                        .tween(cardEntity.pos, 0.3, { x: Luxe.screen.w / 2, y: Luxe.screen.h / 2 })
                        .onComplete(function() {
                            Actuate.tween(cardEntity.scale, 0.4, { x: 0.6, y: 0.6 });
                            Actuate
                                .tween(cardEntity.color, 0.4, { a: 0 })
                                .onComplete(function() {
                                    cards.remove(cardEntity);
                                    cardEntity.destroy();
                                    position_cards().then(function(res, rej) {
                                        resolve();
                                    });
                                });
                        });
                    return;
                }
            }
        });
    }

    function position_cards() :Promise {
        return new Promise(function(resolve, reject) {
            for (i in 0 ... cards.length) {
                var cardEntity = cards[i];
                var cardCount = cards.length;
                var startX :Float = (Luxe.screen.w / 2) - (cards.length * 120) / 2;
                var startRot :Float = -((cards.length - 1) * 3) / 2;
                Actuate.tween(cardEntity.pos, 0.3, { x: startX + i * 120 });
                Actuate.tween(cardEntity, 0.3, { rotation_z: startRot + i * 3 });
            }
            Luxe.timer.schedule(0.3, resolve);
        });
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

        Luxe.events.listen('card_drawn', function(data :CardDrawnData) {
            if (data.player.name == 'Human Player') {
                add_card(data.card);
            }
        });

        Luxe.events.listen('card_played', function(data :CardPlayedData) {
            trace('HandState::card_played');
            trace(data);
            if (data.player.name == 'Human Player') {
                play_card(data.card);
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
