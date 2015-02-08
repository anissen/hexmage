
package core;

import core.Player;
import core.Actions;

typedef GameState = {
    var board :Board;
    var players :Players; // includes deck
    var rules :Rules;
};

// enum Event {
//     Move();
//     Attack();
//     StartTurn();
//     EndTurn();
// }

class Game {
    var state :GameState;
    static var Id :Int = 0;
    @:isVar public var id(default, null) :Int;

    var listeners :Map<String, Dynamic->Void>;

    public function new(_state :GameState, _isNewGame :Bool = true) {
        state = _state;
        listeners = new Map<String, Dynamic->Void>();
        id = Game.Id++;

        if (_isNewGame) { // TODO: This is not pretty
            emit('turn_start');
            start_turn();
        }
    } 

    public function start() {
        var maxTurns = 1; // TEMPORARY, for testing
        for (turn in 0 ... maxTurns) {
            take_turn();
        }
    }

    public function take_turn() :Void {
        // trace('${get_current_player().name} has chosen these actions: ${actions}');
        for (action in get_current_player().take_turn(clone())) {
            // TODO: check action available
            // trace('Doing action: $action');
            do_action(action);
            // TODO: check victory/defeat
            if (has_won(get_current_player())) {
                emit('won_game');
                return;
            }
        }
        emit('turn_end');
        end_turn();

        emit('turn_start');
        start_turn();
    }

    function reset_minion_stats() :Void {
        for (minion in state.board.get_minions_for_player(get_current_player())) {
            // trace('Resetting stats for $minion');
            minion.movesLeft = minion.moves;
            minion.attacksLeft = minion.attacks;
            // trace('Minion $minion had stats reset!');
        }
    }

    function emit(key :String, ?data :Dynamic) :Void {
        if (!listeners.exists(key)) return;
        var listener = listeners.get(key);
        listener(data);
    }

    public function get_available_actions() :Array<Action> {
        return RuleEngine.get_available_actions(state, get_current_player());
    }

    function determine_available_sets_of_actions(actionDepthRemaining :Int) :Array<Array<Action>> {
        if (actionDepthRemaining <= 0)
            return [];

        var actions :Array<Array<Action>> = [];
        for (action in get_available_actions()) {
            var newGame = this.clone();
            newGame.do_action(action);

            var result = newGame.determine_available_sets_of_actions(actionDepthRemaining - 1);
            actions.push([action]);
            for (resultActions in result) {
                actions.push([action].concat(resultActions));
            }
        }

        return actions;
    }

    public function get_available_sets_of_actions(actionDepthRemaining :Int) :Array<Array<Action>> {
        var actions = determine_available_sets_of_actions(actionDepthRemaining);
        actions.push([NoAction]); // Include the no-action actions
        return actions;
    }

    function clone_players() :Players {
        return [ for (p in state.players) p.clone() ];
    }

    public function clone() :Game {
        return new Game({
            board: state.board.clone_board(),
            players: clone_players(),
            rules: state.rules.copy() // TODO: Probably not enough
        }, false);
    }

    public function get_state() :GameState {
        return state;
    }

    public function get_current_player() :Player {
        return state.players[0];
    } 

    public function is_current_player(player :Player) :Bool {
        return get_current_player().id == player.id;
    }

    public function is_game_over() :Bool {
        for (player in state.players) {
            if (state.board.get_minions_for_player(player).length == 0)
                return true;
        }
        return false;
    }

    function start_turn() :Void {
        reset_minion_stats();
    }

    function end_turn() :Void {
        state.players.push(state.players.shift());
    }

    public function do_action(action :Action) :Void {
        state.board.do_action(action);
    }

    public function do_turn(actions :Array<Action>) :Void {
        for (action in actions) {
            do_action(action);
        }
        end_turn();
        start_turn();
    }

    public function has_won(player :Player) :Bool {
        for (other_player in state.players) {
            if (other_player.id == player.id) continue;
            if (state.board.get_minions_for_player(other_player).length > 0)
                return false;
        }
        return true;
    }

    public function listen(key :String, func: Dynamic->Void) {
        listeners.set(key, func);
    }
}

