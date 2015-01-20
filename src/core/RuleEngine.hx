
package core;

import core.Board;
import core.Actions;
import core.Game;

class RuleEngine {
    static public function get_available_actions(state :GameState, player :Player) :Array<Action> {
        var board = state.board;
        var actions = [];
        for (minion in board.get_minions_for_player(player)) {
            actions = actions.concat(get_moves_for_minion(board, minion));
            actions = actions.concat(get_attacks_for_minion(board, minion));    
        }
        return actions;
    }

    // TODO: Move scoring algorithms elsewhere!
    // static public function get_best_actions_for_player(board :Board, player :Player, scoreStrategy :Board->Player->Int /* TODO: incl. score strategy */) :Array<Action> {
    //     var bestScore = -1000;
    //     var bestActions = [];
    //     var actions = [];
    //     for (minion in board.get_minions_for_player(player)) {
    //         actions = actions.concat(get_moves_for_minion(board, minion));
    //         actions = actions.concat(get_attacks_for_minion(board, minion));    
    //     }
    //     var oldBoard = board.clone_board();
    //     for (action in actions) {
    //         board = oldBoard.clone_board();
    //         // print_board();
    //         board.simulate_action(action);
    //         var score = scoreStrategy(board, player);// board.score_board(player);
    //         // trace('score for doing $action: $score');
    //         if (score == bestScore) { 
    //             bestActions.push(action);
    //         } else if (score > bestScore) {
    //             bestActions = [action];
    //             bestScore = score;
    //         }
    //     }
    //     board = oldBoard;
    //     return bestActions;
    // }

    static function get_moves_for_minion(board :Board, minion :Minion) :Array<Action> {
        var pos = board.get_minion_pos(minion);
        var x = pos.x;
        var y = pos.y;
        var moves = [];
        for (newx in x - 1 ... x + 2) {
            for (newy in y - 1 ... y + 2) {
                if (newx == x && newy == y) continue;
                if (newx < 0 || newx >= board.get_board_size().x) continue;
                if (newy < 0 || newy >= board.get_board_size().y) continue;
                if (board.get_tile({ x: newx, y: newy }).minion != null) continue;
                moves.push(Move({ minionId: minion.id, pos: { x: newx, y: newy } }));
            }     
        }
        return moves;
    }

    static function get_attacks_for_minion(board :Board, minion :Minion) :Array<Action> {
        var pos = board.get_minion_pos(minion);
        var x = pos.x;
        var y = pos.y;
        var attacks = [];
        function add_attack(newx, newy) {
            if (newx < 0 || newx >= board.get_board_size().x) return;
            if (newy < 0 || newy >= board.get_board_size().y) return;
            var other = board.get_tile({ x: newx, y: newy }).minion;
            if (other == null || other.player == minion.player) return;
            attacks.push(Attack({ minionId: minion.id, victimId: other.id }));
        }
        add_attack(x, y - 1);
        add_attack(x, y + 1);
        add_attack(x - 1, y);
        add_attack(x + 1, y);
        return attacks;
    }
}
