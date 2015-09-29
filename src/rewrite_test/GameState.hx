
package core;

import core.CardLibrary;
import core.MinionLibrary;
import core.Player;
import core.enums.Actions;
import core.enums.Events;
import core.enums.Commands;
import core.HexLibrary; // TODO: This should not be here!

typedef GameStateData = {
    // var board :Board;
    var players :Map<Int, Player>; // includes deck
    var minions :Map<Int, Minion>;
    var cards :Map<Int, Card>;
    // @:optional var cardIdCounter :Int;
    // @:optional var minionIdCounter :Int;
    @:optional var turn :Int;
};

class GameState {
    var state :GameStateData;
    static public var Id :Int = 0;

    var cardLibrary :CardLibrary;
    var minionLibrary :MinionLibrary;

    public var current_player (get, null) :Player;

    public function new(_state :GameStateData) {
        state = _state;
        
        var nextMinionId = (_state.minionIdCounter != null ? _state.minionIdCounter : 0);
        minionLibrary = new MinionLibrary(nextMinionId);

        var nextCardId = (_state.cardIdCounter != null ? _state.cardIdCounter : 0);
        cardLibrary = new CardLibrary(nextCardId);
        
        if (_state.turn == null) state.turn = 0;
        Id++;
    }

    public function clone() :GameState {
        return new GameState({
            // board: state.board.clone_board(),
            players: clone_players(),
            turn: state.turn,
            cardIdCounter: cardLibrary.nextCardId,
            minionIdCounter: minionLibrary.nextMinionId
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
}
