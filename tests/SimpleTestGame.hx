
package tests;

import core.Game;
import core.Minion;
import core.Board;
import core.RuleEngine;
import core.Rules;
import core.Actions;
import core.Player;
import core.Minimax;

class AIPlayer {
    static public function actions_for_turn(game :Game) :Array<Action> {
        var minimax = new Minimax({
            max_turn_depth: 3,
            max_action_depth: 2,
            score_function: score_board,
            min_delta_score: -4
        });

        return minimax.get_best_actions(game);
    }

    static function score_board(player :Player, game :Game) :Int {
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
            newGame.print();

            var available_actions = newGame.get_actions();
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
                continue;
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
        attacksLeft: 0,
        can_be_damaged: true,
        can_move: true,
        can_attack: true
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
        attacksLeft: 0,
        can_be_damaged: true,
        can_move: true,
        can_attack: true
    });

    public static function damage_self_effect(m :Minion) {
        m.life--;
    }

    /*
        Unicorn should have an URANIUM ARMOR that has
        * Minion is invurnable but loses one life per turn
    */

    public static var human_player = new Player({ id: 1, name: 'Human Player', take_turn: HumanPlayer.actions_for_turn });
    public static var unicorn = new Minion({
        player: human_player,
        id: 2,
        name: 'Unicorn',
        attack: 1,
        life: 6,
        rules: [{ turn_ends: damage_self_effect }],
        moves: 1,
        movesLeft: 0,
        attacks: 1,
        attacksLeft: 0,
        can_be_damaged: false, // armor
        can_move: true,
        can_attack: true
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
        attacksLeft: 0,
        can_be_damaged: true,
        can_move: true,
        can_attack: true,
        on_death: function(self :Minion) {
            //trace('I died! :(');
        }
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
        
        while (!game.is_game_over()) {
            trace('Game ID: ${Game.Id}');
            game.take_turn();
        }
        Sys.println("GAME OVER");
        game.print();
        Sys.stdin().readLine();
    }
}
