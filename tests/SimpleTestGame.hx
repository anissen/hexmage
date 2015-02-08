
package tests;

import core.Game;
import core.Minion;
import core.Board;
import core.RuleEngine;
import core.Rules;
import core.Actions;
import core.Player;

typedef BestActionsResult = { score :Int, actions :Array<Action> };

// TODO: Refactor this (the minimax algorithm) out from here and MinimaxTests
class AIPlayer {
    static public function actions_for_turn(game :Game) :Array<Action> {

        var player = game.get_current_player();
        var currentScore = score_board(player, game);
        var result = minimax(player, game, 3 /* number of turns to test */);
        var deltaScore = result.score - currentScore;

        if (deltaScore < 0) {
            trace('Score of $deltaScore is not good enough');
            return [];
        }

        return result.actions;
    }

    static function minimax(player :Player, game :Game, maxTurns :Int, turn :Int = 0) :BestActionsResult {
        if (game.is_game_over() || turn >= maxTurns) {
            // TODO: Choose a different scoring algorithm for self and other player(s)
            return { score: score_board(player, game) - turn, actions: [] };
        }

        var set_of_all_actions = game.get_available_sets_of_actions(2 /* number of actions per turns to test */);
        var bestResult = { score: (game.is_current_player(player) ? -1000 : 1000), actions: [] };
        for (actions in set_of_all_actions) {
            var newGame = game.clone();
            newGame.do_turn(actions); // TODO: Make this return a clone instead?

            var result = minimax(player, newGame, maxTurns, turn + 1);
            var score = result.score;
            
            if (game.is_current_player(player)) {
                if (result.score > bestResult.score) {
                    bestResult.score = result.score;
                    bestResult.actions = actions;
                }
            } else {
                if (result.score < bestResult.score) {
                    bestResult.score = result.score;
                    bestResult.actions = actions;
                }
            }
        }

        return bestResult;
    }

    static function score_board(player :Player, game :Game) :Int {
        var state = game.get_state();

        // score the players own stuff only
        function get_score_for_player(p) {
            var score :Float = 0;
            var intrinsicMinionScore = 5;
            for (minion in state.board.get_minions_for_player(p)) {
                score += intrinsicMinionScore + Math.max(minion.attack, 0) + Math.max(minion.life, 0);
            }
            return score;
        }
        
        var score = get_score_for_player(player);
        for (p in state.players) {
            if (p.id == player.id) continue;
            score -= get_score_for_player(p);
        }
        return Math.round(score);
    }
}

class HumanPlayer {
    static public function actions_for_turn(game :Game) :Array<Action> {
        // return [Move({ minionId: 1, pos: { x: 1, y: 2 } })];
        return [];


    }
}

class TestGame {
    public static var ai_player = new Player({ id: 0, name: 'AI Player', take_turn: AIPlayer.actions_for_turn });
    public static var goblin = new Minion({ 
        player: ai_player,
        id: 0,
        name: 'Goblin 1',
        attack: 4,
        life: 4,
        rules: new Rules(),
        moves: 1,
        movesLeft: 0,
        attacks: 1,
        attacksLeft: 0
    });

    public static var human_player = new Player({ id: 1, name: 'Human Player', take_turn: HumanPlayer.actions_for_turn });
    public static var unicorn = new Minion({
        player: human_player,
        id: 1,
        name: 'Unicorn',
        attack: 0,
        life: 1,
        rules: new Rules(), /* [{ trigger: OwnTurnStart, effect: Scripted(plus_one_attack_per_turn) }] */
        moves: 1,
        movesLeft: 0,
        attacks: 1,
        attacksLeft: 0
    });
}


// ---------------------------------------------------------------------------------------------------------


class SimpleTestGame {

    static public function main() {
        var name :String = "?";
        Sys.println("Please enter your name...");
        Sys.print(">>> ");
        name = Sys.stdin().readLine();
        trace("Your name is " + name);

        var tiles = { x: 3, y: 4 };
        function create_tile(x :Int, y :Int) :Tile {
            if (x == 1 && y == 0) return { minion: TestGame.goblin.clone() };
            if (x == 1 && y == 3) return { minion: TestGame.unicorn.clone() };
            return {};
        }

        var gameState = {
            board: new Board(tiles.x, tiles.y, create_tile), // TODO: Make from a core.Map
            players: [TestGame.ai_player, TestGame.human_player],
            rules: new Rules()
        };
        var game = new Game(gameState);
        var board = game.get_state().board;
        
        while (!game.is_game_over()) {
            board.print_board();
            game.take_turn();
        }
    }
}
