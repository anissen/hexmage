
package core;

import core.CardLibrary;
import core.Player;
import core.enums.Actions;
import core.enums.Events;
import core.enums.Commands;
import core.Card;
import core.HexLibrary; // TODO: This should not be here!

using Lambda;
using core.Query;

typedef GameState = {
    var board :Board;
    var players :Players; // includes deck
    var cards :Array<Card>; // maybe change to Map<Int, Minion>
    @:optional var cardIdCounter :Int;
    @:optional var turn :Int;
};

typedef EventListenerFunction = Event -> Void;

typedef ActionTree = { current :Action, ?next :Array<ActionTree> };

class Game {
    var state :GameState;
    static public var Id :Int = 0;

    var cardLibrary :CardLibrary;

    public var current_player (get, null) :Player;

    var listeners :List<EventListenerFunction>;

    public function new(_state :GameState) {
        state = _state;
        
        var nextCardId = (_state.cardIdCounter != null ? _state.cardIdCounter : 0);
        cardLibrary = new CardLibrary(nextCardId);
        
        if (_state.turn == null) state.turn = 0;
        listeners = new List<EventListenerFunction>();
        Id++;
    }

    public function start() {
        state.turn = 0;
        for (minion in minions()) {
            emit(MinionEntered({ minion: minion.clone() }));
            handle_commands(minion.handle_event(MinionEvent.Enter));
            //var pos = minion.pos;
            //state.board.tile(pos).minion = minion;
            // minion.pos = pos; // HACK
            claim_tile(minion.pos, minion, minion.playerId);
        }
        for (player in players()) {
            for (card in player.hand) {
                emit(CardDrawn({ card: card, player: player }));
            }
            player.deck.shuffle();
            for (i in 0 ... 4) draw_card(player);
        };

        emit(GameStarted);

        start_turn();
    }

    function reset_minion_stats() :Void {
        for (minion in /* state.cards */ minions().player(current_player.id)) {
            minion.moves = minion.baseMoves;
            minion.attacks = minion.baseAttacks;
        }
    }

    function reset_mana() :Void {
        for (tile in state.board.claimed_tiles_for_player(current_player.id)) {
            if (tile.mana == 0) { // HACK, should check against tile.baseMana
                tile.mana = 1;
                emit(ManaGained({ gained: tile.mana, total: tile.mana, tileId: tile.id, player: current_player }));
            }
        }
    }

    function draw_card(player :Player) {
        var card = player.deck.draw();
        if (card == null) {
            // player is out of cards!
            return;
        }
        player.hand.push(card);

        emit(CardDrawn({ card: card, player: player }));
    }

    function handle_commands(commands :Commands) :Void {
        for (command in commands) {
            switch (command) {
                case Damage(id, amount):
                    var minion = get_minion(id);
                    minion.life -= amount;
                    emit(MinionDamaged({ minion: minion.clone(), damage: amount }));
                    if (minion.life <= 0) {
                        emit(MinionDied({ minion: minion.clone() }));
                        handle_commands(minion.handle_event(MinionEvent.Dies));
                        // var pos = minion_pos(minion);
                        // state.board.tile(pos).minion = null;
                        minion.zone = Graveyard;
                    }
                case DrawCard:
                    draw_card(current_player);
                case Effect(data):
                    var minion = get_minion(data.minionId);
                    for (tag in data.tags.keys()) {
                        minion.tags[tag] = data.tags[tag];
                    }
                    emit(EffectTriggered(data));
            }
        }
    }

    function emit(event :Event) :Void {
        for (listener in listeners) {
            listener(event);
        }
    }

    public function actions_for_minion(minion :Card) :Array<Action> {
        return RuleEngine.available_actions_for_minion(state, minion);
    }

    public function actions_for_card(card :Card) :Array<Action> {
        return RuleEngine.available_actions_for_card(state, current_player, card);
    }

    public function actions() :Array<Action> {
        return RuleEngine.available_actions(state, current_player);
    }

    public function clone() :Game {
        return new Game({
            board: state.board.clone_board(),
            players: clone_players(),
            turn: state.turn,
            cards: state.cards, // TODO: Clone??
            cardIdCounter: cardLibrary.nextCardId
        });
    }

    function clone_players() :Array<Player> {
        return [ for (p in state.players) p.clone() ];
    }

    public function players() :Array<Player> {
        return state.players;
    }

    function player(playerId :Int) :Player {
        return state.players[playerId % state.players.length];
    }

    function get_current_player() :Player {
        return state.players[state.turn % state.players.length];
    }

    public function is_current_player(player :Player) :Bool {
        return current_player.id == player.id;
    }

    public function has_lost(player :Player) :Bool {
        for (minion in minions().player(player.id)) {
            if (minion.hero) return false;
        }
        return true;
    }

    public function is_game_over() :Bool {
        for (player in state.players) {
            if (has_lost(player)) return true;
        }
        return false;
    }

    function start_turn() :Void {
        emit(TurnStarted({ player: current_player }));

        reset_minion_stats();
        reset_mana();
        draw_card(current_player);

        emit(PlayersTurn({ player: current_player }));
    }

    public function do_action(action :Action) :Void {
        switch (action) {
            case MoveAction(m): move(m);
            case AttackAction(a): attack(a);
            case PlayCardAction(c): playCard(c);
        }
        if (is_game_over()) {
            emit(GameOver);
        }
    }

