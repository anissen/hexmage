
package tests;

import core.Game;
import core.Minion;
import core.Board;
import core.RuleEngine;
import core.Rules;
import core.Actions;
import core.Player;
import core.Minimax;
import core.Deck;
import cards.*;

class AIPlayer {
    static public function actions_for_turn(game :Game) :Array<Action> {
        var minimax = new Minimax({
            max_turn_depth: 3,
            max_action_depth: 2,
            score_function: score_board,
            min_delta_score: -4
        });

        var actions = minimax.get_best_actions(game);
        trace('AI tested ${minimax.actions_tested} different sets of actions');
        return actions;
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
    static public function action_to_string(action :Action, game :Game) {
        return switch (action) {
            case Move(m): 'Move ${game.get_minion(m.minionId).name} to ${m.pos.x}, ${m.pos.y}';
            case Attack(a): 'Attack ${game.get_minion(a.minionId).name} —> ${game.get_minion(a.victimId).name}';
            case PlayCard(c): 'Play ${c.card.name} to ${c.target.x}, ${c.target.y}';
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
                // trace(available_actions[i]);
                Sys.println('[${i + 1}] ${action_to_string(available_actions[i], newGame)}');
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
    public static var ai_player = new Player({
        id: 0,
        name: 'AI Player',
        deck: new Deck({ name: 'No Deck', cards: [] }),
        take_turn: AIPlayer.actions_for_turn
    });
    public static var goblin = new Minion({ 
        player: ai_player,
        name: 'Goblin',
        attack: 1,
        life: 2
    });
    public static var troll = new Minion({ 
        player: ai_player,
        name: 'Troll',
        attack: 4,
        life: 1
    });

    /*
        Unicorn should have an URANIUM ARMOR that has
        * Minion is invurnable but loses one life per turn
    */

    public static var human_player = new Player({ 
        id: 1,
        name: 'Human Player',
        deck: new Deck({ 
            name: 'Test Deck', 
            cards: [
                new Unicorn(),
            ]
        }),
        take_turn: HumanPlayer.actions_for_turn 
    });
    public static var teddy = new Minion({
        player: human_player,
        name: 'Teddybear',
        attack: 3,
        life: 3
    });

    public static var bunny = new Minion({
        player: human_player,
        name: 'Bunny',
        attack: 0,
        life: 1
    });
}


// ---------------------------------------------------------------------------------------------------


class SimpleTestGame {
    static public function main() {
        var tiles = { x: 3, y: 4 };
        function create_tile(x :Int, y :Int) :Tile {
            if (x == 1 && y == 0) return { minion: TestGame.troll.clone() };
            if (x == 1 && y == 1) return { minion: TestGame.goblin.clone() };
            if (x == 1 && y == 3) return { minion: TestGame.teddy.clone() };
            if (x == 2 && y == 3) return { minion: TestGame.bunny.clone() };
            return {};
        }

        var gameState = {
            board: new Board(tiles.x, tiles.y, create_tile), // TODO: Make from a core.Map
            players: [TestGame.human_player, TestGame.ai_player],
            rules: new Rules()
        };
        var game = new Game(gameState);
        
        while (!game.is_game_over()) {
            // trace('Game ID: ${Game.Id}');
            game.take_turn();
        }

        Sys.println("GAME OVER");
        game.print();
        Sys.stdin().readLine();
    }
}
