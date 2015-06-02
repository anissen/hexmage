
package core;

import core.Board;
import core.enums.Actions;
import core.Game;
import core.Card;

import core.HexLibrary;

using core.HexLibrary.HexTools;

class RuleEngine {
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
        var hex = board.tile(pos).hex;
        var moves = [];
        for (neighbor in hex.neighbors()) {
            var tileId = neighbor.key;
            if (board.tile(tileId) == null) continue;
            if (board.tile(tileId).minion != null) continue;
            moves.push(MoveAction({ minionId: minion.id, tileId: tileId }));
        }
        
        return moves;
    }

    static function attacks_for_minion(board :Board, minion :Minion) :Array<Action> {
        if (minion == null || !minion.can_attack || minion.attacks <= 0 || minion.attack <= 0) return [];

        var pos = board.minion_pos(minion);
        var hex = board.tile(pos).hex;
        var attacks = [];
        for (neighbor in hex.neighbors()) {
            var tileId = neighbor.key;
            if (board.tile(tileId) == null) continue;
            var other = board.tile(tileId).minion;
            if (other == null || other.playerId == minion.playerId) continue;
            attacks.push(AttackAction({ minionId: minion.id, victimId: other.id }));
        }

        return attacks;
    }

    static public function available_actions_for_card(state :GameState, player :Player, card :Card) :Array<Action> {
        var board = state.board;
        if (board.mana_for_player(player.id) < card.cost) return [];

        function minion_card_targets() {
            var valid_tiles = board.filter_tiles(function(tile) {
                if (tile.claimed != null) return false;
                if (tile.minion != null) return false;
                for (neighbor in tile.hex.neighbors()) {
                    var tileId = neighbor.key;
                    if (board.tile(tileId) == null) continue;
                    if (board.tile(tileId).claimed == player.id) return true;
                }
                return false;
            });
            return [ for (tile in valid_tiles) Target.Tile(tile.id) ];
        }

        function spell_card_targets() {
            return switch card.targetType {
                case Minion: 
                    [ for (minion in board.minions()) Target.Character(minion.id) ];
                case Tile:
                    var empty_tiles = board.filter_tiles(function(tile) {
                        return (tile.minion == null);
                    });
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
