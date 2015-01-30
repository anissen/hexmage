
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
        ai_iterations = 0;

        var player = game.get_current_player();
        var currentScore = score_board(player, game);
        var result = minimax(player, game, 1 /* number of turns to test */);
        var deltaScore = result.score - currentScore;

        trace('AI tested ${ai_iterations} combinations of actions');  
        // TODO: Also write time spend
        trace('Best actions are ${result.actions} with a delta score of $deltaScore');

        if (deltaScore < 0) {
            trace('Score of $deltaScore is not good enough');
            return [];
        }

        // trace('actions: ${result.actions}');
        return result.actions;
    }

    static function minimax(player :Player, game :Game, turnDepthRemaining :Int) :BestActionsResult {
        trace('minimax turnDepthRemaining: $turnDepthRemaining, player: ${game.get_current_player().name}');

        if (game.is_game_over() || turnDepthRemaining <= 0)
            return { score: score_board(player, game), actions: [] };

        var bestResult = { score: 0, actions: [] };
        if (game.is_current_player(player)) {
            bestResult.score = -1000;
        } else {
            bestResult.score = 1000;
        }

        // Should get all valid sets of actions, e.g.
        // [Move1]
        // [Move1, Move2]
        // [Move1, Move2, Attack]
        // [Move1, Attack]
        var set_of_all_actions = get_available_sets_of_actions(player, game, 4 /* number of actions per turns to test */);
        // trace('ACTIONS: $set_of_all_actions');

        for (actions in set_of_all_actions) {
            // trace('actions from get_available_sets_of_actions');
            // trace(actions);

            var newGame = game.clone();
            newGame.do_turn(actions); // TODO: Make this return a clone instead?
            var result = minimax(player, newGame, turnDepthRemaining - 1);

            if (game.is_current_player(player)) {
                if (result.score > bestResult.score) {
                    bestResult.score = result.score;
                    bestResult.actions = result.actions;
                }
            } else {
                if (result.score < bestResult.score) {
                    bestResult.score = result.score;
                    bestResult.actions = result.actions;
                }
            }
        }

        return bestResult;
    }

    static function get_available_sets_of_actions(player :Player, game :Game, actionDepthRemaining :Int) :Array<Array<Action>> {

        trace('get_available_sets_of_actions actionDepthRemaining: $actionDepthRemaining');

        if (actionDepthRemaining <= 0) {
            trace('default case, actions: ${game.get_available_actions()}');
            return [game.get_available_actions()];
        }

        ai_iterations++;

        // trace('get_available_actions: ${game.get_available_actions()}');
        var actions :Array<Array<Action>> = [];
        for (action in game.get_available_actions()) {
            // trace('Trying action $action');
            var newGame = game.clone();
            newGame.do_action(action);

            var result = get_available_sets_of_actions(player, newGame, actionDepthRemaining - 1);
            // trace('result');
            // trace(result);
            actions.push([action]);
            for (resultActions in result) {
                actions.push([action].concat(resultActions)); // array<action>
            }
        }

        return actions;
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
