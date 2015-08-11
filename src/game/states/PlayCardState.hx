
package game.states;

import core.enums.Actions.Action.PlayCardAction;
import core.enums.Actions.PlayCardActionData;
import luxe.Scene;
import luxe.States;
import luxe.Sprite;
import luxe.tween.Actuate;
import luxe.utils.Maths;
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

    function can_play_at(data :PlayCardActionData, game :Game, count :Int) {
        var playAtDot = switch (data.target) {
            case Character(characterId): 
                var pos = game.get_minion(characterId).pos;
                new Sprite({
                    pos: game.tile_to_world(pos),
                    color: new Color(1, 1, 1),
                    geometry: Luxe.draw.circle({ r: 40 }),
                    scale: new Vector(0.0, 0.0),
                    scene: scene,
                    depth: 100
                });
            case Tile(tile, manaTile):
                var pos = game.tile_to_world(tile);

                // Create mana arrow
                if (manaTile != null) {
                    var manaTilePos = game.tile_to_world(manaTile);
                    var diff = Vector.Subtract(pos, manaTilePos);
                    var arrow = new Sprite({
                        pos: manaTilePos,
                        color: new Color(0, 0.8, 0.2, 0.3),
                        texture: Luxe.resources.texture('assets/images/plain-arrow.png'),
                        size: new Vector(64, 64),
                        rotation_z: Maths.degrees(diff.angle2D) - 90,
                        scene: scene,
                        depth: -1
                    });

                    var finalArrowPos = Vector.Add(manaTilePos, Vector.Multiply(diff, 0.6));
                    Actuate
                        .tween(arrow.pos, 0.4 * Settings.TweenFactor, { x: finalArrowPos.x, y: finalArrowPos.y })
                        .delay(count * 0.02)
                        .ease(luxe.tween.easing.Back.easeOut);
                }

                new Sprite({
                    pos: pos,
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
        Actuate
            .tween(playAtDot.scale, 0.3 * Settings.TweenFactor, { x: 1, y: 1 })
            .delay(count * 0.02)
            .ease(luxe.tween.easing.Back.easeOut);
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
        var count = 0;
        for (action in data.game.actions()) {
            switch action {
                case PlayCardAction(p): 
                    if (p.card.id == data.card.id) can_play_at(p, data.game, count++);
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
