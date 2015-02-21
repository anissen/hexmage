
package tests;

import core.Game;
import core.Minion;
import core.Board;
import core.RuleEngine;
import core.Rules;
import core.Actions;
import core.Player;
import core.Minimax;

import mohxa.Mohxa;

typedef BestActionsResult = { score :Int, actions :Array<Action> };

class AIPlayer {
    static public function actions_for_turn(game :Game) :Array<Action> {
        var minimax = new Minimax({
            max_turn_depth: 3,
            max_action_depth: 2,
            min_delta_score: -4
        });

        return minimax.get_best_actions(game);
    }
}

class HumanPlayer {
    static public function actions_for_turn(game :Game) :Array<Action> {
        // return [Move({ minionId: 1, pos: { x: 1, y: 2 } })];
        return [];
    }
}

class TestGame {
    public static var ai_player = new Player({
        id: 0,
        name: 'AI Player',
        take_turn: AIPlayer.actions_for_turn
    });
    public static var goblin = new Minion({ 
        player: ai_player,
        name: 'Goblin 1',
        attack: 4,
        life: 4
    });

    public static var human_player = new Player({ 
        id: 1,
        name: 'Human Player',
        take_turn: HumanPlayer.actions_for_turn 
    });
    public static var unicorn = new Minion({
        player: human_player,
        name: 'Unicorn',
        attack: 0,
        life: 1
    });
}


// ---------------------------------------------------------------------------------------------------------


class MinimaxTrivialTests extends Mohxa {
    public function new() {
        super();

        this.use_colors = true;

        var tiles = { x: 1, y: 2 };
        function create_tile(x :Int, y :Int) :Tile {
            if (x == 0 && y == 0) return { minion: TestGame.goblin.clone() };
            if (x == 0 && y == 1) return { minion: TestGame.unicorn.clone() };
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
            game.print();

            it('should be the correct size', function() {
                var size = game.get_board_size();
                equal(1, size.x, '1 tile wide');
                equal(2, size.y, '2 tiles height');
            });

            var ai_minion;
            var human_minion;

            describe('AI player', function() {
                var minions = game.get_minions_for_player(TestGame.ai_player);

                it('should start with one minion', function() {
                    equal(1, minions.length, '1 minion');
                });

                it('should have a minion of type "goblin"', function() {
                    equal(true, minions[0].equals(TestGame.goblin), 'Is of type "goblin"');
                });

                ai_minion = minions[0];
                it('should have correct properties', function() {
                    equal(4, ai_minion.attack, '4 attack value');
                    equal(4, ai_minion.life, '4 life');
                    equal(1, ai_minion.movesLeft, '1 move left');
                    equal(1, ai_minion.attacksLeft, '1 attack left');
                });

                it('should be positioned at (0, 0)', function() {
                    var pos = game.get_minion_pos(ai_minion);
                    equal(0, pos.x, 'x: 0');
                    equal(0, pos.y, 'y: 0');
                });
            });

            describe('Human player', function() {
                var minions = game.get_minions_for_player(TestGame.human_player);

                it('should start with one minion', function() {
                    equal(1, minions.length, '1 minion');
                });

                it('should have a minion of type "unicorn"', function() {
                    equal(true, minions[0].equals(TestGame.unicorn), 'Is of type "unicorn"');
                });

                human_minion = minions[0];
                it('should have correct properties', function() {
                    equal(0, human_minion.attack, '0 attack value');
                    equal(1, human_minion.life, '1 life');
                    equal(1, human_minion.movesLeft, '1 move left');
                    equal(1, human_minion.attacksLeft, '1 attack left');
                });

                it('should be positioned at (0, 1)', function() {
                    var pos = game.get_minion_pos(human_minion);
                    equal(0, pos.x, 'x: 0');
                    equal(1, pos.y, 'y: 1');
                });
            });

            it('should start with AI player as the current player', function() {
                equal(true, game.is_current_player(TestGame.ai_player), 'AI should be current player');
            });

            describe('AI turn', function() {
                it('should have the correct actions available', function() {
                    var sets_of_actions = game.get_nested_actions(3);
                    equal(3, sets_of_actions.length, '3 sets of actions');

                    var attackAction = sets_of_actions[0];
                    equal(1, attackAction.length, 'containing list of 1 action');
                    equal('Attack', Type.enumConstructor(attackAction[0]), 'Action is an "Attack" action');

                    var actionParams = Type.enumParameters(attackAction[0])[0];
                    equal(ai_minion.id, actionParams.minionId, 'Attacker is the AI minion');
                    equal(human_minion.id, actionParams.victimId, 'Victim is the human minion');

                    var attackAndMoveAction = sets_of_actions[1];
                    equal('Attack', Type.enumConstructor(attackAndMoveAction[0]), 'First action is an "Attack" action');
                    equal('Move', Type.enumConstructor(attackAndMoveAction[1]), 'Second action is a "Move" action');

                    var noAction = sets_of_actions[2];
                    equal(1, noAction.length, 'No actions');
                    equal('NoAction', Type.enumConstructor(noAction[0]), 'Action is a "NoAction" action');
                });

                it('should take the turn', function() {
                    log('AI player is taking the turn');
                    game.take_turn();

                    it('should have changed the board state', function() {
                        var ai_minons_changed = game.get_minions_for_player(TestGame.ai_player);
                        equal(1, ai_minons_changed.length, 'AI player should have 1 minion');
                        equal(0, ai_minons_changed[0].attacksLeft, 'AI minion should have 0 attacks left');
                        equal(1, ai_minons_changed[0].movesLeft, 'AI minion should have 1 moves left');

                        equal(0, game.get_minions_for_player(TestGame.human_player).length, 'Human player should have 0 minions');
                    });

                    it('should be game over', function() {
                        equal(true, game.is_game_over(), 'Game should be over');
                        equal(true, game.has_won(TestGame.ai_player), 'AI player should have won');
                        equal(false, game.has_won(TestGame.human_player), 'Human player should have lost');
                    });
                });
            });
        });

