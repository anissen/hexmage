
package core;

import core.Board;
import core.enums.Actions;
import core.Game;

class RuleEngine {
    static public function available_actions(state :GameState, player :Player) :Array<Action> {
        var board = state.board;
        var actions = [];
        function add_actions(a) {
            actions = actions.concat(a);
        }
        for (card in player.hand) {
            add_actions(card_plays_for_player(board, player, card));
        }
        for (minion in board.minions_for_player(player.id)) {
            add_actions(available_actions_for_minion(state, minion));
        }
        return actions;
    }

    static public function available_actions_for_minion(state :GameState, minion :Minion) :Array<Action> {
        var board = state.board;
        var actions = [];
        actions = actions.concat(attacks_for_minion(board, minion));
        actions = actions.concat(moves_for_minion(board, minion));
        return actions;
    }

    static function moves_for_minion(board :Board, minion :Minion) :Array<Action> {
        if (!minion.can_move || minion.movesLeft <= 0) return [];

        var pos = board.minion_pos(minion);
        var x = pos.x;
        var y = pos.y;
        var moves = [];
        function add_move(newx, newy) {
            if (newx < 0 || newx >= board.board_size().x) return;
            if (newy < 0 || newy >= board.board_size().y) return;
            if (board.tile({ x: newx, y: newy }).minion != null) return;
            moves.push(MoveAction({ minionId: minion.id, pos: { x: newx, y: newy } }));
        }
        add_move(x, y - 1);
        add_move(x, y + 1);
        add_move(x - 1, y);
        add_move(x + 1, y);
        return moves;
    }

    static function attacks_for_minion(board :Board, minion :Minion) :Array<Action> {
        if (!minion.can_attack || minion.attacksLeft <= 0 || minion.attack <= 0) return [];

        var pos = board.minion_pos(minion);
        var x = pos.x;
        var y = pos.y;
        var attacks = [];
        function add_attack(newx, newy) {
            if (newx < 0 || newx >= board.board_size().x) return;
            if (newy < 0 || newy >= board.board_size().y) return;
            var other = board.tile({ x: newx, y: newy }).minion;
            if (other == null || other.playerId == minion.playerId) return;
            attacks.push(AttackAction({ minionId: minion.id, victimId: other.id }));
        }
        add_attack(x, y - 1);
        add_attack(x, y + 1);
        add_attack(x - 1, y);
        add_attack(x + 1, y);
        return attacks;
    }

    static function card_plays_for_player(board :Board, player :Player, card :Card) :Array<Action> {
        // dummy actions: find free tiles
        var empty_tiles = board.filter_tiles(function(tile) {
            return (tile.minion == null);
        });
        // if (empty_tiles.length == 0) return [];
        // return [ PlayCardAction({ card: card, target: empty_tiles[0].pos }) ];
        return [for (tile in empty_tiles) PlayCardAction({ card: card, target: tile.pos })];
    }
}
