
package core;

import core.Game;
import core.Minion;
import core.Board;
import core.RuleEngine;
import core.enums.Actions;
import core.Player;
import core.Minimax;
import core.Deck;
import core.CardLibrary;
import core.MinionLibrary;
import cards.*;

class GameSetup {
    /*
    new Game({
        //board: MapLibrary.create('Test Board'),
        players: [
            {
                name: 'Human Player',
                deck: DeckLibrary.create('Test Deck')
            },
            {
                name: 'AI Player',
                deck: DeckLibrary.create('Test Deck')
            } 
        ]
    });
    */

    static public function initialize() {
        MinionLibrary.Add(new Minion({
            name: 'Goblin',
            attack: 1,
            life: 2
        }));

        MinionLibrary.Add(new Minion({
            name: 'Troll',
            attack: 4,
            life: 1
        }));

        MinionLibrary.Add(new Minion({
            name: 'Teddybear',
            attack: 2,
            life: 2
        }));

        MinionLibrary.Add(new Minion({
            name: 'Bunny',
            attack: 0,
            life: 1
        }));

        MinionLibrary.Add(new Minion({
            name: 'Unicorn',
            attack: 1,
            life: 2,
        }));

        CardLibrary.add(new Unicorn());
        CardLibrary.add(new core.Card({ 
            name: 'Bunny',
            cost: 1,
            type: MinionCard('Bunny')
        }));
        CardLibrary.add(new core.Card({ 
            name: 'Teddybear',
            cost: 2,
            type: MinionCard('Teddybear')
        }));
        CardLibrary.add(new core.Card({ 
            name: 'Troll',
            cost: 3,
            type: MinionCard('Troll')
        }));
        CardLibrary.add(new core.Card({ 
            name: 'Goblin',
            cost: 2,
            type: MinionCard('Goblin')
        }));
    }

    static public function create_game() :Game {
        var human_player = new Player({
            name: 'Human Player',
            deck: new Deck({
                name: 'Test Deck',
                cards: [
                    CardLibrary.create('Bunny'),
                    CardLibrary.create('Bunny'),
                    CardLibrary.create('Bunny'),
                    CardLibrary.create('Teddybear'),
                    CardLibrary.create('Teddybear'),
                    CardLibrary.create('Teddybear'),
                    CardLibrary.create('Unicorn'),
                    CardLibrary.create('Unicorn'),
                    CardLibrary.create('Unicorn'),
                    CardLibrary.create('Unicorn')
                ]
            })
        });

        var ai_player = new Player({
            name: 'AI Player',
            deck: new Deck({
                name: 'AI Test Deck',
                cards: [
                    CardLibrary.create('Troll'),
                    CardLibrary.create('Troll'),
                    CardLibrary.create('Troll'),
                    CardLibrary.create('Troll'),
                    CardLibrary.create('Troll'),
                    CardLibrary.create('Goblin'),
                    CardLibrary.create('Goblin'),
                    CardLibrary.create('Goblin'),
                    CardLibrary.create('Goblin'),
                    CardLibrary.create('Goblin')
                ]
            })
        });

        var minionLibrary = new MinionLibrary(0);
        var tiles = { x: 3, y: 4 };
        var gameState = {
            board: new Board(tiles.x, tiles.y),
            players: [human_player, ai_player],
            minionIdCounter: minionLibrary.nextMinionId
        };
        return new Game(gameState);
    }
}
