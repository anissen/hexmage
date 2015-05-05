
package core;

import core.Game;
import core.enums.Actions;

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

    public function best_actions(game :Game) :Array<Action> {
        actions_tested = 0;
        var player = game.current_player;
        var currentScore = score_function(player, game);
        var result = minimax(player, game);
        var deltaScore = result.score - currentScore;
        // trace('AI; currentScore: $currentScore');
        // trace('AI; result.score: ${result.score}');
        // trace('AI; deltaScore: $deltaScore');

        if (deltaScore < min_delta_score) {
            trace('AI; Actions ${result.actions} with delta score of $deltaScore is not good enough');
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

        // TODO: Handle multiple turns

        var actionTrees = game.nested_actions(max_action_depth);
        // trace('AI has ${actionTrees.length} sets of actions to choose between');

        // if (actionTrees.length == 0) {
        //     return { score: score_function(player, game) - turn, actions: [] };
        // }

        var bestResult = { 
            score: (game.is_current_player(player) ? -1000 : 1000), 
            actions: [] 
        };
        for (actionTree in actionTrees) {
            var result = try_actions(game, player, actionTree);
            if (result.score > bestResult.score) {
                bestResult.score = result.score;
                bestResult.actions = result.actions;
            }
        }

        // trace('*** returning $bestResult');
        return bestResult;
    }

    // TODO: Refactor this
    function try_actions(game :Game, player :Player, actionTree :ActionTree /*, actions :Actions */) :BestActionsResult {
        // trace('Testing $actionTree');
        var newGame = game.clone();
        newGame.do_action(actionTree.current); // TODO: Make this return a clone instead?

        if (actionTree.next == null || actionTree.next.length == 0) {
            // trace('actionTree has no "next" actions');
            var result = { score: score_function(player, game) /* - turn */, actions: [actionTree.current] };
            // trace('* returning $result');
            return result;
        }

        var bestActionTreeResult = {
            score: (game.is_current_player(player) ? -1000 : 1000), 
            actions: [] 
        };
        for (actionSubTree in actionTree.next) {
            var result = try_actions(newGame, player, actionSubTree /*, actions.concat([actionTree.current] )*/);
            // trace('Result is $result');
            if (game.is_current_player(player)) {
                if (result.score > bestActionTreeResult.score) {
                    bestActionTreeResult.score = result.score;
                    bestActionTreeResult.actions = [actionTree.current].concat(result.actions);
                }
            } else {
                if (result.score < bestActionTreeResult.score) {
                    bestActionTreeResult.score = result.score;
                    bestActionTreeResult.actions = [actionTree.current].concat(result.actions);
                }
            }
        }

        // trace('** returning $bestActionTreeResult');
        return bestActionTreeResult;
    }

    function default_score_function(player :Player, game :Game) :Int {
        // score the players own stuff only
        function score_for_player(p :Player) {
            var score :Float = 0;
            var intrinsicMinionScore = 1;
            for (minion in game.minions_for_player(p)) {
                var minionScore = intrinsicMinionScore + Math.max(minion.attack, 0) + Math.max(minion.life, 0);
                // trace('Score for ${minion.name} is $minionScore');
                score += minionScore;
            }
            return score;
        }
        
        var score = score_for_player(player);
        for (p in game.players()) {
            if (p.id == player.id) continue;
            score -= score_for_player(p);
        }
        return Math.round(score);
    }
}
