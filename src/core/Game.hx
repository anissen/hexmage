
package core;

import core.Player;
import core.Actions;

typedef GameState = {
    var board :Board;
    var players :Players; // includes deck
    var rules :Rules;
};

class Game {
    // var map :core.Map;
    // var players :Players;
    // var rules :Rules;
    var state :GameState;

    public function new(_state :GameState) {
        // map = _options.map;
        // players = _options.players;
        // rules = (_options.rules != null _options.rules : new Rules());
        state = _state;
    }

    public function do_action(action :Action) { // action includes end_turn

    }
}