        run();
    }
}


// ---------------------------------------------------------------------------------------------------------


class MinimaxTrivialTests2 extends Mohxa {
    public function new() {
        super();

        this.use_colors = true;

        var tiles = { x: 1, y: 3 };
        function create_tile(x :Int, y :Int) :Tile {
            if (x == 0 && y == 0) return { minion: TestGame.goblin.clone() };
            if (x == 0 && y == 2) return { minion: TestGame.unicorn.clone() };
            return {};
        }

        var gameState = {
            board: new Board(tiles.x, tiles.y, create_tile), // TODO: Make from a core.Map
            players: [TestGame.ai_player, TestGame.human_player],
            rules: new Rules()
        };
        var game = new Game(gameState);

        log('Minimax Trivial Tests 2');
        describe('Board setup', function() {
            game.print();

            it('should be the correct size', function() {
                var size = game.get_board_size();
                equal(1, size.x, '1 tile wide');
                equal(3, size.y, '3 tiles height');
            });

            var ai_minion;
            var human_minion;

            describe('AI player', function() {
                var minions = game.get_minions_for_player(TestGame.ai_player);

                it('should start with one minion', function() {
                    equal(1, minions.length, '1 minion');
                });

                it('should have a minion of type "goblin"', function() {
                    equal(true, minions[0].equals(TestGame.goblin), 'Is of type "goblin"');
                });

                ai_minion = minions[0];
                it('should have correct properties', function() {
                    equal(4, ai_minion.attack, '4 attack value');
                    equal(4, ai_minion.life, '4 life');
                    equal(1, ai_minion.movesLeft, '1 move left');
                    equal(1, ai_minion.attacksLeft, '1 attack left');
                });

                it('should be positioned at (0, 0)', function() {
                    var pos = game.get_minion_pos(ai_minion);
                    equal(0, pos.x, 'x: 0');
                    equal(0, pos.y, 'y: 0');
                });
            });

            describe('Human player', function() {
                var minions = game.get_minions_for_player(TestGame.human_player);

                it('should start with one minion', function() {
                    equal(1, minions.length, '1 minion');
                });

                it('should have a minion of type "unicorn"', function() {
                    equal(true, minions[0].equals(TestGame.unicorn), 'Is of type "unicorn"');
                });

                human_minion = minions[0];
                it('should have correct properties', function() {
                    equal(0, human_minion.attack, '0 attack value');
                    equal(1, human_minion.life, '1 life');
                    equal(1, human_minion.movesLeft, '1 move left');
                    equal(1, human_minion.attacksLeft, '1 attack left');
                });

                it('should be positioned at (0, 2)', function() {
                    var pos = game.get_minion_pos(human_minion);
                    equal(0, pos.x, 'x: 0');
                    equal(2, pos.y, 'y: 2');
                });
            });

            it('should start with AI player as the current player', function() {
                equal(true, game.is_current_player(TestGame.ai_player), 'AI should be current player');
            });

            describe('AI turn', function() {
                it('should have the correct actions available', function() {
                    var sets_of_actions = game.get_nested_actions(3);
                    trace('sets_of_actions');
                    trace(sets_of_actions);
                    equal(3, sets_of_actions.length, '3 sets of actions');

                    var moveAction = sets_of_actions[0];
                    equal(1, moveAction.length, 'containing list of 1 action');
                    equal('Move', Type.enumConstructor(moveAction[0]), 'Action is a "Move" action');

                    var moveAndAttackAction = sets_of_actions[1];
                    equal('Move', Type.enumConstructor(moveAndAttackAction[0]), 'First action is a "Move" action');
                    equal('Attack', Type.enumConstructor(moveAndAttackAction[1]), 'Second action is an "Attack" action');

                    var noAction = sets_of_actions[2];
                    equal(1, noAction.length, 'No actions');
                    equal('NoAction', Type.enumConstructor(noAction[0]), 'Action is a "NoAction" action');
                });

                it('should take the turn', function() {
                    log('AI player is taking the turn');
                    game.take_turn();

                    it('should have changed the board state', function() {
                        var ai_minons_changed = game.get_minions_for_player(TestGame.ai_player);
                        equal(1, ai_minons_changed.length, 'AI player should have 1 minion');
                        equal(0, ai_minons_changed[0].attacksLeft, 'AI minion should have 0 attacks left');
                        equal(0, ai_minons_changed[0].movesLeft, 'AI minion should have 0 moves left');

                        equal(0, game.get_minions_for_player(TestGame.human_player).length, 'Human player should have 0 minions');
                    });

                    it('should be game over', function() {
                        equal(true, game.is_game_over(), 'Game should be over');
                        equal(true, game.has_won(TestGame.ai_player), 'AI player should have won');
                        equal(false, game.has_won(TestGame.human_player), 'Human player should have lost');
                    });
                });
            });
        });

        run();
    }
}


