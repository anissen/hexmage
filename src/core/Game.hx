
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
        return state.players = players;
    }

    public function new(_state :GameStateOptions) {
        state = _state;
    }
}

class Game {
    var state :GameState;

    public function new(_state :GameState) {
        _state = state;
    } 

    public function start() {

    }

    // public function get_available_actions() :Array<Action> {
    //     return RuleEngine.get_best_actions_for_player(state.board, get_current_player, );
    // }

    public function get_current_player() :Player {
        return state.players[0];
    }

    function end_turn() :Void {
        state.players.push(state.players.shift());
    }

    public function do_action(action :Action) :GameState { // action includes end_turn
        switch action {
            case EndTurn: end_turn();
            case _: state.board.do_action(action);
        }
        return state;
    }
}

