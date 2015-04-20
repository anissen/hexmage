
package game.states;

import luxe.Scene;
import luxe.States;
import luxe.Sprite;
import luxe.Vector;
import luxe.Color;

import core.Game;
import game.components.OnClick;

using game.extensions.PointTools;

class MinionActionsState extends State {
    static public var StateId = 'MinionActionsState';

    var scene :Scene;

    public function new() {
        super({ name: StateId });
        scene = new Scene('MinionActionsScene');
    }

    function minion_can_move_to(data :core.Actions.MoveAction, game :Game) {
        var minionPos = game.minion_pos(game.minion(data.minionId));
        var from = minionPos.tile_to_world();
        var to = data.pos.tile_to_world();
        var moveDot = new Sprite({
            pos: from,
            color: new Color(1, 1, 1),
            geometry: Luxe.draw.circle({ r: 25 }),
            scale: new Vector(0.0, 0.0),
            scene: scene
        });
        moveDot.add(new OnClick(function() {
            // callback(data);
            Main.states.disable(this.name);
            game.do_action(Move(data));
        }));
        luxe.tween.Actuate.tween(moveDot.pos, 0.3, { x: to.x, y: to.y });
        luxe.tween.Actuate.tween(moveDot.scale, 0.3, { x: 1, y: 1 });
    }

    function minion_can_attack(data :core.Actions.AttackAction, game :Game) {
        var minionPos = game.minion_pos(game.minion(data.minionId));
        var victimPos = game.minion_pos(game.minion(data.victimId));
        var from = minionPos.tile_to_world();
        var to = victimPos.tile_to_world();
        var attackDot = new Sprite({
            pos: from,
            color: new Color(1, 0, 0),
            geometry: Luxe.draw.circle({ r: 25 }),
            scale: new Vector(0.0, 0.0),
            scene: scene
        });
        attackDot.add(new OnClick(function() {
            // callback(data);
            Main.states.disable(this.name);
            game.do_action(Attack(data));
        }));
        luxe.tween.Actuate.tween(attackDot.pos, 0.3, { x: to.x, y: to.y });
        luxe.tween.Actuate.tween(attackDot.scale, 0.3, { x: 1, y: 1 });
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
                case core.Actions.Action.Move(m): minion_can_move_to(m, data.game);
                case core.Actions.Action.Attack(a): minion_can_attack(a, data.game);
                case _:
            }
        }
    }

    override function ondisabled<T>(_value :T) {
        scene.empty();
    }
}
