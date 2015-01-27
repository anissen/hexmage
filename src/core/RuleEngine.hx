
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
            actions = actions.concat([EndTurn]);
        }
        return actions;
    }

    static function get_moves_for_minion(board :Board, minion :Minion) :Array<Action> {
        if (minion.movesLeft <= 0) return [];

        var pos = board.get_minion_pos(minion);
        var x = pos.x;
        var y = pos.y;
        var moves = [];
        // for (newx in x - 1 ... x + 2) {
        //     for (newy in y - 1 ... y + 2) {
        //         if (newx == x && newy == y) continue;
        //         if (newx < 0 || newx >= board.get_board_size().x) continue;
        //         if (newy < 0 || newy >= board.get_board_size().y) continue;
        //         if (board.get_tile({ x: newx, y: newy }).minion != null) continue;
        //         moves.push(Move({ minionId: minion.id, pos: { x: newx, y: newy } }));
        //     }     
        // }
        function add_move(newx, newy) {
            if (newx < 0 || newx >= board.get_board_size().x) return;
            if (newy < 0 || newy >= board.get_board_size().y) return;
            if (board.get_tile({ x: newx, y: newy }).minion != null) return;
            moves.push(Move({ minionId: minion.id, pos: { x: newx, y: newy } }));
        }
        add_move(x, y - 1);
        add_move(x, y + 1);
        add_move(x - 1, y);
        add_move(x + 1, y);
        return moves;
    }

    static function get_attacks_for_minion(board :Board, minion :Minion) :Array<Action> {
        if (minion.attacksLeft <= 0) return [];

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
