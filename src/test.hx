
import core.Game;
import core.Minion;
import core.Board;
import core.RuleEngine;
import core.Rules;
import core.Actions;
import core.Player;

class AIPlayer {
    static public function actions_for_turn(game :Game) :Array<Action> {
        // trace('AIPlayer says hello');
        var actions = game.get_available_actions();
        if (actions.length > 0) return [actions[0]];
        return [];
    }
}

class HumanPlayer {
    static public function actions_for_turn(game :Game) :Array<Action> {
        // trace('HumanPlayer says hello');
        return [];
    }
}

class Test {

    static function main() {

        function plus_one_attack_per_turn(b :Board) :Void {
            var m = b.get_minion(3);
            m.attack += 1;
        }

        var tiles = { x: 1, y: 3 };
        var player1 = { id: 0, name: 'Princess', take_turn: HumanPlayer.actions_for_turn };
        var player2 = { id: 1, name: 'Troll', take_turn: AIPlayer.actions_for_turn };
        var goblin = new Minion({ player: player2, id: 0, name: 'Goblin 1', attack: 2, life: 2, rules: new Rules() });
        var unicorn = new Minion({ player: player1, id: 3, name: 'Unicorn', attack: -1, life: 3, rules: [{ trigger: OwnTurnStart, effect: Scripted(plus_one_attack_per_turn) }] });

        function create_tile(x :Int, y :Int) :Tile {
            if (x == 0 && y == 0) return { minion: goblin };
            if (x == 0 && y == 2) return { minion: unicorn };
            return {};
        }

        var board = new Board(tiles.x, tiles.y, create_tile); // TODO: Make from a core.Map
        var gameState = {
            board: board,
            players: [player1, player2],
            rules: new Rules()
        };
        var game = new Game(new GameState(gameState));
        game.start();
        
        // TODO: Remove scoring algorithms from Board
        function score_board(player :Player, otherPlayers :Array<Player>) :Int {
            // score the players own stuff only
            function get_score_for_player(p) {
                var score = 0;
                for (minion in board.get_minions_for_player(p)) {
                    score += minion.attack + minion.life;
                }
                return score;
            }
             
            var score = get_score_for_player(player);
            // var otherPlayers = [player1, player2];
            // otherPlayers.remove(player);
            for (p in otherPlayers) {
                score -= get_score_for_player(p);
            }
            return score;
        }

        function print_score_board_for_player(player :Player) {
            trace('=> Score: ${score_board(player, [player2])} to ${player.name} (player ${player.id})');
        }
        
        board.print_board();
        
        // for (x in 0 ... 5) {
        //     trace('');
        //     trace('========== TURN #${x+1} ==========');
        //     for (minion in board.get_minions_for_player(player1)) {
        //         board.handle_rules_for_minion(minion);
        //     }

        //     var actions = RuleEngine.get_best_actions_for_player(board, player1, function(board, player) {
        //         return score_board(player, [player2]);
        //     });
        //     if (actions.length == 0) {
        //         trace('No available action!');
        //         continue;
        //     } else if (actions.length > 1) {
        //         trace('${actions.length} best actions to choose from!: ');
        //         //for (a in actions) trace('action: $a');
        //     }
        //     var randomBestAction = actions[Math.floor(actions.length * Math.random())];
        //     // trace('chosen action: $randomBestAction');
        //     board.do_action(randomBestAction);
        //     board.print_board();
        //     print_score_board_for_player(player1);
        // }
    }
}
