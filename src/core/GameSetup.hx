
package core;

import core.Game;
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
import cards.*;

import core.Tag;

import core.HexLibrary;

import core.Query;
using core.Query;
using core.Query.MinionQuery;

class GameSetup {
    static public function initialize() {
        CardLibrary.add(new Card({
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

        CardLibrary.add(new Card({
            name: 'Princess',
            tags: [
                Attack => 1,
                Life => 10,
                Hero => 1
            ]
        }));

        // ---------
        CardLibrary.add(new Card({
            name: 'Rat',
            cost: 2,
            tags: [
                Attack => 1,
                Life => 2
            ]
        }));

        CardLibrary.add(new Card({
            name: 'Fetid Rat',
            cost: 3,
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

        CardLibrary.add(new Card({
            name: 'Tyrannosaurus Rat',
            cost: 4,
            tags: [
                Attack => 5,
                Life => 3
            ]
        }));

        CardLibrary.add(new Card({
            name: 'Radioactive Rat',
            cost: 5,
            tags: [
                Attack => 2,
                Life => 4
            ]
        }));

        CardLibrary.add(new Card({
            name: 'Teddybear',
            cost: 2,
            description: 'Attack: 2\nLife: 2\n\nDraw card when dies',
            tags: [
                Attack => 2,
                Life => 2
            ],
            on_event: [
                Dies => function(_) { return [ DrawCard ]; }
            ]
        }));

        CardLibrary.add(new Card({
            name: 'Bunny',
            cost: 1,
            description: 'Attack: 1\nLife: 1\n\nCan move and attack immediately',
            tags: [
                Attack => 1,
                Life => 1,
                Moves => 1,
                Attacks => 1
            ]
        }));

        CardLibrary.add(new Card({
            name: 'Unicorn',
            cost: 1,
            description: 'Attack: 1\nLife: 2',
            tags: [
                Attack => 1,
                Life => 2
            ],
            on_event: [
                // When enters, give all nearby friendly minions +1 Attack
                Enter => function(query) {
                    return query.friendly().nearby().buff(Attack, 1);
                },
                // At the end of your turn give another random friendly minion +1 Health
                OwnTurnEnd => function(query) { 
                    return query.friendly().nearby().random().buff(Life, 1);
                }
            ]
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

        var human_player = new Player({
            name: 'Human Player',
            hand: [],
            deck: new Deck({
                name: 'Test Deck',
                cards: [
                    cardLibrary.create('Bunny', 0),
                    cardLibrary.create('Bunny', 0),
                    cardLibrary.create('Bunny', 0),
                    cardLibrary.create('Teddybear', 0),
                    cardLibrary.create('Teddybear', 0),
                    cardLibrary.create('Teddybear', 0),
                    cardLibrary.create('Unicorn', 0),
                    cardLibrary.create('Unicorn', 0),
                    cardLibrary.create('Unicorn', 0),
                    cardLibrary.create('Unicorn', 0),
                    cardLibrary.create('Ouch', 0),
                    cardLibrary.create('It\'s Raining Cards!', 0)
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
                    cardLibrary.create('Rat', 1),
                    cardLibrary.create('Rat', 1),
                    cardLibrary.create('Rat', 1),
                    cardLibrary.create('Rat', 1),
                    cardLibrary.create('Fetid Rat', 1),
                    cardLibrary.create('Fetid Rat', 1),
                    cardLibrary.create('Fetid Rat', 1),
                    cardLibrary.create('Tyrannosaurus Rat', 1),
                    cardLibrary.create('Tyrannosaurus Rat', 1),
                    cardLibrary.create('Radioactive Rat', 1)
                ]
            }),
            ai: true,
            color: 0xFF0000
        });

        var map = new Map<TileId, Tile>();
        for (hex in create_hexagon_map()) {
            if (hex.key == '0,0') continue; // HACK to create a hole in the middle of the map
            map[hex.key] = { hex: hex, mana: 1 };
        }
        var board = new Board(map);
        var orcTile = new Hex(1, -2, 0);
        var princessTile = new Hex(-1, 2, 0);
        board.tile(orcTile.key).minion = cardLibrary.create('Rat King', ai_player.id);
        board.tile(orcTile.key).minion.pos = orcTile.key;
        board.tile(princessTile.key).minion = cardLibrary.create('Princess', human_player.id);
        board.tile(princessTile.key).minion.pos = princessTile.key;
        var gameState = {
            board: board,
            players: [human_player, ai_player],
            cardIdCounter: cardLibrary.nextCardId,
            cards: [board.tile(orcTile.key).minion, board.tile(princessTile.key).minion]
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
