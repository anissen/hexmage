
package game;

import luxe.States;
import luxe.tween.Actuate;
import game.states.*;

class Main extends luxe.Game {
    static var states :States;

    override function ready() {
        Actuate.defaultEase = luxe.tween.easing.Quad.easeInOut;

        states = new States({ name: 'state_machine' });
        states.add(new TitleScreenState());
        // states.add(new MenuScreenState());
        states.add(new PlayScreenState());

        states.set('TitleScreenState');
        // states.set('PlayScreenState');
        // states.set('MenuScreenState');
    }

    static public function switch_to_state(state :String) {
        if (!states.exists(state)) 
            throw 'State "$state" not found';
        states.set(state);
    }
}