    public function do_turn(actions :Array<Action>) :Void {
        for (action in actions) {
            // TODO: check action available
            do_action(action);
            if (is_game_over()) return;
        }
        end_turn();
    }

    public function end_turn() :Void {
        for (minion in /* state.cards*/ minions().player(current_player.id)) {
            handle_commands(minion.handle_event(OwnTurnEnd));
        }
        emit(TurnEnded({ player: current_player }));
        state.turn++;

        start_turn();
    }

    function move(moveAction :MoveActionData) {
        var minion = get_minion(moveAction.minionId);
        var currentPos = minion.pos;
        //state.board.tile(currentPos).minion = null;
        // var toTile = state.board.tile(moveAction.tileId);
        // toTile.minion = minion;
        minion.pos = moveAction.tileId;
        minion.moves--;
        emit(MinionMoved({ minion: minion.clone(), from: currentPos, to: moveAction.tileId }));
        if (minion.hero) {
            claim_tile(moveAction.tileId, minion, minion.playerId);
        }
    }

    function claim_tile(tileId :TileId, minion :Card, playerId :Int) {
        var tile = state.board.tile(tileId);
        if (tile.claimed == null) {
            emit(TileClaimed({ tileId: tileId, minion: minion.clone() }));
        } else if (tile.claimed != playerId) {
            emit(TileReclaimed({ tileId: tileId, minion: minion.clone() }));
        }
        tile.claimed = playerId;

        emit(ManaGained({ gained: tile.mana, total: tile.mana, tileId: tileId, player: player(playerId) }));
    }

    function attack(attackAction :AttackActionData) {
        var minion = get_minion(attackAction.minionId);
        var victim = get_minion(attackAction.victimId);

        minion.attacks--;
        
        emit(MinionAttacked({ minion: minion.clone(), victim: victim.clone() }));

        victim.life -= minion.attack;
        emit(MinionDamaged({ minion: victim.clone(), damage: minion.attack }));

        if (victim.attack > 0) {
            minion.life -= victim.attack;
            emit(MinionDamaged({ minion: minion.clone(), damage: victim.attack }));
        }   
        
        if (victim.life <= 0) {
            emit(MinionDied({ minion: victim.clone() })); // temp!
            handle_commands(victim.handle_event(MinionEvent.Dies));
            // var pos = minion_pos(victim);
            // state.board.tile(pos).minion = null;
            victim.zone = Graveyard;
        }
        if (minion.life <= 0) {
            emit(MinionDied({ minion: minion.clone() })); // temp!
            handle_commands(minion.handle_event(MinionEvent.Dies));
            // var pos = minion_pos(minion);
            // state.board.tile(pos).minion = null;
            minion.zone = Graveyard;
        }
    }

    function playCard(playCardAction :PlayCardActionData) {
        var player = current_player;
        for (card in player.hand) {
            if (card.id == playCardAction.card.id) {
                player.hand.remove(card);
                break;
            }
        }

        var cardCost = playCardAction.card.cost;
        var remainingCost = cardCost;
        for (tile in state.board.claimed_tiles_for_player(player.id)) {
            var manaPaid = 0;
            if (remainingCost >= tile.mana) {
                manaPaid = tile.mana;
                tile.mana = 0;
            } else {
                var diff = (tile.mana - remainingCost);
                manaPaid -= diff;
                tile.mana -= diff; 
            }
            remainingCost -= manaPaid;
            emit(ManaSpent({ spent: manaPaid, left: tile.mana, tileId: tile.id, player: player }));
            if (remainingCost <= 0) break;
        }

        emit(CardPlayed({ card: playCardAction.card, player: player }));

        // handle
        switch (playCardAction.card.type) {
            case MinionCard: playMinion(playCardAction.card.id /* HACK */, playCardAction.target);
            case SpellCard(castFunc): playSpell(castFunc, playCardAction.target);
        }
    }

    function playMinion(id :Int, target :Target) {
        switch target {
            case Tile(tile, _): 
                // TODO: This probably doesn't work!
                var minion = get_card(id); //cardLibrary.create(minionName, current_player.id);
                //state.board.tile(tile).minion = minion;
                minion.pos = tile;
                minion.zone = Board;
                emit(MinionEntered({ minion: minion.clone() }));
                handle_commands(minion.handle_event(MinionEvent.Enter));
            case _: throw 'Cannot play minion with this target: "$target"';
        }
    }

    function playSpell(castFunc :CastFunction, target :Target) {
        handle_commands(castFunc(target));
    }

    public function listen(func: EventListenerFunction) {
        listeners.add(func);
    }

    public function get_minion(id :Int) :Null<Card> {
        return minions().find(function(minion) {
            return minion.id == id;
        });
    }

    public function get_card(id :Int) :Null<Card> {
        return cards().find(function(card) {
            return card.id == id;
        });
    }

    public inline function minions() :Array<Card> {
        return cards().zone(Board);
    }

    public inline function cards() :Array<Card> {
        return state.cards;
    }

    public function tile_to_world(tileId :TileId) :luxe.Vector {
        // GIANT HACK!!!
        var hexSize = 70;
        var margin = 8;

        var layout = new Layout(Layout.pointy, new Point(hexSize + margin, hexSize + margin), new Point(Luxe.screen.mid.x, Luxe.screen.mid.y));
        var hex = state.board.tile(tileId).hex;
        var point = Layout.hexToPixel(layout, hex);
        return new luxe.Vector(point.x, point.y);
    }
}
