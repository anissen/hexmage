
package core;

import core.CardLibrary;
import core.MinionLibrary;
import core.Player;
import core.enums.Actions;
import core.enums.Events;

typedef GameState = {
    var board :Board;
    var players :Players; // includes deck
    @:optional var cardIdCounter :Int;
    @:optional var minionIdCounter :Int;
    @:optional var turn :Int;
};

typedef EventListenerFunction = Event -> Void;

typedef ActionTree = { current :Action, ?next :Array<ActionTree> };

class Game {
    var state :GameState;
    static public var Id :Int = 0;

    var cardLibrary :CardLibrary;
    var minionLibrary :MinionLibrary;
    // @:isVar public var id(default, null) :Int;

    //var commandQueue :Commands;
    public var current_player (get, null) :Player;

    var listeners :List<EventListenerFunction>;

    public function new(_state :GameState) {
        state = _state;
        
        var nextMinionId = (_state.minionIdCounter != null ? _state.minionIdCounter : 0);
        minionLibrary = new MinionLibrary(nextMinionId);

        var nextCardId = (_state.cardIdCounter != null ? _state.cardIdCounter : 0);
        cardLibrary = new CardLibrary(nextCardId);
        
        if (_state.turn == null) state.turn = 0;
        listeners = new List<EventListenerFunction>();
        //commandQueue = new Commands();
        Id++;
    }

    public function start() {
        state.turn = 0;
        // for (player in players()) emit(PlayerEntered({ player: player }));
        for (minion in minions()) emit(MinionEntered({ minion: minion.clone() }));
        for (player in players()) {
            player.deck.shuffle();
            for (i in 0 ... 4) draw_card(player);
        };

        emit(GameStarted);

        start_turn();
    }

    function reset_minion_stats() :Void {
        for (minion in state.board.minions_for_player(current_player.id)) {
            minion.movesLeft = minion.moves;
            minion.attacksLeft = minion.attacks;
        }
    }

    function draw_card(player :Player) {
        //trace('draw_card');
        // var player = current_player;
        var card = player.deck.draw();
        if (card == null) {
            // player is out of cards!
            return;
        }
        player.hand.push(card);

        emit(CardDrawn({ card: card, player: player }));

        /*
        // EMIT CardDrawn:
        for (minion in state.board.minions()) {
            // commandQueue
            //commandQueue = commandQueue.concat(minion.handle_event(CardDrawn));
            handle_commands(minion.handle_event(CardDrawn));
        }
        */
    }

    /*
    function handle_commands(commands :Commands) :Void {
        for (command in commands) {
            switch (command) {
                case Print(s): trace('handle_commands: Print "$s"');
                case DrawCards(count):
                    trace('handle_commands: Draw $count card(s)');
                    for (i in 0 ... count) draw_card();
            }
        }
    }
    */

    function emit(event :Event) :Void {
        for (listener in listeners) {
            listener(event);
        }
    }

    public function actions_for_minion(minion :Minion) :Array<Action> {
        return RuleEngine.available_actions_for_minion(state, minion);
    }

    public function actions() :Array<Action> {
        return RuleEngine.available_actions(state, current_player);
    }

    public function nested_actions(actionDepthRemaining :Int) :Array<ActionTree> {
        if (actionDepthRemaining <= 0)
            return [{ current: NoAction }];

        var actions :Array<ActionTree> = [];
        for (action in this.actions()) {
            var newGame = this.clone();
            newGame.do_action(action);

            // trace(action);

            var result = newGame.nested_actions(actionDepthRemaining - 1);
            actions.push({ current: action, next: result });
        }

        return actions;
    }

    public function clone() :Game {
        return new Game({
            board: state.board.clone_board(),
            players: state.players,
            turn: state.turn,
            cardIdCounter: cardLibrary.nextCardId,
            minionIdCounter: minionLibrary.nextMinionId
            //rules: state.rules // TODO: Should clone rules list
        });
    }

