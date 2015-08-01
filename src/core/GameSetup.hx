
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

import core.Tag;

import core.HexLibrary;

import core.Query;
using core.Query;

class GameSetup {
    static public function initialize() {
        MinionLibrary.Add(new Minion({
            name: 'Rat King',
            tags: [
                Attack => 3,
                Life => 10,
                Hero => 1
            ]
            // on_event: [
                // Entered => function() { /* taunt */ }
                // Always => function() { /* boost attack of nearby minions */ }
                // DidDamage => function(minion) { /* poison damaged minion */ }
                // Died => function() { return [ DrawCard ]; }
            // ]
        }));

        MinionLibrary.Add(new Minion({
            name: 'Princess',
            tags: [
                Attack => 1,
                Life => 10,
                Hero => 1
            ]
        }));

        // ---------
        MinionLibrary.Add(new Minion({
            name: 'Rat',
            tags: [
                Attack => 1,
                Life => 2
            ]
        }));

        MinionLibrary.Add(new Minion({
            name: 'Fetid Rat',
            tags: [
                Attack => 2,
                Life => 2
            ]
            // on_event: [
                // OWN_TURN_END.on(Buff(RANDOM_OTHER_FRIENDLY_MINION, "NEW1_037e"))
                // https://github.com/jleclanche/fireplace/blob/eaa288244a4fd303b109abb257473f6cf81dbb2c/fireplace/cards/classic/neutral_rare.py
                // On(OwnTurnEnd) => function() { Buff(RANDOM_OTHER_FRIENDLY_MINION, { Health: -1 }); }
            // ]
        }));

        MinionLibrary.Add(new Minion({
            name: 'Tyrannosaurus Rat',
            tags: [
                Attack => 5,
                Life => 3
            ]
        }));

        MinionLibrary.Add(new Minion({
            name: 'Radioactive Rat',
            tags: [
                Attack => 2,
                Life => 4
            ]
        }));

        MinionLibrary.Add(new Minion({
            name: 'Teddybear',
            tags: [
                Attack => 2,
                Life => 2
            ],
            on_event: [
                Dies => function(_) { return [ DrawCard ]; }
            ]
        }));

        MinionLibrary.Add(new Minion({
            name: 'Bunny',
            tags: [
                Attack => 1,
                Life => 1,
                Moves => 1,
                Attacks => 1
            ]
        }));

        MinionLibrary.Add(new Minion({
            name: 'Unicorn',
            tags: [
                Attack => 1,
                Life => 2
            ],
            on_event: [
                // At the end of your turn give another random friendly minion +1 Health
                Enter => function(self) {
                    var the_game = game.states.PlayScreenState.game;
                    // var tile = the_game.minion_pos(self);
                    var affected = the_game.minions()
                        .friendly(self.playerId);
                        // .nearby(pos.x, pos.y); // self.tags[PosX], tags[PosY]
                    return [ for (minion in affected) Effect({
                                    minionId: minion.id, 
                                    description: '+1 Attack',
                                    tags: [ Attack => minion.attack + 1 ]
                                }) ];
                },
                OwnTurnEnd => function(self) { 
                    var the_game = game.states.PlayScreenState.game;
                    // var pos = the_game.minion_pos(self);
                    var affected = the_game.minions()
                        .friendly(self.playerId);
                        // .nearby(pos.x, pos.y); // self.tags[PosX], tags[PosY]
                    return [ for (minion in affected) Effect({
                                    minionId: minion.id, 
                                    description: '+1 Health',
                                    tags: [ Life => minion.life + 1 ]
                                }) ];
                }
            ]
        }));

        CardLibrary.add(new core.Card({ 
            name: 'Unicorn',
            cost: 1,
            type: MinionCard('Unicorn'),
            description: 'Attack: 1\nLife: 2'
        }));
        CardLibrary.add(new core.Card({ 
            name: 'Rapid Bunny',
            cost: 1,
            type: MinionCard('Bunny'),
            description: 'Attack: 1\nLife: 1\n\nCan move and attack immediately'
        }));
        CardLibrary.add(new core.Card({ 
            name: 'Teddybear',
            cost: 2,
            type: MinionCard('Teddybear'),
            description: 'Attack: 2\nLife: 2\n\nDraw card when dies'
        }));
        CardLibrary.add(new core.Card({ 
            name: 'Rat',
            cost: 2,
            type: MinionCard('Rat')
        }));
        CardLibrary.add(new core.Card({ 
            name: 'Fetid Rat',
            cost: 3,
            type: MinionCard('Fetid Rat')
        }));
        CardLibrary.add(new core.Card({ 
            name: 'Tyrannosaurus Rat',
            cost: 4,
            type: MinionCard('Tyrannosaurus Rat')
        }));
        CardLibrary.add(new core.Card({ 
            name: 'Radioactive Rat',
            cost: 5,
            type: MinionCard('Radioactive Rat')
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
            ai: false,
            color: 0x00FF00
        });

        var ai_player = new Player({
            name: 'AI Player',
            hand: [],
            deck: new Deck({
                name: 'The Rat King',
                cards: [
                    cardLibrary.create('Rat'),
                    cardLibrary.create('Rat'),
                    cardLibrary.create('Rat'),
                    cardLibrary.create('Rat'),
                    cardLibrary.create('Fetid Rat'),
                    cardLibrary.create('Fetid Rat'),
                    cardLibrary.create('Fetid Rat'),
                    cardLibrary.create('Tyrannosaurus Rat'),
                    cardLibrary.create('Tyrannosaurus Rat'),
                    cardLibrary.create('Radioactive Rat')
                ]
            }),
            ai: true,
            color: 0xFF0000
        });

        var map = new Map<TileId, Tile>();
        for (hex in create_hexagon_map()) {
            map[hex.key] = { hex: hex, mana: 1 };
        }
        var board = new Board(map);
        var orcTile = new Hex(1, -2, 0);
        var princessTile = new Hex(-1, 2, 0);
        board.tile(orcTile.key).minion = minionLibrary.create('Rat King', ai_player);
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
