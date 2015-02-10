
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
        trace('currentScore: $currentScore');
        trace('result.score: ${result.score}');
        trace('deltaScore: $deltaScore');

        if (deltaScore < -4) {
            trace('Delta score of $deltaScore is not good enough');
            trace('Considered actions: ${result.actions}');
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
            
            if (game.is_current_player(player)) {
                if (result.score > bestResult.score) {
                    bestResult.score = result.score;
                    bestResult.actions = actions;

                    if (turn == 0 /*&& result.actions.length > 0*/)
                        trace(result);
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
            var intrinsicMinionScore = 1;
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
    static public function action_to_string(action :Action) {
        return switch (action) {
            case Move(m): 'Move ${TestGame.get_minion(m.minionId).name} to ${m.pos.x}, ${m.pos.y}';
            case Attack(a): 'Attack ${TestGame.get_minion(a.minionId).name} —> ${TestGame.get_minion(a.victimId).name}';
            case NoAction: 'No Action';
        }
    }

    static public function actions_for_turn(game :Game) :Array<Action> {
        var newGame = game.clone();
        var actions = [];
        while (true) {
            newGame.get_state().board.print_board_big();

            var available_actions = newGame.get_available_actions();
            if (available_actions.length == 0)
                return actions;

            Sys.println("Available actions:");
            for (i in 0 ... available_actions.length) {
                Sys.println('[${i + 1}] ${action_to_string(available_actions[i])}');
            }
            var end_turn_index = available_actions.length + 1;
            Sys.println('[$end_turn_index] End turn');

            Sys.println('Select action (1-$end_turn_index): ');
            Sys.print(">>> ");
            var selection = Sys.stdin().readLine();
            var actionIndex = Std.parseInt(selection);
            if (actionIndex != null && actionIndex > 0 && actionIndex <= end_turn_index) {
                if (actionIndex == end_turn_index)
                    return actions;

                var action = available_actions[actionIndex - 1];
                newGame.do_action(action);
                actions.push(action);
            }
            
            Sys.println('$selection is an invalid action index');
        }
    }
}

class TestGame {
    public static var ai_player = new Player({ id: 0, name: 'AI Player', take_turn: AIPlayer.actions_for_turn });
    public static var goblin = new Minion({ 
        player: ai_player,
        id: 0,
        name: 'Goblin',
        attack: 1,
        life: 2,
        rules: new Rules(),
        moves: 1,
        movesLeft: 0,
        attacks: 1,
        attacksLeft: 0
    });
    public static var orc = new Minion({ 
        player: ai_player,
        id: 1,
        name: 'Troll',
        attack: 4,
        life: 1,
        rules: new Rules(),
        moves: 1,
        movesLeft: 0,
        attacks: 1,
        attacksLeft: 0
    });

    public static var human_player = new Player({ id: 1, name: 'Human Player', take_turn: HumanPlayer.actions_for_turn });
    public static var unicorn = new Minion({
        player: human_player,
        id: 2,
        name: 'Unicorn',
        attack: 1,
        life: 6,
        rules: new Rules(), /* [{ trigger: OwnTurnStart, effect: Scripted(plus_one_attack_per_turn) }] */
        moves: 1,
        movesLeft: 0,
        attacks: 1,
        attacksLeft: 0
    });
    public static var bunny = new Minion({
        player: human_player,
        id: 3,
        name: 'Bunny',
        attack: 0,
        life: 1,
        rules: new Rules(), /* [{ trigger: OwnTurnStart, effect: Scripted(plus_one_attack_per_turn) }] */
        moves: 1,
        movesLeft: 0,
        attacks: 1,
        attacksLeft: 0
    });

    public static var minions = [goblin, orc, unicorn, bunny];
    public static function get_minion(id :Int) {
        for (minion in minions) {
            if (minion.id == id) return minion;
        }
        return null;
    }
}


// ---------------------------------------------------------------------------------------------------------


class SimpleTestGame {
    static public function main() {
        var tiles = { x: 3, y: 4 };
        function create_tile(x :Int, y :Int) :Tile {
            if (x == 1 && y == 0) return { minion: TestGame.orc.clone() };
            if (x == 1 && y == 1) return { minion: TestGame.goblin.clone() };
            if (x == 1 && y == 3) return { minion: TestGame.unicorn.clone() };
            if (x == 2 && y == 3) return { minion: TestGame.bunny.clone() };
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
            game.take_turn();
        }
        Sys.println("GAME OVER");
        board.print_board_big();
        Sys.stdin().readLine();
    }
}