    // public function state() :GameState {
    //     return state;
    // }

    public function players() :Array<Player> {
        return state.players;
    }

    function get_current_player() :Player {
        return state.players[state.turn % state.players.length];
    }

    public function is_current_player(player :Player) :Bool {
        return current_player.id == player.id;
    }

    public function is_game_over() :Bool {
        if (state.turn < state.players.length) return false; // HACK to not game over on the first round
        for (player in state.players) {
            if (state.board.minions_for_player(player.id).length == 0)
                return true;
        }
        return false;
    }

    function start_turn() :Void {
        emit(TurnStarted({ player: current_player }));
        reset_minion_stats();
        draw_card(current_player);
        emit(PlayersTurn({ player: current_player }));
    }

    public function do_action(action :Action) :Void {
        switch (action) {
            case NoAction:
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
        emit(TurnEnded({ player: current_player }));
        state.turn++;

        start_turn();
    }

    function move(moveAction :MoveActionData) {
        var minion = state.board.minion(moveAction.minionId);
        var currentPos = state.board.minion_pos(minion);
        state.board.tile(currentPos).minion = null;
        state.board.tile(moveAction.pos).minion = minion;
        minion.movesLeft--;
        emit(MinionMoved({ minion: minion.clone(), from: currentPos, to: moveAction.pos }));
    }

    function attack(attackAction :AttackActionData) {
        var minion = state.board.minion(attackAction.minionId);
        var victim = state.board.minion(attackAction.victimId);

        minion.attacksLeft--;
        
        emit(MinionAttacked({ minion: minion.clone(), victim: victim.clone() }));

        victim.life -= minion.attack;
        emit(MinionDamaged({ minion: victim.clone(), damage: minion.attack }));

        if (victim.attack > 0) {
            minion.life -= victim.attack;
            emit(MinionDamaged({ minion: minion.clone(), damage: victim.attack }));
        }   
        
        if (victim.life <= 0) {
            emit(MinionDied({ minion: victim.clone() })); // temp!
            var pos = minion_pos(victim);
            //if (victim.on_death != null)
            //    handle_commands(victim.on_death());
            state.board.tile(pos).minion = null;
        }
        if (minion.life <= 0) {
            emit(MinionDied({ minion: minion.clone() })); // temp!
            var pos = minion_pos(minion);
            //handle_commands(minion.handle_event(MinionDied, { minionId: minion.id }));
            state.board.tile(pos).minion = null;
        }
    }

    function playCard(playCardAction :PlayCardActionData) {
        var player = current_player;
        player.hand.remove(playCardAction.card);

        emit(CardPlayed({ card: playCardAction.card, player: player }));

        // handle
        switch (playCardAction.card.type) {
            case MinionCard(minionName): playMinion(minionName, playCardAction.target);
        }
    }

    function playMinion(minionName :String, target :Point) {
        var minion = minionLibrary.create(minionName, current_player);
        state.board.tile(target).minion = minion;
        // handle_commands(minion.handle_event(SelfEntered));

        emit(MinionEntered({ minion: minion.clone() }));
    }

    public function has_won(player :Player) :Bool {
        for (other_player in state.players) {
            if (other_player.id == player.id) continue;
            if (state.board.minions_for_player(other_player.id).length > 0)
                return false;
        }
        return true;
    }

    public function listen(func: EventListenerFunction) {
        listeners.add(func);
    }

    public function minions_for_player(player :Player) :Array<Minion> {
        return state.board.minions_for_player(player.id);
    }

    public function board_size() :Point {
        return state.board.board_size();
    }

    public function minion_pos(m :Minion) :Point {
        return state.board.minion_pos(m);
    }

    public function minion(id :Int) :Null<Minion> {
        return state.board.minion(id);
    }

    public function minions() :Array<Minion> {
        return state.board.minions();
    }

    // public function tile(pos :Point) :Board.Tile {
    //     return state.board.tile(pos);
    // }

    public function print() {
        state.board.print_big();
    }
}
