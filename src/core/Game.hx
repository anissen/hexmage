
package core;

import core.Player;
import core.Actions;

typedef GameState = {
    var board :Board;
    var players :Players; // includes deck
    var rules :Rules;
};

class Game {
    var state :GameState;
    static var Id :Int = 0;
    @:isVar public var id(default, null) :Int;

    var listeners :Map<String, Dynamic->Void>;

    public function new(_state :GameState) {
        state = _state;
        listeners = new Map<String, Dynamic->Void>();
        id = Game.Id++;
    } 

    public function start() {
        var maxTurns = 10; // TEMPORARY, for testing
        for (turn in 0 ... maxTurns) {
            emit('turn_start');
            var actions = get_current_player().take_turn(clone());
            // trace('${get_current_player().name} has chosen these actions: ${actions}');
            for (action in actions) {
                // TODO: check action available
                trace('Doing action: $action');
                do_action(action);
                // TODO: check victory/defeat
                if (has_won()) {
                    emit('won_game');
                    return;
                }
            }
            emit('turn_end');
            end_turn();
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

    public function clone() :Game {
        return new Game({
            board: state.board.clone_board(),
            players: state.players.copy(), // TODO: Probably not enough
            rules: state.rules.copy() // TODO: Probably not enough
        });
    }

    public function get_state() :GameState {
        return state;
    }

    public function get_current_player() :Player {
        return state.players[0];
    } 

    function end_turn() :Void {
        state.players.push(state.players.shift());
        // trace('players: ');
        //     for (p in state.players) trace('${p.name}');
    }

    public function do_action(action :Action) :Void {
        state.board.do_action(action);
    }

    function has_won() :Bool {
        for (player in state.players) {
            if (player == get_current_player()) continue;
            if (state.board.get_minions_for_player(player).length > 0)
                return false;
        }
        return true;
    }

    public function listen(key :String, func: Dynamic->Void) {
        listeners.set(key, func);
    }
}

