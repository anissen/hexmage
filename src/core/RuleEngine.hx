
package core;

import core.Board;
import core.Actions;
import core.Game;

class RuleEngine {
    static public function get_available_actions(state :GameState, player :Player) :Array<Action> {
        var board = state.board;
        var actions = [];
        for (card in player.hand) {
            actions = actions.concat(get_card_plays_for_player(board, player, card));
        }
        for (minion in board.get_minions_for_player(player)) {
            actions = actions.concat(get_attacks_for_minion(board, minion));
            actions = actions.concat(get_moves_for_minion(board, minion));
        }
        return actions;
    }

    static function get_moves_for_minion(board :Board, minion :Minion) :Array<Action> {
        if (!minion.can_move || minion.movesLeft <= 0) return [];

        var pos = board.get_minion_pos(minion);
        var x = pos.x;
        var y = pos.y;
        var moves = [];
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
        if (!minion.can_attack || minion.attacksLeft <= 0 || minion.attack <= 0) return [];

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

    static function get_card_plays_for_player(board :Board, player :Player, card :Card) :Array<Action> {
        // dummy action: find first free tile
        var empty_tiles = board.filter_tiles(function(tile) {
            return (tile.minion == null);
        });
        if (empty_tiles.length == 0) return [];
        var tile = empty_tiles[0];
        return [PlayCard({ card: card, target: tile.pos })];
    }
}
