
package tests;

import core.Game;
import core.Minion;
import core.Board;
import core.RuleEngine;
import core.Actions;
import core.Player;
import core.Minimax;
import core.Deck;
import core.CardLibrary;
import core.MinionLibrary;
import cards.*;

class AIPlayer {
    static public function actions_for_turn(game :Game) :Array<Action> {
        var minimax = new Minimax({
            max_turn_depth: 1,
            max_action_depth: 2,
            score_function: score_board,
            min_delta_score: -4
        });

        var actions = minimax.best_actions(game);
        trace('AI tested ${minimax.actions_tested} different sets of actions');
        trace('AI chose $actions');
        return actions;
    }

    static function score_board(player :Player, game :Game) :Int {
        // score the players own stuff only
        function score_for_player(p) {
            var score :Float = 0;
            var intrinsicMinionScore = 1;
            for (minion in game.minions_for_player(p)) {
                score += intrinsicMinionScore + Math.max(minion.attack, 0) + Math.max(minion.life, 0);
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

class HumanPlayer {
    static public function action_to_string(action :Action, game :Game) {
        return switch (action) {
            case Move(m): 'Move ${game.minion(m.minionId).name} to ${m.pos.x}, ${m.pos.y}';
            case Attack(a): 'Attack ${game.minion(a.minionId).name} —> ${game.minion(a.victimId).name}';
            case PlayCard(c): 'Play ${c.card.name} to ${c.target.x}, ${c.target.y}';
            case NoAction: 'No Action';
        }
    }

    static public function actions_for_turn(game :Game) :Array<Action> {
        #if (neko || cpp)
        var newGame = game.clone();
        var actions = [];
        while (true) {
            newGame.print();

            var available_actions = newGame.actions();
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
        #else
        return [];
        #end
    }
}


// ---------------------------------------------------------------------------------------------------


class SimpleTestGame {
    static public function main() {
        play();
    }

    static public function create_game(?take_turn_function :Game->Array<Action>) :Game {
        CardLibrary.add(new Unicorn());

        MinionLibrary.add(new Minion({
            name: 'Goblin',
            attack: 1,
            life: 2
        }));

        MinionLibrary.add(new Minion({
            name: 'Troll',
            attack: 4,
            life: 1
        }));

        MinionLibrary.add(new Minion({
            name: 'Teddybear',
            attack: 2,
            life: 2
        }));

        MinionLibrary.add(new Minion({
            name: 'Bunny',
            attack: 0,
            life: 1
        }));

        MinionLibrary.add(new Minion({
            name: 'Unicorn',
            attack: 1,
            life: 2,
            // on_death: function() {
            //     trace('Unicorn::on_death!');
            //     return [ DrawCards(1) ];
            // },
            on_event: [
                // CardDrawn => function() {
                //     return [ Print("Unicorn saw that a card was drawn!") ];
                // },
                SelfEntered => function() {
                    return [ DrawCards(1) ];
                }
            ]
            // effect: function(event) {
            //     return switch (event) {
            //         case Death(minionId) && minionId == id: DrawCard;
            //         default: null;
            //     }
            // }
        }));

        var ai_player = new Player({
            name: 'AI Player',
            take_turn: AIPlayer.actions_for_turn,
            deck: new Deck({
                name: 'AI Test Deck',
                cards: [
                    CardLibrary.create('Unicorn')
                ]
            })
        });

        /*
            Unicorn should have an URANIUM ARMOR that has
            * Minion is invurnable but loses one life per turn
        */

        var human_player = new Player({
            name: 'Human Player',
            deck: new Deck({
                name: 'Test Deck',
                cards: [
                    CardLibrary.create('Unicorn'),
                    CardLibrary.create('Unicorn')
                ]
            }),
            hand: [
                CardLibrary.create('Unicorn')
            ],
            take_turn: (take_turn_function != null ? take_turn_function : HumanPlayer.actions_for_turn)
        });

        var tiles = { x: 3, y: 4 };
        function create_tile(x :Int, y :Int) :Tile {
            if (x == 1 && y == 0) return { minion: MinionLibrary.create('Troll', ai_player) };
            if (x == 1 && y == 1) return { minion: MinionLibrary.create('Goblin', ai_player) };
            if (x == 1 && y == 3) return { minion: MinionLibrary.create('Teddybear', human_player) };
            if (x == 2 && y == 3) return { minion: MinionLibrary.create('Bunny', human_player) };
            return {};
        }

        var gameState = {
            board: new Board(tiles.x, tiles.y, create_tile), // TODO: Make from a core.Map
            players: [human_player, ai_player]
            //rules: new Rules()
        };
        return new Game(gameState);
    }

    static public function play() {
        var game = create_game();
        while (!game.is_game_over()) {
            // trace('Game ID: ${Game.Id}');
            game.take_turn();
        }

        #if (neko || cpp)
        Sys.println("GAME OVER");
        game.print();
        Sys.stdin().readLine();
        #else
        trace("GAME OVER");
        game.print();
        #end
    }
}
