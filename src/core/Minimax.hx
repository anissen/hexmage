
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
        max_action_depth = (options.max_action_depth != null ? options.max_action_depth : 5);
        score_function   = (options.score_function   != null ? options.score_function : default_score_function);
        min_delta_score  = (options.min_delta_score  != null ? options.min_delta_score : -1000);
        actions_tested = 0;
    }

    public function best_actions(game :Game) :Array<Action> {
        actions_tested = 0;
        var player = game.current_player;
        var currentScore = score_function(player, game);
        // var negamax_result = negamax(game, 3, -1000, 1000, player.id);
        // trace('AI; negamax_result: $negamax_result');
        // var result = minimax(player, game);
        var result = greedy_best_actions(player, game);
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

    function greedy_best_actions(player :Player, game :Game) :BestActionsResult {
        var bestScore = -1000;
        var bestAction = null;
        var bestGame = null;
        for (action in game.actions()) {
            var newGame = game.clone();
            newGame.do_action(action);
            var score = score_function(player, newGame);
            if (score > bestScore) {
                bestScore = score;
                bestAction = action;
                bestGame = newGame;
            }
        }

        if (bestGame == null) {
            return { score: bestScore, actions: [] };
        }

        var result = greedy_best_actions(player, bestGame);
        if (result.score > bestScore) {
            return { score: result.score, actions: [bestAction].concat(result.actions) };
        }
        return { score: bestScore, actions: [bestAction] };
    }

    function get_best_actions(player :Player, game :Game, turnDepth :Int = 0, actionDepth :Int = 0) :BestActionsResult {
        var actions = game.actions();
        if (turnDepth == max_turn_depth || game.is_game_over()) {
            return { 
                score: score_function(game.current_player, game), 
                actions: []
            };
        }
        if (actions.length == 0) {
            return get_best_actions(player, game, turnDepth + 1, 0);
        }
        var bestResult = { score: -1000, actions: [] };
        for (action in actions) {
            var newGame = game.clone();
            newGame.do_action(action);
            var result = get_best_actions(player, newGame, turnDepth, actionDepth + 1);
            if (newGame.is_current_player(player)) {
                if (result.score >= bestResult.score) {
                    bestResult.score = result.score;
                    bestResult.actions = [action].concat(result.actions);
                }
            } else {
                if (result.score <= bestResult.score) {
                    bestResult.score = result.score;
                    bestResult.actions = [];
                }
            }
        }
        return bestResult;
    }

    function nested_actions(game :Game, actionDepthRemaining :Int) :Array<ActionTree> {
        // if (actionDepthRemaining <= 0)
        //     return [{ current: NoAction }];

        var actions :Array<ActionTree> = [];
        for (action in game.actions()) {
            var newGame = game.clone();
            newGame.do_action(action);

            // trace(action);

            var result = nested_actions(newGame, actionDepthRemaining - 1);
            actions.push({ current: action, next: result });
        }

        return actions;
    }

    function negamax(game :Game, depth :Int, alpha :Int, beta :Int, playerId :Int) :Int {
        if (depth == 0 || game.is_game_over()) { // is a terminal node 
            trace('player id: ${playerId % game.players().length}');
            return score_function(game.players()[playerId % game.players().length], game);
        }
        var bestValue :Int = -1000; //-∞
        var childNodes = nested_actions(game, max_action_depth);
        //childNodes = OrderMoves(childNodes)
        for (child in childNodes) {
            var newGame = game.clone();
            newGame.do_action(child.current);
            var val = -negamax(newGame, depth - 1, -beta, -alpha, playerId + 1);
            trace('val: $val');
            bestValue = Math.round(Math.max(bestValue, val));
            trace('bestValue: $bestValue');
            var a = Math.round(Math.max(alpha, val));
            trace('a: $a');
            trace('beta: $beta');
            if (a >= beta)
                break;
        }
        return bestValue;
    }

    // Initial call for Player A's root node
    // rootNegamaxValue = negamax(rootNode, depth, -1000, +1000, 1)

    function minimax(player :Player, game :Game, turn :Int = 0) :BestActionsResult {
        if (game.is_game_over() || turn >= max_turn_depth) {
            // TODO: Choose a different scoring algorithm for self and other player(s)
            return { score: score_function(player, game) - turn, actions: [] };
        }

        var actionTrees = nested_actions(game, max_action_depth);
        // trace('AI has ${actionTrees.length} sets of actions to choose between');

        if (actionTrees.length == 0) {
            return { score: score_function(player, game) - turn, actions: [] };
        }

        var bestResult = { 
            score: (game.is_current_player(player) ? -1000 : 1000), 
            actions: [] 
        };
        
        // TODO: Handle multiple turns

        // algorithm:
        // function minimax:
        //   games = take_turn(game, 0)
        //   pick game where score is highest --- NOTE: may make alpha-beta pruning impossible!

        // function take_turn (game, turn)
        //   if turn > max_turn return game
        //   for each actionTree AT:
        //      return take_turn(game resulting from AT, turn + 1)
        

        for (actionTree in actionTrees) {
            var result    = try_actions(game, player, actionTree, 0);
            var ownTurn   = game.is_current_player(player);
            var ownBest   =  ownTurn && (result.score >= bestResult.score);
            var enemyBest = !ownTurn && (result.score <= bestResult.score);
            if (ownBest || enemyBest) {
                bestResult.score = result.score;
                bestResult.actions = result.actions;
            }
        }

        // trace('*** returning $bestResult');
        return bestResult;
    }

    // TODO: Refactor this
    function try_actions(game :Game, player :Player, actionTree :ActionTree, actionCount :Int) :BestActionsResult {
        actions_tested++;
        
        // trace('Testing $actionTree');
        var newGame = game.clone();
        newGame.do_action(actionTree.current); // TODO: Make this return a clone instead?

        var max_action_depth_reached = (actionCount >= max_action_depth);
        var no_more_actions = (actionTree.next == null || actionTree.next.length == 0);
        if (max_action_depth_reached || no_more_actions) {
            // trace('actionTree has no "next" actions');
            var result = { 
                score: score_function(player, game) /* - turn */,
                actions: [actionTree.current] 
            };
            // trace('* returning $result');
            return result;
        }

        var bestResult = {
            score: -1000,
            actions: [] 
        };
        for (actionSubTree in actionTree.next) {
            var result = try_actions(newGame, player, actionSubTree, actionCount + 1);
            // trace('Result is $result');
            if (result.score >= bestResult.score) {
                bestResult.score = result.score;
                bestResult.actions = [actionTree.current].concat(result.actions);
            }
        }

        // trace('** returning $bestResult');
        return bestResult;
    }

    function default_score_function(player :Player, game :Game) :Int {
        // score the players own stuff only
        function score_for_player(p :Player) :Float {
            var score :Float = 0;
            var intrinsicCardInDeckScore = 1;
            score += player.deck.length * intrinsicCardInDeckScore;

            var intrinsicCardInHandScore = 3;
            score += player.hand.length * intrinsicCardInHandScore;

            var intrinsicMinionScore = 2;
            var minionAttackScore = 1;
            var minionLifeScore = 1;
            for (minion in game.minions_for_player(p)) {
                var minionScore = intrinsicMinionScore + Math.max(minion.attack, 0) * minionAttackScore + Math.max(minion.life, 0) * minionLifeScore;
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
