
package tests;

import core.Game;
import core.Minion;
import core.Board;
import core.RuleEngine;
import core.Rules;
import core.Actions;
import core.Player;

import mohxa.Mohxa;

typedef BestActionsResult = { score :Int, actions :Array<Action> };

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

    /*
    ERROR:

    Test.hx:45: ->  minimax turn: 1, player: Human Player
    Test.hx:45: -> ->  minimax turn: 2, player: AI Player
    Test.hx:45: ->  RESULT: -1 for Human Player with [Move({ pos => { x => 2, y => 1 }, minionId => 1 })]
    Test.hx:45: -> ->  minimax turn: 2, player: AI Player
    Test.hx:45: ->  RESULT: -1 for Human Player with [Move({ pos => { x => 2, y => 3 }, minionId => 1 })]
    Test.hx:45: -> ->  minimax turn: 2, player: AI Player
    Test.hx:45: -> -> ->  minimax turn: 3, player: Human Player
    Test.hx:45: -> ->  RESULT: 5 for AI Player with [Attack({ victimId => 1, minionId => 0 })]
    Test.hx:45: -> ->  BEST RESULT: 5 for [Attack({ victimId => 1, minionId => 0 })]
    Test.hx:45: ->  RESULT: 5 for Human Player with [Move({ pos => { x => 1, y => 2 }, minionId => 1 })]
    Test.hx:45: ->  BEST RESULT: -1 for [Move({ pos => { x => 2, y => 1 }, minionId => 1 })]
    */

    static function minimax(player :Player, game :Game, maxTurns :Int, turn :Int = 0) :BestActionsResult {
        indent_trace(turn, 'minimax turn: $turn, player: ${game.get_current_player().name}');

        if (game.is_game_over() || turn >= maxTurns) {
            var turn_penalty = -turn;
            // indent_trace(turn, 'SCORE: ${score_board(player, game) + turn_penalty}');
            return { score: score_board(player, game) + turn_penalty, actions: [] };
        }

        var set_of_all_actions = get_available_sets_of_actions(game, 2 /* number of actions per turns to test */);
        // indent_trace(turn, 'ACTIONS: $set_of_all_actions');

        if (set_of_all_actions.length == 0) {
            var turn_penalty = -turn;
            return { score: score_board(player, game) + turn_penalty, actions: [] };
        }

        var bestResult = { score: (game.is_current_player(player) ? -1000 : 1000), actions: [] };
        for (actions in set_of_all_actions) {
            // indent_trace(turn, '· TRYING $actions');

            var newGame = game.clone();
            newGame.do_turn(actions); // TODO: Make this return a clone instead?

            var result = minimax(player, newGame, maxTurns, turn + 1);
            var score = result.score;
            indent_trace(turn, 'RESULT: ${result.score} for ${game.get_current_player().name} with $actions');
            // if (result.score == 5 && !game.is_current_player(player)) {
            //     trace('--------------');
            //     trace('MAYBE ERROR HERE!!');
            //     trace('minimax turn: $turn, player: ${game.get_current_player().name}');
            //     trace(result);
            //     trace('--------------');
            // }
            /*
            |x| |y|
            AI:
            | |x|y| -> Move X (good score, e.g. 10)
            Human:
            | |-|y| -> Attack Y (bad score, e.g. 2)
            -> Bad move!
            */
            if (game.is_current_player(player)) {
                if (result.score > bestResult.score) {
                    // trace('::: BEST for current player');
                    bestResult.score = result.score;
                    bestResult.actions = actions;
                }
            } else {
                if (result.score < bestResult.score) {
                    // trace('::: BEST for other player');
                    bestResult.score = result.score;
                    bestResult.actions = actions;
                }
            }
        }

        indent_trace(turn, '== BEST RESULT: ${bestResult.score} for ${game.get_current_player().name} with ${bestResult.actions}');
        return bestResult;
    }

    static function get_available_sets_of_actions(game :Game, actionDepthRemaining :Int) :Array<Array<Action>> {
        if (actionDepthRemaining <= 0)
            return [];

        ai_iterations++;

        var actions :Array<Array<Action>> = [];
        for (action in game.get_available_actions()) {
            var newGame = game.clone();
            newGame.do_action(action);

            var result = get_available_sets_of_actions(newGame, actionDepthRemaining - 1);
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
            if (p.id == player.id) continue;
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

class TestGame {
    public static var ai_player = { id: 0, name: 'AI Player', take_turn: AIPlayer.actions_for_turn };
    public static var goblin = new Minion({ 
        player: ai_player,
        id: 0,
        name: 'Goblin 1',
        attack: 4,
        life: 4,
        rules: new Rules(),
        movesLeft: 1,
        attacksLeft: 1
    });

    public static var human_player = { id: 1, name: 'Human Player', take_turn: HumanPlayer.actions_for_turn };
    public static var unicorn = new Minion({
        player: human_player,
        id: 1,
        name: 'Unicorn',
        attack: 0,
        life: 1,
        rules: new Rules(), /* [{ trigger: OwnTurnStart, effect: Scripted(plus_one_attack_per_turn) }] */
        movesLeft: 0,
        attacksLeft: 0
    });
}

class MinimaxTrivialTests extends Mohxa {
    public function new() {
        super();

        var tiles = { x: 1, y: 2 };
        function create_tile(x :Int, y :Int) :Tile {
            if (x == 0 && y == 0) return { minion: TestGame.goblin };
            if (x == 0 && y == 1) return { minion: TestGame.unicorn };
            return {};
        }

        var gameState = {
            board: new Board(tiles.x, tiles.y, create_tile), // TODO: Make from a core.Map
            players: [TestGame.ai_player, TestGame.human_player],
            rules: new Rules()
        };
        var game = new Game(gameState);

        log('Minimax Trivial Tests');
        describe('Board setup', function() {
            var board = game.get_state().board;
            board.print_board();

            it('should be the correct size', function() {
                var size = board.get_board_size();
                equal(1, size.x, '1 tile wide');
                equal(2, size.y, '2 tiles height');
            });

            var ai_minion;
            var human_minion;

            describe('AI player', function() {
                var minions = board.get_minions_for_player(TestGame.ai_player);

                it('should start with one minion', function() {
                    equal(1, minions.length, '1 minion');
                });

                it('should have a minion of type "goblin"', function() {
                    equal(true, minions[0] == TestGame.goblin, 'Is of type "goblin"');
                });

                ai_minion = minions[0];
                it('should have correct properties', function() {
                    equal(4, ai_minion.attack, '4 attack value');
                    equal(4, ai_minion.life, '4 life');
                    equal(1, ai_minion.movesLeft, '1 move left');
                    equal(1, ai_minion.attacksLeft, '1 attack left');
                });

                it('should be positioned at (0, 0)', function() {
                    var pos = board.get_minion_pos(ai_minion);
                    equal(0, pos.x, 'x: 0');
                    equal(0, pos.y, 'y: 0');
                });
            });

            describe('Human player', function() {
                var minions = board.get_minions_for_player(TestGame.human_player);

                it('should start with one minion', function() {
                    equal(1, minions.length, '1 minion');
                });

                it('should have a minion of type "unicorn"', function() {
                    equal(true, minions[0] == TestGame.unicorn, 'Is of type "unicorn"');
                });

                human_minion = minions[0];
                it('should have correct properties', function() {
                    equal(0, human_minion.attack, '0 attack value');
                    equal(1, human_minion.life, '1 life');
                    equal(0, human_minion.movesLeft, '0 move left');
                    equal(0, human_minion.attacksLeft, '0 attack left');
                });

                it('should be positioned at (0, 1)', function() {
                    var pos = board.get_minion_pos(human_minion);
                    equal(0, pos.x, 'x: 0');
                    equal(1, pos.y, 'y: 1');
                });
            });

            it('should start with AI player as the current player', function() {
                equal(true, game.is_current_player(TestGame.ai_player), 'AI should be current player');
            });

            describe('AI turn', function() {
                it('should have the correct actions available', function() {
                    var actions = game.get_available_actions();
                    equal(1, actions.length, '1 action');

                    var action = actions[0];
                    equal('Attack', Type.enumConstructor(action), 'Action is an "attack" action');
                    var actionParams = Type.enumParameters(action)[0];
                    equal(ai_minion.id, actionParams.minionId, 'Attacker is the AI minion');
                    equal(human_minion.id, actionParams.victimId, 'Victim is the human minion');
                });

                it('should take the turn', function() {
                    log('AI player is taking the turn');
                    game.take_turn();

                    it('should have changed the board state', function() {
                        var ai_minons_changed = board.get_minions_for_player(TestGame.ai_player);
                        equal(1, ai_minons_changed.length, 'AI player should have 1 minion');
                        equal(0, ai_minons_changed[0].attacksLeft, 'AI minion should have 0 attacks left');
                        equal(1, ai_minons_changed[0].movesLeft, 'AI minion should have 1 moves left');

                        equal(0, board.get_minions_for_player(TestGame.human_player).length, 'Human player should have 0 minions');
                    });

                    it('should be game over', function() {
                        equal(true, game.is_game_over(), 'Game should be over');
                        equal(true, game.has_won(TestGame.ai_player), 'AI player should have won');
                        equal(false, game.has_won(TestGame.human_player), 'Human player should have lost');
                    });
                });
            });

            // game.take_turn(); // AI
            // game.take_turn(); // Human
            // game.take_turn(); // AI

            // it('should have killed the human players minion after a turn', function() {
            //     equal(1, game.get_state().board.get_minions_for_player(ai_player).length, 'should have 1 minion');
            //     equal(0, game.get_state().board.get_minions_for_player(human_player).length, 'should have 0 minions');
            // });
        });

        run();
    }
}

/*
class MinimaxTests extends Mohxa {
    public function new() {
        super();

        var tiles = { x: 3, y: 4 };

        function create_tile(x :Int, y :Int) :Tile {
            if (x == 0 && y == 1) return { minion: TestGame.goblin };
            if (x == 1 && y == 3) return { minion: TestGame.unicorn };
            return {};
        }

        var gameState = {
            board: new Board(tiles.x, tiles.y, create_tile), // TODO: Make from a core.Map
            players: [TestGame.ai_player, TestGame.human_player],
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

        // game.start();

        describe('Minimax Tests', function() {
            log('Here we test the minimax algorithm using a simple test game state');

            it('should start with both minions', function() {
                equal(1, game.get_state().board.get_minions_for_player(TestGame.ai_player).length, 'should have 1 minion');
                equal(1, game.get_state().board.get_minions_for_player(TestGame.human_player).length, 'should have 1 minion');
            });

            game.take_turn(); // AI
            game.take_turn(); // Human
            game.take_turn(); // AI

            it('should have killed the human players minion after a turn', function() {
                equal(1, game.get_state().board.get_minions_for_player(TestGame.ai_player).length, 'should have 1 minion');
                equal(0, game.get_state().board.get_minions_for_player(TestGame.human_player).length, 'should have 0 minions');
            });
        });

        run();
    }
}
*/
