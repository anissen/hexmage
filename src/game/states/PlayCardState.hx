
package game.states;

import core.enums.Actions.Action.PlayCardAction;
import core.enums.Actions.PlayCardActionData;
import luxe.Scene;
import luxe.States;
import luxe.Sprite;
import luxe.Vector;
import luxe.Color;

import core.Game;
import game.components.OnClick;

class PlayCardState extends State {
    static public var StateId = 'PlayCardState';

    var scene :Scene;
    var dots :Array<Sprite>;

    public function new() {
        super({ name: StateId });
        scene = new Scene('PlayCardScene');
    }

    function can_play_at(data :PlayCardActionData, game :Game) {
        var playAtDot = switch (data.target) {
            case Character(characterId): 
                var pos = game.minion_pos(game.minion(characterId));
                new Sprite({
                    pos: game.tile_to_world(pos),
                    color: new Color(1, 1, 1),
                    geometry: Luxe.draw.circle({ r: 40 }),
                    scale: new Vector(0.0, 0.0),
                    scene: scene,
                    depth: 100
                });
            case Tile(tile):
                new Sprite({
                    pos: game.tile_to_world(tile), //tile.tile_to_world().subtract(new Vector(50, 50)),
                    color: new Color(1, 1, 1),
                    geometry: Luxe.draw.circle({ r: 40 }), //Luxe.draw.ngon({ sides: 6, r: 50, angle: 30, solid: true }),
                    scale: new Vector(0.0, 0.0),
                    scene: scene,
                    depth: 100
                });
            case Global:
                new Sprite({
                    pos: Luxe.screen.mid.clone(),
                    color: new Color(0.4, 0.2, 1),
                    geometry: Luxe.draw.ngon({ sides: 6, r: 300, solid: true }),
                    scale: new Vector(0.0, 0.0),
                    scene: scene,
                    depth: 100
                });
        }
        playAtDot.color.a = 0.3;
        switch (data.target) {
            case Character(_): 
                new Sprite({
                    color: new Color(1, 0.1, 0.1),
                    texture: Luxe.resources.texture('assets/images/cross-mark.png'),
                    size: new Vector(96, 96),
                    scene: scene,
                    depth: 101,
                    parent: playAtDot
                });
            case Tile(_):
                new Sprite({
                    color: new Color(0, 0.6, 0.6),
                    texture: Luxe.resources.texture('assets/images/impact-point.png'),
                    size: new Vector(64, 64),
                    scene: scene,
                    depth: 101,
                    parent: playAtDot
                });
            case Global:
                new Sprite({
                    color: new Color(1, 1, 1),
                    texture: Luxe.resources.texture('assets/images/magic-swirl.png'),
                    size: new Vector(512, 512),
                    scene: scene,
                    depth: 101,
                    parent: playAtDot
                });
        }
        playAtDot.add(new OnClick({
            callback: function() {
                // callback(data);
                // trace('PlayCardState: Playing card');
                // trace(data);
                game.do_action(PlayCardAction(data));
                Main.states.disable(StateId);
            }
        }));
        dots.push(playAtDot);
        luxe.tween.Actuate.tween(playAtDot.scale, 0.3 * Settings.TweenFactor, { x: 1, y: 1 });
    }

    override function onenabled<T>(_value :T) {
        var bg = new Sprite({
            color: new Color(0, 0, 100, 0.1),
            size: Luxe.screen.size.clone(),
            centered: false,
            scene: scene,
            depth: -20
        });

        dots = [];

        var data :{ game :Game, card :core.Card } = cast _value;
        for (action in data.game.actions()) {
            switch action {
                case PlayCardAction(p): if (p.card.id == data.card.id) can_play_at(p, data.game);
                case _:
            }
        }
    }

    override function ondisabled<T>(_value :T) {
        trace('PlayCardState: Emptying scene...');
        for (dot in dots) dot.destroy(); // HACK: This *seems* to solve the problem with emptying scenes with entities with components
        scene.empty();
    }
}
