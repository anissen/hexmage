
package game;

import luxe.Input.KeyEvent;
import luxe.Input.Key;
import luxe.States;
import luxe.tween.Actuate;
import game.states.*;

class Main extends luxe.Game {
    static public var states :States;

    override function ready() {
        Actuate.defaultEase = luxe.tween.easing.Quad.easeInOut;

        states = new States({ name: 'state_machine' });
        states.add(new TitleScreenState());
        // states.add(new MenuScreenState());
        states.add(new PlayCardState());
        states.add(new PlayScreenState());

        // switch_to_state('TitleScreenState');
        switch_to_state('PlayScreenState');
        // switch_to_state('MenuScreenState');
    }

    static public function switch_to_state<T>(state :String, ?args :T) {
        if (!states.exists(state)) 
            throw 'State "$state" not found';
        states.set(state, args);
    }

    override function onkeyup(e :KeyEvent) {
        if (e.keycode == Key.enter && e.mod.alt) {
            app.app.window.fullscreen = !app.app.window.fullscreen;
        }
    }
}
