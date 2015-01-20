
import core.Game;
import core.Minion;
import core.Board;
import core.RuleEngine;
import core.Rules;
import core.Actions;
import core.Player;

class AIPlayer {
    static public function actions_for_turn(game :Game) :Array<Action> {
        var actions = [];
        trace('AIPlayer says hello');

        var bestScore = -1000;
        var bestActions = [];
        for (action in game.get_available_actions()) {
            var oldGame = game.clone();
            game.do_action(action);

            // TODO: Should be
            // var newGame = game.do_action(action);
            var score = AIPlayer.score_board(game);
            if (score == bestScore) { 
                bestActions.push(action);
            } else if (score > bestScore) {
                bestActions = [action];
                bestScore = score;
            }
            game = oldGame;
        }

        if (actions.length == 0) return [];
        return actions[Math.floor(actions.length * Math.random())]; // random best action
    }

    static function score_board(game :Game) :Int {
        var state = game.get_state();

        // score the players own stuff only
        function get_score_for_player(p) {
            var score = 0;
            for (minion in state.board.get_minions_for_player(p)) {
                score += minion.attack + minion.life;
            }
            return score;
        }
        
        var player = game.get_current_player();
        var score = get_score_for_player(player);
        var otherPlayers = state.players;
        otherPlayers.remove(player);
        for (p in otherPlayers) {
            score -= get_score_for_player(p);
        }
        return score;
    }
}

class HumanPlayer {
    static public function actions_for_turn(game :Game) :Array<Action> {
        trace('HumanPlayer says hello');
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

        var gameState = {
            board: new Board(tiles.x, tiles.y, create_tile), // TODO: Make from a core.Map
            players: [player1, player2],
            rules: new Rules()
        };
        var game = new Game(new GameState(gameState));

        game.listen('turn_start', function() {
            trace('========= Turn starts! =======');
            game.get_state().board.print_board();
            trace('...');
        });

        game.listen('turn_end', function() {
            game.get_state().board.print_board();
            trace('========= Turn ends! =======');
        });

        game.start();
    }
}
