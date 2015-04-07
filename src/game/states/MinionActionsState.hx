
package game.states;

import luxe.Scene;
import luxe.States;
import luxe.Sprite;
import luxe.Vector;
import luxe.Color;

import core.Game;
import game.components.OnClick;

class MinionActionsState extends State {
    var scene :Scene;

    public function new() {
        super({ name: 'MinionActionsState' });
        scene = new Scene('MinionActionsScene');
    }

    function minion_can_move_to(data :core.Actions.MoveAction, game :Game) {
        var minionPos = game.minion_pos(game.minion(data.minionId));
        var from = tile_to_pos(minionPos.x, minionPos.y);
        var to = tile_to_pos(data.pos.x, data.pos.y);
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
        var from = tile_to_pos(minionPos.x, minionPos.y);
        var to = tile_to_pos(victimPos.x, victimPos.y);
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

    function tile_to_pos(x, y) :Vector { // HACK (this shouldn't be included here)!
        var tileSize = 140;
        return new Vector(180 + tileSize / 2 + x * (tileSize + 10), 20 + tileSize / 2 + y * (tileSize + 10));
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
        // trace('MinionActionState before scene empty');
        scene.empty();
        // trace('MinionActionState after scene empty');
    }
}
