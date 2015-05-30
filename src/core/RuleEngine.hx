
package core;

import core.Board;
import core.enums.Actions;
import core.Game;
import core.Card;

class RuleEngine {
    // static public function available_actions_without_minions(state :GameState, player :Player) :Array<Action> 
    // {
    //     var board = state.board;
    //     var actions = [];
    //     function add_actions(a) {
    //         actions = actions.concat(a);
    //     }
    //     for (card in player.hand) {
    //         add_actions(card_plays_for_player(board, player, card));
    //     }
    //     return actions;
    // }

    static public function available_actions(state :GameState, player :Player) :Array<Action> {
        var board = state.board;
        var actions = [];
        function add_actions(a) {
            actions = actions.concat(a);
        }
        for (card in player.hand) {
            add_actions(available_actions_for_card(state, player, card));
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
        if (minion == null || !minion.can_move || minion.moves <= 0) return [];

        var pos = board.minion_pos(minion);
        // var x = pos.x;
        // var y = pos.y;
        var moves = [];
        // TODO: Check neighbors
        
        // function add_move(newx, newy) {
        //     if (newx < 0 || newx >= board.board_size().x) return;
        //     if (newy < 0 || newy >= board.board_size().y) return;
        //     if (board.tile({ x: newx, y: newy }).minion != null) return;
        //     moves.push(MoveAction({ minionId: minion.id, pos: { x: newx, y: newy } }));
        // }
        // add_move(x, y - 1);
        // add_move(x, y + 1);
        // add_move(x - 1, y);
        // add_move(x + 1, y);
        return moves;
    }

    static function attacks_for_minion(board :Board, minion :Minion) :Array<Action> {
        if (minion == null || !minion.can_attack || minion.attacks <= 0 || minion.attack <= 0) return [];

        var pos = board.minion_pos(minion);
        var attacks = [];
        // function add_attack(newx, newy) {
        //     var tile = board.tile({ x: newx, y: newy });
        //     if (tile == null) return;
        //     var other = tile.minion;
        //     if (other == null || other.playerId == minion.playerId) return;
        //     attacks.push(AttackAction({ minionId: minion.id, victimId: other.id }));
        // }
        // TODO: Check neighbors
        // add_attack(x, y - 1);
        // add_attack(x, y + 1);
        // add_attack(x - 1, y);
        // add_attack(x + 1, y);
        return attacks;
    }

    static public function available_actions_for_card(state :GameState, player :Player, card :Card) :Array<Action> {
        var board = state.board;
        if (board.mana_for_player(player.id) < card.cost) return [];

        function is_tile_claimed(x :Int, y :Int) {
            var tile = board.tile('{ x: x, y: y }');
            if (tile == null) return false;
            return (tile.claimed == player.id);
        }

        function minion_card_targets() {
            var valid_tiles = board.filter_tiles(function(tile) {
                if (tile.claimed != null) return false;
                if (tile.minion != null) return false;
                // TODO: Check neighbors
                // if (is_tile_claimed(tile.x, tile.y - 1)) return true;
                // if (is_tile_claimed(tile.x, tile.y + 1)) return true;
                // if (is_tile_claimed(tile.x - 1, tile.y)) return true;
                // if (is_tile_claimed(tile.x + 1, tile.y)) return true;
                return false;
            });
            return [ for (tile in valid_tiles) Target.Tile(tile.id) ];
        }

        function spell_card_targets() {
            return switch card.targetType {
                case Minion: 
                    [ for (minion in board.minions()) Target.Character(minion.id) ];
                case Tile:
                    // dummy actions: find free tiles
                    var empty_tiles = board.filter_tiles(function(tile) {
                        return (tile.minion == null);
                    });
                    // if (empty_tiles.length == 0) return [];
                    // return [ PlayCardAction({ card: card, target: empty_tiles[0].pos }) ];
                    [ for (tile in empty_tiles) Target.Tile(tile.id) ];
                case Global:
                    [ Target.Global ];
            }
        }

        var targets = switch card.type {
            case MinionCard(_): minion_card_targets();
            case SpellCard(_): spell_card_targets();
        };

        return [ for (target in targets) PlayCardAction({ card: card, target: target }) ];
    }
}