// ---------------------------------------------------------------------------------------------------------


class MinimaxMultiTurnPlanningTests extends Mohxa {
    public function new() {
        super();

        this.use_colors = true;

        /*
        [0] (0, 0), goblin
        [ ] (0, 1)
        [ ] (0, 2)
        [1] (0, 3), unicorn
        */
        var tiles = { x: 1, y: 4 };
        function create_tile(x :Int, y :Int) :Tile {
            if (x == 0 && y == 0) return { minion: TestGame.goblin.clone() };
            if (x == 0 && y == 3) return { minion: TestGame.unicorn.clone() };
            return {};
        }

        var gameState = {
            board: new Board(tiles.x, tiles.y, create_tile), // TODO: Make from a core.Map
            players: [TestGame.ai_player, TestGame.human_player],
            rules: new Rules()
        };
        var game = new Game(gameState);

        log('MinimaxMultiTurnPlanningTests');
        describe('Board setup', function() {
            game.print();

            var ai_minion;
            var human_minion;

            describe('AI player', function() {
                var minions = game.get_minions_for_player(TestGame.ai_player);

                it('should start with one minion', function() {
                    equal(1, minions.length, '1 minion');
                });

                it('should have a minion of type "goblin"', function() {
                    equal(true, minions[0].equals(TestGame.goblin), 'Is of type "goblin"');
                });

                ai_minion = minions[0];
                it('should have correct properties', function() {
                    equal(4, ai_minion.attack, '4 attack value');
                    equal(4, ai_minion.life, '4 life');
                    equal(1, ai_minion.movesLeft, '1 move left');
                    equal(1, ai_minion.attacksLeft, '1 attack left');
                });

                it('should be positioned at (0, 0)', function() {
                    var pos = game.get_minion_pos(ai_minion);
                    equal(0, pos.x, 'x: 0');
                    equal(0, pos.y, 'y: 0');
                });
            });

            describe('Human player', function() {
                var minions = game.get_minions_for_player(TestGame.human_player);

                it('should start with one minion', function() {
                    equal(1, minions.length, '1 minion');
                });

                it('should have a minion of type "unicorn"', function() {
                    equal(true, minions[0].equals(TestGame.unicorn), 'Is of type "unicorn"');
                });

                human_minion = minions[0];
                it('should have correct properties', function() {
                    equal(0, human_minion.attack, '0 attack value');
                    equal(1, human_minion.life, '1 life');
                    equal(1, human_minion.movesLeft, '1 move left');
                    equal(1, human_minion.attacksLeft, '1 attack left');
                });

                it('should be positioned at (0, 3)', function() {
                    var pos = game.get_minion_pos(human_minion);
                    equal(0, pos.x, 'x: 0');
                    equal(3, pos.y, 'y: 3');
                });
            });

            it('should start with AI player as the current player', function() {
                equal(true, game.is_current_player(TestGame.ai_player), 'AI should be current player');
            });

            describe('AI turn', function() {
                it('should have the correct actions available', function() {
                    var sets_of_actions = game.get_nested_actions(3);
                    equal(2, sets_of_actions.length, '2 set of actions');

                    var moveAction = sets_of_actions[0];
                    equal(1, moveAction.length, 'containing list of 1 action');
                    equal('Move', Type.enumConstructor(moveAction[0]), 'Action is a "Move" action');

                    var noAction = sets_of_actions[1];
                    equal(1, noAction.length, 'No actions');
                    equal('NoAction', Type.enumConstructor(noAction[0]), 'Action is a "NoAction" action');
                });

                it('should take the turn', function() {
                    log('AI player is taking the turn');
                    game.take_turn();

                    it('should have changed the board state', function() {
                        var ai_minons_changed = game.get_minions_for_player(TestGame.ai_player);
                        equal(1, ai_minons_changed.length, 'AI player should have 1 minion');
                        equal(0, ai_minons_changed[0].movesLeft, 'AI minion should have 0 moves left');
                        var pos = game.get_minion_pos(ai_minons_changed[0]);
                        equal(0, pos.x, 'AI minion should be at x: 0');
                        equal(1, pos.y, 'AI minion should be at y: 1');
                    });
                });
            });

            describe('Human turn', function() {
                it('should have the correct actions available', function() {
                    var sets_of_actions = game.get_nested_actions(3);
                    equal(2, sets_of_actions.length, '2 set of actions');

                    var moveAction = sets_of_actions[0];
                    equal(1, moveAction.length, 'One action');
                    equal('Move', Type.enumConstructor(moveAction[0]), 'Action is a "Move" action');

                    var noAction = sets_of_actions[1];
                    equal(1, noAction.length, 'No actions');
                    equal('NoAction', Type.enumConstructor(noAction[0]), 'Action is a "NoAction" action');
                });

                it('should take the turn', function() {
                    log('Human player is taking the turn');
                    game.take_turn();

                    it('should not have moved the minion', function() {
                        var human_minons_changed = game.get_minions_for_player(TestGame.human_player);
                        equal(1, human_minons_changed.length, 'Human player should have 1 minion');
                        equal(1, human_minons_changed[0].movesLeft, 'Human minion should have 1 move left');
                        var pos = game.get_minion_pos(human_minons_changed[0]);
                        equal(0, pos.x, 'Human minion should be at x: 0');
                        equal(3, pos.y, 'Human minion should be at y: 3');
                    });
                });
            });

            describe('AI turn', function() {

                it('should have the correct actions available', function() {
                    var set_of_actions = game.get_nested_actions(3);
                    equal(4, set_of_actions.length, '4 set of actions');
                });

                it('should take the turn', function() {
                    log('AI player is taking the turn');
                    game.take_turn();

                    it('should have changed the board state', function() {
                        var ai_minons_changed = game.get_minions_for_player(TestGame.ai_player);
                        equal(1, ai_minons_changed.length, 'AI player should have 1 minion');
                        equal(0, game.get_minions_for_player(TestGame.human_player).length, 'Human should have 0 minions');
                    });
                });
            });
        });

        run();
    }
}

