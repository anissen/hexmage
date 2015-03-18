
package game.states;

import luxe.Color;
import luxe.Input.KeyEvent;
import luxe.Input.Key;
import luxe.Scene;
import luxe.States;
import luxe.Text;
import luxe.tween.Actuate;
import luxe.Vector;
import luxe.Visual;

class PlayScreenState extends State {
    var scene :Scene;
    var background :Visual;

    public function new() {
        super({ name: 'PlayScreenState' });
        scene = new Scene('PlayScreenScene');
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

    function setup() {
        background = new Visual({
            pos: new Vector(0, 0),
            size: Luxe.screen.size.clone(),
            color: new ColorHSV(200, 0.5, 0.7),
            scene: scene
        });

        var tileSize = 140;
        Actuate
            .tween(background.color, 0.3, { h: 240, s: 0.5, v: 0.7 })
            .onComplete(function() {
                for (y in 0 ... 4) {
                    for (x in 0 ... 4) {
                        var tile = new luxe.Sprite({
                            pos: new Vector(180 + tileSize / 2 + x * (tileSize + 10), 20 + tileSize / 2 + y * (tileSize + 10)),
                            color: new ColorHSV(360 * Math.random(), 0.5, 0.5),
                            size: new Vector(tileSize, tileSize),
                            scale: new Vector(0, 0),
                            scene: scene
                        });
                        tile.rotation_z = -25 + 50 * Math.random();
                        Actuate
                            .tween(tile, 0.2, { rotation_z: 0 })
                            .delay((y * 4 + x) / 20);
                        Actuate
                            .tween(tile.scale, 0.2, { x: 1, y: 1 })
                            .delay((y * 4 + x) / 20);
                    }
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
