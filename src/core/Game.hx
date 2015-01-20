
package core;

import core.Player;
import core.Actions;

typedef GameStateOptions = {
    var board :Board;
    var players :Players; // includes deck
    var rules :Rules;
};

class GameState {
    var state :GameStateOptions;

    public var board (get, never) :Board;
    public var players (get, set) :Players;

    function get_board() :Board {
        return state.board;
    }

    function get_players() :Players {
        return state.players;
    }

    function set_players(players :Players) :Players {
        return (state.players = players);
    }

    public function new(_state :GameStateOptions) {
        state = _state;
    }
}

class Game {
    var state :GameState;

    public function new(_state :GameState) {
        state = _state;
    } 

    public function start() {
        var maxTurns = 4; // TEMPORARY, for testing
        for (turn in 0 ... maxTurns) {
            var actions = get_current_player().take_turn(this);
            for (action in actions) {
                // check action available
                state = do_action(action);
                // check victory/defeat
            }
            end_turn();
        }
    }

    public function get_available_actions() :Array<Action> {
        return RuleEngine.get_available_actions(state, get_current_player());
    }

    function get_current_player() :Player {
        return state.players[0];
    }

    function end_turn() :Void {
        state.players.push(state.players.shift());
    }

    public function do_action(action :Action) :GameState {
        // TODO: Clone state, do action on cloned state and return cloned state
        state.board.do_action(action);
        return state;
    }
}

