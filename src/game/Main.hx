
package game;

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
        states.add(new MinionActionsState());
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
}
