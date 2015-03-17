
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

    public function new() {
        super({ name: 'PlayScreenState' });
        scene = new Scene('PlayScreenScene');
    }

    override function init() {
        trace("INIT PlayScreenState");
    }

    override function onenter<T>(_value :T) {
        trace("ENTER PlayScreenState");
        Actuate
            .tween(Luxe.renderer.clear_color, 0.5, { r: 140, g: 50, b: 120 })
            .ease(luxe.tween.easing.Quad.easeInOut);
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