// ---------------------------------------------------------------------------------------------------------


class MinimaxFailingTest extends Mohxa {
    public function new() {
        super();

        this.use_colors = true;

        /*
        [ ][ ]
        [0][ ] goblin: (0, 1)
        [ ][ ]
        [ ][1] unicorn: (1, 3)
        */
        var tiles = { x: 2, y: 4 };
        function create_tile(x :Int, y :Int) :Tile {
            if (x == 0 && y == 1) return { minion: TestGame.goblin.clone() };
            if (x == 1 && y == 3) return { minion: TestGame.unicorn.clone() };
            return {};
        }

        var gameState = {
            board: new Board(tiles.x, tiles.y, create_tile), // TODO: Make from a core.Map
            players: [TestGame.ai_player, TestGame.human_player],
            rules: new Rules()
        };
        var game = new Game(gameState);

        log('FailingTest');
        describe('Board setup', function() {
            game.print();

            describe('AI turn', function() {
                it('should take the correct action', function() {
                    log('AI player is taking the turn');
                    game.take_turn();
                    game.print();
                    var goblin = game.get_minions_for_player(TestGame.ai_player)[0];
                    var pos = game.get_minion_pos(goblin);
                    equal(0, pos.x, 'AI minion should be at x: 0');
                    equal(2, pos.y, 'AI minion should be at y: 2');
                });
            });

            describe('Human turn', function() {
                game.print();
                it('should not take any action', function() {
                    log('Human player is taking the turn');
                    game.take_turn();

                    var unicorn = game.get_minions_for_player(TestGame.human_player)[0];
                    var pos = game.get_minion_pos(unicorn);
                    equal(1, pos.x, 'AI minion should be at x: 1');
                    equal(3, pos.y, 'AI minion should be at y: 3');
                });
            });

            describe('AI turn', function() {
                game.print();

                it('should take the correct action', function() {
                    log('AI player is taking the turn');
                    game.take_turn();

                    var goblin = game.get_minions_for_player(TestGame.ai_player)[0];
                    var pos = game.get_minion_pos(goblin);
                    equal(0, pos.x, 'AI minion should be at x: 0');
                    equal(3, pos.y, 'AI minion should be at y: 3');

                    equal(true, game.has_won(TestGame.ai_player));
                });
            });
        });

        run();
    }
}
