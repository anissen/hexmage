
package core;

import core.Game;
import core.Actions;

typedef BestActionsResult = { 
    score :Int,
    actions :Array<Action> 
}

typedef MinimaxOptions = {
    ?max_turn_depth :Int,
    ?max_action_depth :Int,
    ?score_function :Player -> Game -> Int,
    ?min_delta_score :Int
    // TODO: Max actions per turn
    // TODO: Max action percentage per turn
}

class Minimax {
    public var actions_tested :Int;
    var max_turn_depth :Int;
    var max_action_depth :Int;
    var score_function :Player -> Game -> Int;
    var min_delta_score :Int;

    public function new(options :MinimaxOptions) {
        max_turn_depth   = (options.max_turn_depth   != null ? options.max_turn_depth : 3);
        max_action_depth = (options.max_action_depth != null ? options.max_action_depth : 2);
        score_function   = (options.score_function   != null ? options.score_function : default_score_function);
        min_delta_score  = (options.min_delta_score  != null ? options.min_delta_score : -1000);
        actions_tested = 0;
    }

    public function get_best_actions(game :Game) :Array<Action> {
        actions_tested = 0;
        var player = game.get_current_player();
        var currentScore = score_function(player, game);
        var result = minimax(player, game);
        var deltaScore = result.score - currentScore;
        // trace('currentScore: $currentScore');
        // trace('result.score: ${result.score}');
        // trace('deltaScore: $deltaScore');

        if (deltaScore < min_delta_score) {
            // trace('Delta score of $deltaScore is not good enough');
            // trace('Considered actions: ${result.actions}');
            return [];
        }

        return result.actions;
    }

    function minimax(player :Player, game :Game, turn :Int = 0) :BestActionsResult {
        actions_tested++;

        if (game.is_game_over() || turn >= max_turn_depth) {
            // TODO: Choose a different scoring algorithm for self and other player(s)
            return { score: score_function(player, game) - turn, actions: [] };
        }

        var bestResult = { 
            score: (game.is_current_player(player) ? -1000 : 1000), 
            actions: [] 
        };

        var set_of_all_actions = game.get_nested_actions(max_action_depth);
        // trace('AI has ${set_of_all_actions.length} sets of actions to choose between');

        // TODO: Actions should be tested in a tree to avoid many similar cases, e.g.
        // [[Move 1 to X, Move 2 to Y], [Move 1 to X, Move 2 to Z], ...]
        for (actions in set_of_all_actions) {
            var newGame = game.clone();
            newGame.do_turn(actions); // TODO: Make this return a clone instead?

            var result = minimax(player, newGame, turn + 1);
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

    function default_score_function(player :Player, game :Game) :Int {
        // score the players own stuff only
        function get_score_for_player(p) {
            var score :Float = 0;
            var intrinsicMinionScore = 1;
            for (minion in game.get_minions_for_player(p)) {
                score += intrinsicMinionScore + Math.max(minion.attack, 0) + Math.max(minion.life, 0);
            }
            return score;
        }
        
        var score = get_score_for_player(player);
        for (p in game.get_players()) {
            if (p.id == player.id) continue;
            score -= get_score_for_player(p);
        }
        return Math.round(score);
    }
}