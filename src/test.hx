
import core.Game;
import core.Minion;
import core.Board;
import core.RuleEngine;
import core.Rules;
import core.Actions;
import core.Player;

typedef BestActionsResult = { score :Int, actions :Array<Action> };

class AIPlayer {
    static var ai_iterations = 0;

    static public function actions_for_turn(game :Game) :Array<Action> {
        AIPlayer.ai_iterations = 0;

        var player = game.get_current_player();
        var currentScore = AIPlayer.score_board(player, game);
        var result = minimax(player, game, 3);
        var deltaScore = result.score - currentScore;

        trace('AI tested ${AIPlayer.ai_iterations} combinations of actions');
        trace('Best actions are ${result.actions} with a delta score of $deltaScore');

        if (deltaScore < 0) {
            trace('Score of $deltaScore is not good enough');
            return [];
        }

        // trace('actions: ${result.actions}');
        return result.actions;
    }

    static function minimax(player :Player, game :Game, turnDepthRemaining :Int) :BestActionsResult {
        if (game.is_game_over() || turnDepthRemaining <= 0)
            return { score: AIPlayer.score_board(player, game), actions: [] };

        var bestResult = { score: 0, actions: [] };

        var newGame = game.clone();
        if (newGame.is_current_player(player)) {
            var best = best_actions_for_state(player, newGame, 3 /* own action depth */);
            newGame.do_turn(best.actions); // TODO: Make this return a clone instead?
            var result = minimax(player, newGame, turnDepthRemaining - 1);
            if (result.score > bestResult.score) {
                bestResult.score = result.score;
                bestResult.actions = result.actions;
            }
        } else {
            var worst = worst_actions_for_state(player, newGame, 3 /* enemy action depth */);
            newGame.do_turn(worst.actions);
            var result = minimax(player, newGame, turnDepthRemaining - 1);
            if (result.score < bestResult.score) {
                bestResult.score = result.score;
                bestResult.actions = result.actions;
            }
        }

        return bestResult;
    }

    static function best_actions_for_state(player :Player, game :Game, actionDepthRemaining :Int) :BestActionsResult {
        var initialScore = -1000;
        function scoreFunc(new_score, old_score) { 
            return new_score > old_score; 
        }
        return AIPlayer.actions_for_state(player, game, initialScore, scoreFunc, actionDepthRemaining);
    }

    // http://web.cs.wpi.edu/~rich/courses/imgd4000-d09/lectures/E-MiniMax.pdf
    static function worst_actions_for_state(player :Player, game :Game, actionDepthRemaining :Int) :BestActionsResult {
        var initialScore = 1000;
        function scoreFunc(new_score, old_score) { 
            return new_score < old_score; 
        }
        return AIPlayer.actions_for_state(player, game, initialScore, scoreFunc, actionDepthRemaining);
    }

    static function actions_for_state(player :Player, game :Game, initialScore :Int, scoreFunc :Int -> Int -> Bool, actionDepthRemaining :Int) :BestActionsResult {

        if (game.is_game_over() || actionDepthRemaining <= 0)
            return { score: AIPlayer.score_board(player, game), actions: [] };

        AIPlayer.ai_iterations++;

        var best = { score: initialScore, actions: [] };
        for (action in game.get_available_actions()) {
            var newGame = game.clone();
            // trace('Trying action $action');
            newGame.do_action(action);

            var result = actions_for_state(player, newGame, initialScore, scoreFunc, actionDepthRemaining - 1);
            if (scoreFunc(result.score, best.score)) {
                best.score = result.score;
                best.actions = [action].concat(result.actions);
            }
        }

        return best;
    }

    static function score_board(player :Player, game :Game) :Int {
        var state = game.get_state();

        // score the players own stuff only
        function get_score_for_player(p) {
            var score = 0;
            for (minion in state.board.get_minions_for_player(p)) {
                score += minion.attack + minion.life;
            }
            return score;
        }
        
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
            if (x == 0 && y == 0) return { minion: goblin };
            if (x == 1 && y == 3) return { minion: unicorn };
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
            players: [player2, player1],
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
