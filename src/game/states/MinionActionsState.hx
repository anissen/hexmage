
package game.states;

import core.enums.Actions.Action.AttackAction;
import core.enums.Actions.Action.MoveAction;
import core.enums.Actions.MoveActionData;
import core.enums.Actions.AttackActionData;
import luxe.Scene;
import luxe.States;
import luxe.Sprite;
import luxe.tween.Actuate;
import luxe.utils.Maths;
import luxe.Vector;
import luxe.Color;

import core.Game;
import game.components.OnClick;

class MinionActionsState extends State {
    static public var StateId = 'MinionActionsState';

    var scene :Scene;

    public function new() {
        super({ name: StateId });
        scene = new Scene('MinionActionsScene');
    }

    function minion_can_move_to(data :MoveActionData, game :Game, count :Int) {
        var minionPos = game.get_minion(data.minionId).pos;
        var from = game.tile_to_world(minionPos);
        var to = game.tile_to_world(data.tileId);

        var diff = Vector.Subtract(to, from);
        var arrow = new Sprite({
            pos: from,
            color: new Color(1, 1, 0.5, 0.3),
            texture: Luxe.resources.texture('assets/images/plain-arrow.png'),
            size: new Vector(80, 80),
            rotation_z: Maths.degrees(diff.angle2D) - 90,
            scene: scene,
            depth: -1
        });

        var finalArrowPos = Vector.Add(from, Vector.Multiply(diff, 0.7));
        Actuate
            .tween(arrow.pos, 0.6 * Settings.TweenFactor, { x: finalArrowPos.x, y: finalArrowPos.y })
            .delay(count * 0.05)
            .ease(luxe.tween.easing.Elastic.easeOut);

        var moveDot = new Sprite({
            pos: from,
            color: new Color(0, 0, 0, 0.1),
            geometry: Luxe.draw.circle({ r: 35 }),
            scale: new Vector(0.0, 0.0),
            scene: scene,
            depth: 2
        });
        new Sprite({
            color: new Color(1, 1, 0.5),
            texture: Luxe.resources.texture('assets/images/footprint.png'),
            size: new Vector(64, 64),
            scene: scene,
            depth: 2.1,
            parent: moveDot
        });
        moveDot.add(new OnClick({
            callback: function() {
                Main.states.disable(this.name);
                game.do_action(MoveAction(data));
            }
        }));
        Actuate
            .tween(moveDot.pos, 0.6 * Settings.TweenFactor, { x: to.x, y: to.y })
            .delay(count * 0.05)
            .ease(luxe.tween.easing.Cubic.easeOut);
        Actuate
            .tween(moveDot.scale, 0.6 * Settings.TweenFactor, { x: 1, y: 1 })
            .delay(count * 0.05)
            .ease(luxe.tween.easing.Cubic.easeOut);
    }

    function minion_can_attack(data :AttackActionData, game :Game, count :Int) {
        var minionPos = game.get_minion(data.minionId).pos;
        var victimPos = game.get_minion(data.victimId).pos;
        var from = game.tile_to_world(minionPos);
        var to = game.tile_to_world(victimPos);

        var diff = Vector.Subtract(to, from);
        var arrow = new Sprite({
            pos: from,
            color: new Color(1, 0, 0, 0.3),
            texture: Luxe.resources.texture('assets/images/plain-arrow.png'),
            size: new Vector(80, 80),
            rotation_z: Maths.degrees(diff.angle2D) - 90,
            scene: scene,
            depth: -1
        });

        var finalArrowPos = Vector.Add(from, Vector.Multiply(diff, 0.7));
        Actuate
            .tween(arrow.pos, 0.6 * Settings.TweenFactor, { x: finalArrowPos.x, y: finalArrowPos.y })
            .delay(count * 0.05)
            .ease(luxe.tween.easing.Bounce.easeOut);

        var attackDot = new Sprite({
            pos: from,
            color: new Color(0, 0, 0, 0.5),
            geometry: Luxe.draw.circle({ r: 35 }),
            scale: new Vector(0.0, 0.0),
            scene: scene,
            depth: 2
        });
        new Sprite({
            texture: Luxe.resources.texture('assets/images/punch-blast.png'),
            size: new Vector(96, 96),
            scene: scene,
            depth: 2.1,
            parent: attackDot
        });
        attackDot.add(new OnClick({
            callback: function() {
                Main.states.disable(this.name);
                game.do_action(AttackAction(data));
            }
        }));
        Actuate
            .tween(attackDot.pos, 0.6 * Settings.TweenFactor, { x: to.x, y: to.y })
            .delay(count * 0.05)
            .ease(luxe.tween.easing.Bounce.easeOut);
        Actuate
            .tween(attackDot.scale, 0.6 * Settings.TweenFactor, { x: 1, y: 1 })
            .delay(count * 0.05)
            .ease(luxe.tween.easing.Bounce.easeOut);
    }

    override function onenabled<T>(_value :T) {
        // var bg = new Sprite({
        //     color: new Color(0, 0, 0, 0.2),
        //     size: Luxe.screen.size.clone(),
        //     centered: false,
        //     scene: scene,
        //     depth: -20
        // });

        var data :{ game :Game, minionId :Int } = cast _value;
        var minion = data.game.get_minion(data.minionId);
        var minion_actions = data.game.actions_for_minion(minion);
        var count = 0;
        for (action in minion_actions) {
            switch action {
                case MoveAction(m): minion_can_move_to(m, data.game, count++);
                case AttackAction(a): minion_can_attack(a, data.game, count++);
                case _:
            }
        }
    }

    override function ondisabled<T>(_value :T) {
        scene.empty();
    }
}
