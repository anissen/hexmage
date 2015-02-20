
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
    static public var Id :Int = 0;
    // @:isVar public var id(default, null) :Int;

    var listeners :Map<String, Dynamic->Void>;

    public function new(_state :GameState, _isNewGame :Bool = true) {
        state = _state;
        listeners = new Map<String, Dynamic->Void>();
        Id++;

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
        for (action in get_current_player().take_turn(clone())) {
            // TODO: check action available
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
            minion.movesLeft = minion.moves;
            minion.attacksLeft = minion.attacks;
        }
    }

    function emit(key :String, ?data :Dynamic) :Void {
        if (!listeners.exists(key)) return;
        var listener = listeners.get(key);
        listener(data);
    }

    public function get_actions() :Array<Action> {
        return RuleEngine.get_available_actions(state, get_current_player());
    }

    function determine_available_sets_of_actions(actionDepthRemaining :Int) :Array<Array<Action>> {
        if (actionDepthRemaining <= 0)
            return [];

        var actions :Array<Array<Action>> = [];
        for (action in get_actions()) {
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

    public function get_nested_actions(actionDepthRemaining :Int) :Array<Array<Action>> {
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

    // public function get_state() :GameState {
    //     return state;
    // }

    public function get_players() :Array<Player> {
        return clone_players();
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
        for (minion in state.board.get_minions_for_player(get_current_player())) {
            for (rule in minion.rules) {
                if (rule.turn_ends == null) continue;
                rule.turn_ends(minion);
            }
        }

        state.players.push(state.players.shift());
    }

    public function do_action(action :Action) :Void {
        switch (action) {
            case NoAction:
            case Move(m): move(m);
            case Attack(a): attack(a);
        }
    }

    public function do_turn(actions :Array<Action>) :Void {
        for (action in actions) {
            do_action(action);
        }
        end_turn();
        start_turn();
    }
    
    function move(moveAction :MoveAction) {
        var minion = state.board.get_minion(moveAction.minionId);
        var currentPos = state.board.get_minion_pos(minion);
        state.board.get_tile(currentPos).minion = null;
        state.board.get_tile(moveAction.pos).minion = minion;
        minion.movesLeft--;
    }
    
    function attack(attackAction :AttackAction) {
        var minion = state.board.get_minion(attackAction.minionId);
        var victim = state.board.get_minion(attackAction.victimId);

        minion.attacksLeft--;

        var victim_tool_damage = victim.damage(minion.attack, minion);
        if (victim_tool_damage) {
            // queue effect
        }
        var minion_tool_damage = minion.damage(victim.attack, victim);
        if (minion_tool_damage) {
            // queue effect
        }

        // TODO: Should be handled in response to damage
        if (victim.life <= 0) {
            var pos = get_minion_pos(victim);
            if (victim.on_death != null)
                victim.on_death(victim);
            state.board.get_tile(pos).minion = null;
        }
        if (minion.life <= 0) {
            var pos = get_minion_pos(minion);
            if (minion.on_death != null)
                minion.on_death(minion);
            state.board.get_tile(pos).minion = null;
        }
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

    public function get_minions_for_player(player :Player) :Array<Minion> {
        return state.board.get_minions_for_player(player);
    }

    public function get_board_size() :Point {
        return state.board.get_board_size();
    }

    public function get_minion_pos(m :Minion) :Point {
        return state.board.get_minion_pos(m);
    }

    public function print() {
        state.board.print_big();
    }
}

