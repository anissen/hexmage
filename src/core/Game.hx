
package core;

import core.MinionLibrary;
import core.Player;
import core.Actions;
import core.Events;

typedef GameState = {
    var board :Board;
    var players :Players; // includes deck
    @:optional var current_player_index :Int;
};

typedef EventListenerFunction = Event -> Void;

class Game {
    var state :GameState;
    static public var Id :Int = 0;
    // @:isVar public var id(default, null) :Int;

    //var commandQueue :Commands;
    public var current_player (get, null) :Player;

    var listeners :List<EventListenerFunction>;

    public function new(_state :GameState) {
        state = _state;
        if (_state.current_player_index == null) state.current_player_index = 0;
        listeners = new List<EventListenerFunction>();
        //commandQueue = new Commands();
        Id++;
    }

    public function start() {
        emit(GameStarted);
        state.current_player_index = 0;
        for (player in players()) emit(PlayerEntered({ playerId: player.id }));
        for (minion in minions()) emit(MinionEntered({ minionId: minion.id }));

        start_turn();
    }

    function reset_minion_stats() :Void {
        for (minion in state.board.minions_for_player(current_player)) {
            minion.movesLeft = minion.moves;
            minion.attacksLeft = minion.attacks;
        }
    }

    function draw_cards() :Void {
        //trace('draw_cards');
        var player = current_player;
        var card = player.deck.draw();
        if (card == null) {
            // player is out of cards!
            return;
        }
        player.hand.push(card);

        // EMIT CardDrawn:
        for (minion in state.board.minions()) {
            // commandQueue
            //commandQueue = commandQueue.concat(minion.handle_event(CardDrawn));
            handle_commands(minion.handle_event(CardDrawn));
        }
    }

    function handle_commands(commands :Commands) :Void {
        for (command in commands) {
            switch (command) {
                case Print(s): trace('handle_commands: Print "$s"');
                case DrawCards(count):
                    trace('handle_commands: Draw $count card(s)');
                    for (i in 0 ... count) draw_cards();
            }
        }
    }

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

    function determine_available_sets_of_actions(actionDepthRemaining :Int) :Array<Array<Action>> {
        if (actionDepthRemaining <= 0)
            return [];

        var actions :Array<Array<Action>> = [];
        for (action in this.actions()) {
            var newGame = this.clone();
            newGame.do_action(action);

            var result = newGame.determine_available_sets_of_actions(actionDepthRemaining - 1);
            actions.push([action]);
            for (resultActions in result) {
                actions.push([action].concat(resultActions));
            }
        }

        return actions;
    }

    public function nested_actions(actionDepthRemaining :Int) :Array<Array<Action>> {
        var actions = determine_available_sets_of_actions(actionDepthRemaining);
        actions.push([NoAction]); // Include the no-action actions
        return actions;
    }

    public function clone() :Game {
        return new Game({
            board: state.board.clone_board(),
            players: state.players,
            current_player_index: state.current_player_index
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
        return state.players[state.current_player_index];
    }

    public function is_current_player(player :Player) :Bool {
        return current_player.id == player.id;
    }

    public function is_game_over() :Bool {
        for (player in state.players) {
            if (state.board.minions_for_player(player).length == 0)
                return true;
        }
        return false;
    }

    function start_turn() :Void {
        emit(TurnStarted);
        reset_minion_stats();
        draw_cards();
    }

    public function do_action(action :Action) :Void {
        switch (action) {
            case NoAction:
            case Move(m): move(m);
            case Attack(a): attack(a);
            case PlayCard(c): playCard(c);
        }
    }

    public function do_turn(actions :Array<Action>) :Void {
        for (action in actions) {
            // TODO: check action available
            do_action(action);
            // TODO: check victory/defeat
            if (has_won(current_player)) {
                emit(GameOver);
                return;
            }
        }
        end_turn();
    }

    public function end_turn() :Void {
        emit(TurnEnded);
        state.current_player_index = (state.current_player_index + 1) % state.players.length;

        start_turn();
    }

    function move(moveAction :MoveAction) {
        var minion = state.board.minion(moveAction.minionId);
        var currentPos = state.board.minion_pos(minion);
        state.board.tile(currentPos).minion = null;
        state.board.tile(moveAction.pos).minion = minion;
        minion.movesLeft--;
        emit(MinionMoved({ minionId: moveAction.minionId, from: currentPos, to: moveAction.pos }));
    }

    function attack(attackAction :AttackAction) {
        var minion = state.board.minion(attackAction.minionId);
        var victim = state.board.minion(attackAction.victimId);

        minion.attacksLeft--;
        
        emit(MinionAttacked(attackAction));

        victim.life -= minion.attack;
        emit(MinionDamaged({ minionId: victim.id, damage: minion.attack }));

        minion.life -= victim.attack;
        emit(MinionDamaged({ minionId: minion.id, damage: victim.attack }));
        
        if (victim.life <= 0) {
            emit(MinionDied({ minionId: victim.id })); // temp!
            var pos = minion_pos(victim);
            //if (victim.on_death != null)
            //    handle_commands(victim.on_death());
            state.board.tile(pos).minion = null;
        }
        if (minion.life <= 0) {
            emit(MinionDied({ minionId: minion.id })); // temp!
            var pos = minion_pos(minion);
            //handle_commands(minion.handle_event(MinionDied, { minionId: minion.id }));
            state.board.tile(pos).minion = null;
        }
    }

    function playCard(playCardAction :PlayCardAction) {
        var player = current_player;
        player.hand.remove(playCardAction.card);

        // handle
        switch (playCardAction.card.type) {
            case MinionCard(minionId): playMinion(minionId, playCardAction.target);
        }
    }

    function playMinion(minionId :String, target :Point) {
        var minion = MinionLibrary.create(minionId, current_player);
        state.board.tile(target).minion = minion;
        handle_commands(minion.handle_event(SelfEntered));
    }

    public function has_won(player :Player) :Bool {
        for (other_player in state.players) {
            if (other_player.id == player.id) continue;
            if (state.board.minions_for_player(other_player).length > 0)
                return false;
        }
        return true;
    }

    public function listen(func: EventListenerFunction) {
        listeners.add(func);
    }

    public function minions_for_player(player :Player) :Array<Minion> {
        return state.board.minions_for_player(player);
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
