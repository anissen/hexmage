
import core.Game;
import core.Minion;
import core.Board;
import core.RuleEngine;
import core.Rules;
import core.Actions;
import core.Player;

typedef BestActionsResult = { score :Int, action :Null<Action>, game :Game };

class AIPlayer {
    static public function actions_for_turn(game :Game) :Array<Action> {
        var actions = [];
        var newGame = game;
        var currentScore = AIPlayer.score_board(game);

        var tries = 0;
        while (tries < 10) { // TODO: Should be based on time instead
            tries++;
            var result = get_best_actions_greedily(newGame);

            if (result.action == null)
                break;

            var deltaScore = result.score - currentScore;

            // trace('Best action is ${result.action} with a delta score of $deltaScore');

            if (deltaScore < 0) {
                trace('Score of $deltaScore is not good enough');
                break;
            }
            // var randomBestAction = result.actions[Math.floor(result.actions.length * Math.random())]; // random best action
            actions.push(result.action);
            newGame = result.game;
            // trace('Score is now ${result.score}');
        }
        return actions;
    }

    static function get_best_actions_greedily(game :Game) :BestActionsResult {
        var bestResult :BestActionsResult = { score: -1000, action: null, game: null };

        for (action in game.get_available_actions()) {
            var newGame = game.clone();
            newGame.do_action(action);
            var score = AIPlayer.score_board(newGame);
            if (score < bestResult.score) continue;

            bestResult.action = action;
            bestResult.score = score;
            bestResult.game = newGame;
        }

        return bestResult;
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
        for (p in state.players) {
            if (p == player) continue;
            score -= get_score_for_player(p);
        }
        return score;
    }
}

class HumanPlayer {
    static public function actions_for_turn(game :Game) :Array<Action> {
        // return [Move({ minionId: 3, pos: { x: 0, y: 3 } })];
        return [];
    }
}

class Test {
    static function main() {
        function plus_one_attack_per_turn(b :Board) :Void {
            var m = b.get_minion(3);
            m.attack += 1;
        }

        var tiles = { x: 3, y: 4 };
        var player1 = { id: 0, name: 'Princess', take_turn: HumanPlayer.actions_for_turn };
        var player2 = { id: 1, name: 'Troll', take_turn: AIPlayer.actions_for_turn };
        var goblin = new Minion({ 
            player: player2,
            id: 0,
            name: 'Goblin 1',
            attack: 2,
            life: 3,
            rules: new Rules(),
            movesLeft: 1,
            attacksLeft: 1
        });
        var unicorn = new Minion({
            player: player1,
            id: 3,
            name: 'Unicorn',
            attack: 2,
            life: 2,
            rules: new Rules(), /* [{ trigger: OwnTurnStart, effect: Scripted(plus_one_attack_per_turn) }] */
            movesLeft: 1,
            attacksLeft: 1
        });

        function create_tile(x :Int, y :Int) :Tile {
            if (x == 1 && y == 0) return { minion: goblin };
            if (x == 1 && y == 2) return { minion: unicorn };
            return {};
        }

        // function one_move_per_turn_rule(state :GameState) {
        //     for (action in state.actions_for_turn) {
        //         switch (action) {
        //             case Move: available_actions = available_actions.filter(function(a) { return a != Move });
        //             case _:
        //         }
        //     }
        // }

        var gameState = {
            board: new Board(tiles.x, tiles.y, create_tile), // TODO: Make from a core.Map
            players: [player1, player2],
            rules: new Rules() // [{ trigger: Constant, effect:  }]
        };
        var game = new Game(gameState);

        game.listen('turn_start', function(data) {
            trace('========= ${game.get_current_player().name} turn starts! =========');
        });

        game.listen('turn_end', function(data) {
            game.get_state().board.print_board();
            // trace('--------- ${game.get_current_player().name} turn ends! ---------');
        });

        game.listen('won_game', function(data) {
            trace('***********************');
            trace('${game.get_current_player().name} won the game!');
            game.get_state().board.print_board();
        });

        game.start();
    }
}
