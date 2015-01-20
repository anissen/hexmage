
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

    public function clone() :GameState {
        return new GameState({
            board: state.board.clone_board(),
            players: state.players.copy(), // TODO: Probably not enough
            rules: state.rules.copy() // TODO: Probably not enough
        });
    }
}

class Game {
    var state :GameState;

    var listeners :Map<String, Void->Void>;

    public function new(_state :GameState) {
        state = _state;
        listeners = new Map<String, Void->Void>();
    } 

    public function start() {
        var maxTurns = 4; // TEMPORARY, for testing
        for (turn in 0 ... maxTurns) {
            if (listeners.exists('turn_start')) listeners.get('turn_start')();
            var actions = get_current_player().take_turn(clone());
            for (action in actions) {
                // check action available
                do_action(action);
                // check victory/defeat
            }
            if (listeners.exists('turn_end')) listeners.get('turn_end')();
            end_turn();
        }
    }

    public function get_available_actions() :Array<Action> {
        return RuleEngine.get_available_actions(state, get_current_player());
    }

    public function clone() :Game {
        return new Game(state.clone());
    }

    public function get_state() :GameState {
        return state;
    }

    public function get_current_player() :Player {
        return state.players[0];
    } 

    function end_turn() :Void {
        state.players.push(state.players.shift());
    }

    public function do_action(action :Action) :Void {
        state.board.do_action(action);
    }

    public function listen(key :String, func: Void->Void) {
        listeners.set(key, func);
    }
}

