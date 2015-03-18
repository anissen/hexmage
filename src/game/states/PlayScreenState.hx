
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

        background = new Visual({
            pos: new Vector(0, 0),
            size: Luxe.screen.size.clone(),
            color: new ColorHSV(200, 0.5, 0.7),
            scene: scene
        });

        var text = new Text({
            pos: Luxe.screen.mid.clone(),
            text: 'This is the PLAY screen.',
            color: new Color(1, 1, 1, 0),
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            scene: scene,
            parent: background
        });


        Actuate
            .tween(background.color, 0.3, { h: 240, s: 0.5, v: 0.7 })
            .onComplete(function() {
                Actuate.tween(text.color, 0.3, { a: 1 });
            });
    }

    override function onleave<T>(_value :T) {
        trace("LEAVE PlayScreenState");
        scene.empty();
    }
    
    override function onkeyup(e :KeyEvent) {
        switch (e.keycode) {
            case Key.escape: Main.switch_to_state('TitleScreenState');
        }
    }
}
