
package game.states;

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

    public function new() {
        super({ name: StateId });
        scene = new Scene('PlayCardScene');
    }

    function can_play_at(data :core.Actions.PlayCardAction, game :Game) {
        var playAtDot = new Sprite({
            pos: tile_to_pos(data.target.x, data.target.y),
            color: new Color(0.2, 0.2, 1),
            geometry: Luxe.draw.circle({ r: 25 }),
            scale: new Vector(0.0, 0.0),
            scene: scene
        });
        playAtDot.add(new OnClick(function() {
            // callback(data);
            Main.states.disable(this.name);
            game.do_action(PlayCard(data));
        }));
        luxe.tween.Actuate.tween(playAtDot.scale, 0.3, { x: 1, y: 1 });
    }

    function tile_to_pos(x, y) :Vector { // HACK (this shouldn't be included here)!
        var tileSize = 120;
        return new Vector(180 + tileSize / 2 + x * (tileSize + 10), 10 + tileSize / 2 + y * (tileSize + 10));
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
                case core.Actions.Action.PlayCard(p): if (p.card.name == data.card.name) can_play_at(p, data.game);
                case _:
            }
        }
    }

    override function ondisabled<T>(_value :T) {
        scene.empty();
    }
}
