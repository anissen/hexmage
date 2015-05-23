
package core;

import core.Game;
import core.Minion;
import core.Board;
import core.RuleEngine;
import core.enums.Actions;
import core.enums.Commands;
import core.Card;
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

        function ouchFunction(target :Target) :Array<Command> {
            switch target {
                case Character(id): return [Damage(id, 2)];
                case _: throw 'Ouch cannot target $target';
            }
        }

        CardLibrary.add(new core.Card({ 
            name: 'Ouch',
            cost: 2,
            type: SpellCard(ouchFunction),
            targetType: TargetType.Minion
            // type: SpellCard(function(event :Event) :Array<Command> {
            //     return switch event {
            //         case Cast
            //     }
            // })
        }));

        // function healFunction(target :Target) :Array<Command> {
        //     switch target {
        //         case Global: return [Heal(ALL_OWN_MINIONS, 2)];
        //         case _: throw 'Ouch cannot target $target';
        //     }
        // }

        // CardLibrary.add(new core.Card({ 
        //     name: 'Heal Own',
        //     cost: 2,
        //     type: SpellCard(ouchFunction),
        //     targetType: TargetType.Minion
        // }));

        function drawTwoCardsFunction(target :Target) :Array<Command> {
            switch target {
                case Global: return [DrawCard, DrawCard];
                case _: throw 'Ouch cannot target $target';
            }
        }

        CardLibrary.add(new core.Card({ 
            name: 'It\'s Raining Cards!',
            cost: 2,
            type: SpellCard(drawTwoCardsFunction),
            targetType: TargetType.Global
        }));
    }

    static public function create_game() :Game {
        var cardLibrary   = new CardLibrary(0);
        var minionLibrary = new MinionLibrary(0);

        var human_player = new Player({
            name: 'Human Player',
            hand: [
                cardLibrary.create('Ouch'),
                cardLibrary.create('It\'s Raining Cards!')
            ],
            deck: new Deck({
                name: 'Test Deck',
                cards: [
                    cardLibrary.create('Bunny'),
                    cardLibrary.create('Bunny'),
                    cardLibrary.create('Bunny'),
                    cardLibrary.create('Teddybear'),
                    cardLibrary.create('Teddybear'),
                    cardLibrary.create('Teddybear'),
                    cardLibrary.create('Unicorn'),
                    cardLibrary.create('Unicorn'),
                    cardLibrary.create('Unicorn'),
                    cardLibrary.create('Unicorn')
                ]
            }),
            ai: false
        });

        var ai_player = new Player({
            name: 'AI Player',
            hand: [],
            deck: new Deck({
                name: 'AI Test Deck',
                cards: [
                    cardLibrary.create('Troll'),
                    cardLibrary.create('Troll'),
                    cardLibrary.create('Troll'),
                    cardLibrary.create('Troll'),
                    cardLibrary.create('Troll'),
                    cardLibrary.create('Goblin'),
                    cardLibrary.create('Goblin'),
                    cardLibrary.create('Goblin'),
                    cardLibrary.create('Goblin'),
                    cardLibrary.create('Goblin')
                ]
            }),
            ai: true
        });

        var tiles = { x: 3, y: 4 };
        var gameState = {
            board: new Board(tiles.x, tiles.y),
            players: [human_player, ai_player],
            cardIdCounter: cardLibrary.nextCardId,
            minionIdCounter: minionLibrary.nextMinionId
        };
        return new Game(gameState);
    }
}
