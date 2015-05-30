
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
    // static public var StateId = 'HandState';
    public var stateId :String;

    var scene :Scene;
    var cards :Array<CardEntity>;
    var card_hovered :CardEntity;
    var card_clicked :CardEntity;

    var card_depth = 5;
    var cards_y :Float;
    var flipped :Bool;

    public function new(id :String, y :Float, flip :Bool /* HACK */) {
        super({ name: id });
        stateId = id;
        scene = new Scene('HandScene');
        cards = [];

        cards_y = y;
        flipped = flip;
    }

    public function add_card(card :Card, game :Game /* HACK */) :Promise {
        var cardEntity = new CardEntity({ 
            pos: new Vector(Luxe.screen.w * Math.random(), cards_y),
            card: card,
            scene: scene,
            secret: flipped, // HACK
            depth: card_depth++
        });
        highlight_card_entity(cardEntity, game);
        cards.push(cardEntity);
        return position_cards();
    }

    public function play_card(card :Card) :Promise {
        return new Promise(function(resolve, reject) {
            var cardEntity = get_card_entity(card.id);
            Actuate.tween(cardEntity, 0.3 * Settings.TweenFactor, { rotation_z: 0 });
            Actuate
                .tween(cardEntity.pos, 0.3 * Settings.TweenFactor, { x: Luxe.screen.w / 2, y: Luxe.screen.h / 2 })
                .onComplete(function() {
                    cardEntity.secret = false;
                    Actuate
                        .tween(cardEntity.scale, 0.4 * Settings.TweenFactor, { x: 0.6, y: 0.6 })
                        .delay(0.3 * Settings.TweenFactor);
                    Actuate
                        .tween(cardEntity.color, 0.4 * Settings.TweenFactor, { a: 0 })
                        .onComplete(function() {
                            cards.remove(cardEntity);
                            cardEntity.destroy();
                            position_cards().then(function(res, rej) {
                                card_clicked = null;
                                resolve();
                            });
                        })
                        .delay(0.3 * Settings.TweenFactor);
                });
        });
    }

    public function highlight_cards(game :Game) :Void {
        for (cardEntity in cards) {
            highlight_card_entity(cardEntity, game);
        }
    }

    public function highlight_card_entity(cardEntity :CardEntity, game :Game) :Void {
        var canCast = (game.actions_for_card(cardEntity.card).length > 0);
        cardEntity.set_color_value(canCast ? 0.8 : 0.3);
    }

    function get_card_entity(cardId :Int) :CardEntity {
        for (cardEntity in cards) {
            if (cardEntity.card.id == cardId) {
                return cardEntity;       
            }
        }
        return null;
    }

    function position_cards() :Promise {
        return new Promise(function(resolve, reject) {
            var tweenTime = 0.3 * Settings.TweenFactor;
            for (i in 0 ... cards.length) {
                var cardEntity = cards[i];
                var cardCount = cards.length;
                var startX :Float = (Luxe.screen.w / 2) - (cards.length * 120) / 2;
                var startRot :Float = -((cards.length - 1) * 3) / 2 + (flipped ? 180 : 0);
                Actuate.tween(cardEntity.pos, tweenTime, { x: startX + i * 120 });
                Actuate.tween(cardEntity, tweenTime, { rotation_z: startRot + (flipped ? -i : i) * 3 });
            }
            Luxe.timer.schedule(tweenTime, resolve);
        });
    }

    override function onenabled<T>(_value :T) {
        Luxe.events.listen('card_clicked', function(data :{ entity :CardEntity, card :Card }) {
            if (data.entity != card_clicked) {
                card_clicked = data.entity;
            } else {
                card_clicked = null;
            }
        });
    }

    override function onmousemove(event :MouseEvent) {
        if (card_clicked != null) return;

        for (cardEntity in cards) {
            var mouseover = Luxe.utils.geometry.point_in_geometry(event.pos, cardEntity.geometry);
            if (mouseover && card_hovered != cardEntity) {
                Actuate.tween(cardEntity.scale, 0.3 * Settings.TweenFactor, { x: 1.5, y: 1.5 });
                Actuate.tween(cardEntity.pos, 0.3 * Settings.TweenFactor, { y: cards_y - 70 });
                if (card_hovered != null) {
                    Actuate.tween(card_hovered.scale, 0.5 * Settings.TweenFactor, { x: 1.0, y: 1.0 });
                    Actuate.tween(card_hovered.pos, 0.5 * Settings.TweenFactor, { y: cards_y });
                }
                card_hovered = cardEntity;
            } else if (!mouseover && card_hovered == cardEntity) {
                Actuate.tween(cardEntity.scale, 0.5 * Settings.TweenFactor, { x: 1.0, y: 1.0 });
                Actuate.tween(cardEntity.pos, 0.5 * Settings.TweenFactor, { y: cards_y });
                card_hovered = null;
            }   
        }
    }

    override function ondisabled<T>(_value :T) {
        scene.empty();
        cards = [];
    }
}
