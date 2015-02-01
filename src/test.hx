
import core.Game;
import core.Minion;
import core.Board;
import core.RuleEngine;
import core.Rules;
import core.Actions;
import core.Player;

typedef BestActionsResult = { /* potentialScore :Int, */ score :Int, actions :Array<Action> };

class AIPlayer {
    static var ai_iterations = 0;

    static public function actions_for_turn(game :Game) :Array<Action> {
        ai_iterations = 0;

        game.get_state().board.print_board();

        var player = game.get_current_player();
        var currentScore = score_board(player, game);
        var result = minimax(player, game, 3 /* number of turns to test */);
        var deltaScore = result.score - currentScore;

        trace('AI tested ${ai_iterations} combinations of actions');  
        // TODO: Also write time spend
        trace('Best actions are ${result.actions} with a result of $result and a delta score of $deltaScore');

        // if (deltaScore < 0) {
        //     trace('Score of $deltaScore is not good enough');
        //     return [];
        // }

        // trace('actions: ${result.actions}');
        return result.actions;
    }

    static function get_indent(index :Int) {
        var s = '';
        for (i in 0 ... index) s += '-> ';
        return s;
    }

    static function indent_trace(index :Int, s :String) {
        trace('${get_indent(index)} $s');
    }

    static function minimax(player :Player, game :Game, maxTurns :Int, turn :Int = 0) :BestActionsResult {
        indent_trace(turn, 'minimax turn: $turn, player: ${game.get_current_player().name}');

        if (game.is_game_over() || turn >= maxTurns) {
            var turn_penalty = -turn;
            indent_trace(turn, 'SCORE: ${score_board(player, game) + turn_penalty}');
            return { score: score_board(player, game) + turn_penalty, actions: [] };
        }

        var set_of_all_actions = get_available_sets_of_actions(player, game, 2 /* number of actions per turns to test */);
        indent_trace(turn, 'ACTIONS: $set_of_all_actions');

        if (set_of_all_actions.length == 0) {
            var turn_penalty = -turn;
            return { score: score_board(player, game) + turn_penalty, actions: [] };
        }

        var bestResult = { score: (game.is_current_player(player) ? -1000 : 1000), actions: [] };
        for (actions in set_of_all_actions) {
            indent_trace(turn, '· TRYING $actions');

            var newGame = game.clone();
            newGame.do_turn(actions); // TODO: Make this return a clone instead?

            var result = minimax(player, newGame, maxTurns, turn + 1);
            indent_trace(turn, '· RESULT: ${result.score} for ${actions}');
            if (game.is_current_player(player)) {
                if (result.score > bestResult.score) {
                    // trace('::: BEST for current player');
                    bestResult.score = result.score;
                    bestResult.actions = actions;
                }
            } else { // ensure we only set actions if we simulate more turns
                if (result.score < bestResult.score) {
                    // trace('::: BEST for other player');
                    bestResult.score = result.score;
                    bestResult.actions = actions;
                }
            }
        }

        indent_trace(turn, 'BEST RESULT: ${bestResult.score} for ${bestResult.actions}');
        return bestResult;
    }

    static function get_available_sets_of_actions(player :Player, game :Game, actionDepthRemaining :Int) :Array<Array<Action>> {
        if (actionDepthRemaining <= 0)
            return [];

        ai_iterations++;

        var actions :Array<Array<Action>> = [];
        for (action in game.get_available_actions()) {
            var newGame = game.clone();
            newGame.do_action(action);

            var result = get_available_sets_of_actions(player, newGame, actionDepthRemaining - 1);
            actions.push([action]);
            for (resultActions in result) {
                actions.push([action].concat(resultActions));
            }
        }

        return actions;
    }

    static function score_board(player :Player, game :Game) :Int {
        var state = game.get_state();

        // score the players own stuff only
        function get_score_for_player(p) {
            var score = 0;
            var intrinsicMinionScore = 5;
            for (minion in state.board.get_minions_for_player(p)) {
                score += intrinsicMinionScore + minion.attack + minion.life;
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
        // return [Move({ minionId: 1, pos: { x: 1, y: 2 } })];
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

        var ai_player = { id: 0, name: 'AI Player', take_turn: AIPlayer.actions_for_turn };
        var goblin = new Minion({ 
            player: ai_player,
            id: 0,
            name: 'Goblin 1',
            attack: 2,
            life: 3,
            rules: new Rules(),
            movesLeft: 1,
            attacksLeft: 1
        });

        var human_player = { id: 1, name: 'Human Player', take_turn: HumanPlayer.actions_for_turn };
        var unicorn = new Minion({
            player: human_player,
            id: 1,
            name: 'Unicorn',
            attack: 2,
            life: 2,
            rules: new Rules(), /* [{ trigger: OwnTurnStart, effect: Scripted(plus_one_attack_per_turn) }] */
            movesLeft: 1,
            attacksLeft: 1
        });

        function create_tile(x :Int, y :Int) :Tile {
            if (x == 0 && y == 0) return { minion: goblin };
            if (x == 2 && y == 2) return { minion: unicorn };
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
            players: [ai_player, human_player],
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
