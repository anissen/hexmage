
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

using game.extensions.PointTools;

class PlayCardState extends State {
    static public var StateId = 'PlayCardState';

    var scene :Scene;

    public function new() {
        super({ name: StateId });
        scene = new Scene('PlayCardScene');
    }

    function can_play_at(data :PlayCardActionData, game :Game) {
        var playAtDot = new Sprite({
            pos: data.target.tile_to_world(),
            color: new Color(0.2, 0.2, 1),
            geometry: Luxe.draw.circle({ r: 25 }),
            scale: new Vector(0.0, 0.0),
            scene: scene
        });
        playAtDot.add(new OnClick(function() {
            // callback(data);
            trace('PlayCardState: Playing card');
            trace(data);
            Main.states.disable(this.name);
            game.do_action(PlayCardAction(data));
        }));
        luxe.tween.Actuate.tween(playAtDot.scale, 0.3, { x: 1, y: 1 });
    }

    override function onenabled<T>(_value :T) {
        var bg = new Sprite({
            color: new Color(0, 0, 100, 0.1),
            size: Luxe.screen.size.clone(),
            centered: false,
            scene: scene,
            depth: -20
        });

        var data :{ game :Game, card :core.Card } = cast _value;
        for (action in data.game.actions()) {
            switch action {
                case PlayCardAction(p): if (p.card.id == data.card.id) can_play_at(p, data.game);
                case _:
            }
        }
    }

    override function ondisabled<T>(_value :T) {
        scene.empty();
    }
}
