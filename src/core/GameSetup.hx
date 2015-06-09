
package core;

import core.Game;
import core.Minion;
import core.Board;
import core.RuleEngine;
import core.enums.Actions;
import core.enums.Commands;
import core.enums.Events;
import core.Card;
import core.Player;
import core.Minimax;
import core.Deck;
import core.CardLibrary;
import core.MinionLibrary;
import cards.*;

import core.HexLibrary;

class GameSetup {
    static public function initialize() {
        MinionLibrary.Add(new Minion({
            name: 'Orc Chieftain',
            attack: 3,
            life: 10,
            hero: true
        }));

        MinionLibrary.Add(new Minion({
            name: 'Princess',
            attack: 1,
            life: 10,
            hero: true
        }));

        // ---------

        MinionLibrary.Add(new Minion({
            name: 'Goblin',
            attack: 1,
            life: 2
        }));

        MinionLibrary.Add(new Minion({
            name: 'Troll',
            attack: 3,
            life: 1
        }));

        MinionLibrary.Add(new Minion({
            name: 'Teddybear',
            attack: 2,
            life: 2,
            on_event: [
                Died => function() { return [ DrawCard ]; }
            ]
        }));

        MinionLibrary.Add(new Minion({
            name: 'Bunny',
            attack: 1,
            life: 1,
            moves: 1,
            attacks: 1
        }));

        MinionLibrary.Add(new Minion({
            name: 'Unicorn',
            attack: 1,
            life: 2,
        }));

        CardLibrary.add(new Unicorn());
        CardLibrary.add(new core.Card({ 
            name: 'Rapid Bunny',
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
            targetType: TargetType.Minion,
            description: 'Deal 2 damage to a minion'
        }));

        // function healFunction(target :Target) :Array<Command> {
        //     switch target {
        //         case Global: return [Heal(ALL_OWN_MINIONS, 2)];
        //         case _: throw 'Ouch cannot target $target';
        //     }
        // }

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
            hand: [],
            deck: new Deck({
                name: 'Test Deck',
                cards: [
                    cardLibrary.create('Rapid Bunny'),
                    cardLibrary.create('Rapid Bunny'),
                    cardLibrary.create('Rapid Bunny'),
                    cardLibrary.create('Teddybear'),
                    cardLibrary.create('Teddybear'),
                    cardLibrary.create('Teddybear'),
                    cardLibrary.create('Unicorn'),
                    cardLibrary.create('Unicorn'),
                    cardLibrary.create('Unicorn'),
                    cardLibrary.create('Unicorn'),
                    cardLibrary.create('Ouch'),
                    cardLibrary.create('It\'s Raining Cards!')
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

        var map = new Map<TileId, Tile>();
        for (hex in create_hexagon_map()) {
            map[hex.key] = { hex: hex, mana: 1 };
        }
        var board = new Board(map);
        var orcTile = new Hex(1, -2, 0);
        var princessTile = new Hex(-1, 2, 0);
        board.tile(orcTile.key).minion = minionLibrary.create('Orc Chieftain', ai_player);
        board.tile(princessTile.key).minion = minionLibrary.create('Princess', human_player);
        var gameState = {
            board: board,
            players: [human_player, ai_player],
            cardIdCounter: cardLibrary.nextCardId,
            minionIdCounter: minionLibrary.nextMinionId
        };
        return new Game(gameState);
    }

    static function create_hexagon_map(radius :Int = 3) :Array<Hex> {
        var hexes = [];
        for (q in -radius + 1 ... radius) {
            var r1 = Math.round(Math.max(-radius, -q - radius));
            var r2 = Math.round(Math.min(radius, -q + radius));
            for (r in r1 + 1 ... r2) {
                hexes.push(new Hex(q, r, -q - r));
            }
        }
        return hexes;
    }
}
