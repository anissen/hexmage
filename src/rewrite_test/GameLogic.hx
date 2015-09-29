
package core;

import core.enums.Actions;
import core.enums.Commands;
import core.enums.Events;
import core.Card;

class GameLogic {
    var engine :GameEngine;

    public function new(engine) {
        this.engine = engine;
    }

    public function start() {
        state.turn = 0;
        for (minion in minions()) {
            emit(MinionEntered({ minion: minion.clone() }));
            handle_commands(minion.handle_event(MinionEvent.Enter));
            var pos = minion_pos(minion);
            minion.pos = pos; // HACK
            claim_tile(pos, minion, minion.playerId);
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
        for (minion in state.board.minions_for_player(current_player.id)) {
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
                    var minion = minion(id);
                    minion.life -= amount;
                    emit(MinionDamaged({ minion: minion.clone(), damage: amount }));
                    if (minion.life <= 0) {
                        emit(MinionDied({ minion: minion.clone() }));
                        handle_commands(minion.handle_event(MinionEvent.Dies));
                        var pos = minion_pos(minion);
                        state.board.tile(pos).minion = null;
                    }
                case DrawCard:
                    draw_card(current_player);
                case Effect(data):
                    var minion = minion(data.minionId);
                    for (tag in data.tags.keys()) {
                        minion.tags[tag] = data.tags[tag];
                    }
                    emit(EffectTriggered(data));
            }
        }
    }

    public function has_lost(player :Player) :Bool {
        for (minion in minions_for_player(player)) {
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
        for (minion in minions_for_player(current_player)) {
            handle_commands(minion.handle_event(OwnTurnEnd));
        }
        emit(TurnEnded({ player: current_player }));
        state.turn++;

        start_turn();
    }

    function move(moveAction :MoveActionData) {
        var minion = state.board.minion(moveAction.minionId);
        var currentPos = state.board.minion_pos(minion);
        state.board.tile(currentPos).minion = null;
        var toTile = state.board.tile(moveAction.tileId);
        toTile.minion = minion;
        minion.moves--;
        minion.pos = moveAction.tileId;
        emit(MinionMoved({ minion: minion.clone(), from: currentPos, to: moveAction.tileId }));
        if (minion.hero) {
            claim_tile(moveAction.tileId, minion, minion.playerId);
        }
    }

    function claim_tile(tileId :TileId, minion :Minion, playerId :Int) {
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
        var minion = state.board.minion(attackAction.minionId);
        var victim = state.board.minion(attackAction.victimId);

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
            var pos = minion_pos(victim);
            state.board.tile(pos).minion = null;
        }
        if (minion.life <= 0) {
            emit(MinionDied({ minion: minion.clone() })); // temp!
            handle_commands(minion.handle_event(MinionEvent.Dies));
            var pos = minion_pos(minion);
            state.board.tile(pos).minion = null;
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
            case MinionCard(minionName): playMinion(minionName, playCardAction.target);
            case SpellCard(castFunc): playSpell(castFunc, playCardAction.target);
        }
    }

    function playMinion(minionName :String, target :Target) {
        switch target {
            case Tile(tile, _): 
                var minion = minionLibrary.create(minionName, current_player);
                state.board.tile(tile).minion = minion;
                minion.pos = tile; // HACK
                emit(MinionEntered({ minion: minion.clone() }));
                handle_commands(minion.handle_event(MinionEvent.Enter));
            case _: throw 'Cannot play minion with this target: "$target"';
        }
    }

    function playSpell(castFunc :CastFunction, target :Target) {
        handle_commands(castFunc(target));
    }

    public function emit(event :Event) {
        engine.events.emit(event);
    }

    public function minions_for_player(player :Player) :Array<Minion> {
        return state.board.minions_for_player(player.id);
    }

    public function minion_pos(m :Minion) :TileId {
        return state.board.minion_pos(m);
    }

    public function minion(id :Int) :Null<Minion> {
        return state.board.minion(id);
    }

    public function minions() :Array<Minion> {
        return state.board.minions();
    }

    // public function tile_to_world(tileId :TileId) :luxe.Vector {
    //     // GIANT HACK!!!
    //     var hexSize = 70;
    //     var margin = 8;

    //     var layout = new Layout(Layout.pointy, new Point(hexSize + margin, hexSize + margin), new Point(Luxe.screen.mid.x, Luxe.screen.mid.y));
    //     var hex = state.board.tile(tileId).hex;
    //     var point = Layout.hexToPixel(layout, hex);
    //     return new luxe.Vector(point.x, point.y);
    // }




    // TODO: Should be removed
    public function actions_for_minion(minion :Minion) :Array<Action> {
        return RuleEngine.available_actions_for_minion(state, minion);
    }

    public function actions_for_card(card :Card) :Array<Action> {
        return RuleEngine.available_actions_for_card(state, current_player, card);
    }

    public function actions() :Array<Action> {
        return RuleEngine.available_actions(state, current_player);
    }




}
