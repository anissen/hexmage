
package game.states;

import core.enums.Actions.Action.AttackAction;
import core.enums.Actions.Action.MoveAction;
import core.enums.Actions.MoveActionData;
import core.enums.Actions.AttackActionData;
import luxe.Scene;
import luxe.States;
import luxe.Sprite;
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

    function minion_can_move_to(data :MoveActionData, game :Game) {
        var minionPos = game.minion_pos(game.minion(data.minionId));
        var from = game.tile_to_world(minionPos);
        var to = game.tile_to_world(data.tileId);
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
        luxe.tween.Actuate.tween(moveDot.pos, 0.3 * Settings.TweenFactor, { x: to.x, y: to.y });
        luxe.tween.Actuate.tween(moveDot.scale, 0.3 * Settings.TweenFactor, { x: 1, y: 1 });
    }

    function minion_can_attack(data :AttackActionData, game :Game) {
        var minionPos = game.minion_pos(game.minion(data.minionId));
        var victimPos = game.minion_pos(game.minion(data.victimId));
        var from = game.tile_to_world(minionPos);
        var to = game.tile_to_world(victimPos);
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
            size: new Vector(92, 92),
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
        luxe.tween.Actuate.tween(attackDot.pos, 0.3 * Settings.TweenFactor, { x: to.x, y: to.y });
        luxe.tween.Actuate.tween(attackDot.scale, 0.3 * Settings.TweenFactor, { x: 1, y: 1 });
    }

    override function onenabled<T>(_value :T) {
        var bg = new Sprite({
            color: new Color(0, 0, 0, 0.2),
            size: Luxe.screen.size.clone(),
            centered: false,
            scene: scene,
            depth: -20
        });

        var data :{ game :Game, minionId :Int } = cast _value;
        var minion = data.game.minion(data.minionId);
        var minion_actions = data.game.actions_for_minion(minion);
        for (action in minion_actions) {
            switch action {
                case MoveAction(m): minion_can_move_to(m, data.game);
                case AttackAction(a): minion_can_attack(a, data.game);
                case _:
            }
        }
    }

    override function ondisabled<T>(_value :T) {
        scene.empty();
    }
}
