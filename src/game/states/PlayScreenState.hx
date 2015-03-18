
package game.states;

import luxe.Color;
import luxe.Input.KeyEvent;
import luxe.Input.Key;
import luxe.Scene;
import luxe.Sprite;
import luxe.States;
import luxe.Text;
import luxe.tween.Actuate;
import luxe.Vector;
import luxe.Visual;

class PlayScreenState extends State {
    var scene :Scene;
    var background :Visual;
    var game :core.Game;

    public function new() {
        super({ name: 'PlayScreenState' });
        scene = new Scene('PlayScreenScene');
        game = tests.SimpleTestGame.create_game();
    }

    override function init() {
        trace("INIT PlayScreenState");
    }

    override function onenter<T>(_value :T) {
        trace("ENTER PlayScreenState");
        setup();
    }

    override function onleave<T>(_value :T) {
        trace("LEAVE PlayScreenState");
        cleanup();
    }

    function reset() {
        cleanup();
        setup();
    }

    function tile_to_pos(x, y) :Vector {
        var tileSize = 140;
        return new Vector(180 + tileSize / 2 + x * (tileSize + 10), 20 + tileSize / 2 + y * (tileSize + 10));
    }

    function setup() {
        background = new Visual({
            pos: new Vector(0, 0),
            size: Luxe.screen.size.clone(),
            color: new ColorHSV(200, 0.5, 0.7),
            scene: scene
        });

        var boardSize = game.get_board_size();
        var tileSize = 140;
        Actuate
            .tween(background.color, 0.3, { h: 240, s: 0.5, v: 0.7 })
            .onComplete(function() {
                for (y in 0 ... boardSize.y) {
                    for (x in 0 ... boardSize.x) {
                        var tile = new Sprite({
                            pos: tile_to_pos(x, y),
                            color: new ColorHSV(360 * Math.random(), 0.5, 0.5),
                            size: new Vector(tileSize, tileSize),
                            scale: new Vector(0, 0),
                            scene: scene
                        });
                        tile.rotation_z = -25 + 50 * Math.random();
                        Actuate
                            .tween(tile, 0.2, { rotation_z: 0 })
                            .delay((y * boardSize.x + x) / 20);
                        Actuate
                            .tween(tile.scale, 0.2, { x: 1, y: 1 })
                            .delay((y * boardSize.x + x) / 20);
                    }
                }

                var minions = game.get_minions();
                for (m in minions) {
                    var pos = game.get_minion_pos(m);
                    var minion = new Visual({
                        pos: tile_to_pos(pos.x, pos.y),
                        color: new ColorHSV(100 * m.player.id, 0.8, 0.8),
                        geometry: Luxe.draw.circle({ r: 60 }),
                        scene: scene
                    });
                    new Text({
                        text: m.name,
                        color: new Color(1, 1, 1, 1),
                        align: TextAlign.center,
                        align_vertical: TextAlign.center,
                        point_size: 20,
                        scene: scene,
                        parent: minion
                    });
                }
            });
    }

    function cleanup() {
        scene.empty();
    }
    
    override function onkeyup(e :KeyEvent) {
        switch (e.keycode) {
            case Key.key_r: reset();
            case Key.escape: Main.switch_to_state('TitleScreenState');
        }
    }
}
