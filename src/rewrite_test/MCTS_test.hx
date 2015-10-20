
/*
enum Play {
    Place(x :Int, y :Int);
    Move(fromX :Int, fromY :Int, toX :Int, toY :Int);
}
*/
typedef Play = { x: Int, y :Int };

typedef State = {
    positions :Array<Array<Int>>,
    player :Int
};
class Board {
    //var state :Array<Array<Int>>;
    var num_players :Int = 2;
    var player :Int = 0;
    
    public function new() {
        
    }
    
    public function start() :State {
        // Returns a representation of the starting state of the game.
        return { 
            positions: [
                [0, 0, 0],
                [0, 0, 0],
                [0, 0, 0]
            ],
            player: 1
        };
    }

    public function current_player(state :State) {
        // Takes the game state and returns the current player's number.
        return state.player;
    }

    public function next_state(state :State, play :Play) :State {
        // Takes the game state, and the move to be applied.
        // Returns the new game state.
        
        var new_state = { positions: state.positions.copy(), player: state.player };
        new_state.positions[play.y][play.x] = state.player;
        /*
        switch (play) {
            case Place(x, y):
                new_state[y][x] = state.player;
            case Move(fromX, fromY, toX, toY):
                new_state[fromY][fromX] = 0;
                new_state[toY][toX] = state.player;
        }
        */
        return new_state;
    }

    public function legal_plays(state_history :Array<State>) :Array<Play> {
        // Takes a sequence of game states representing the full
        // game history, and returns the full list of moves that
        // are legal plays for the current player.
        var state = state_history[state_history.length-1];
        var plays = [];
        for (y in 0 ... state.positions.length) {
            for (x in 0 ... state.positions[y].length) {
                if (state.positions[y][x] == 0) {
                    plays.push({ x: x, y: y });
                }
            }  
        }
        return plays;
    }

    public function winner(state_history :Array<State>) :Int {
        // Takes a sequence of game states representing the full
        // game history.  If the game is now won, return the player
        // number.  If the game is still ongoing, return zero.  If
        // the game is tied, return a different distinct value, e.g. -1.
        var state = state_history[state_history.length - 1];
        var player = 0;

        for (y in 0 ... state.positions.length) {
             var x0 = state.positions[y][0];
             var x1 = state.positions[y][1];
             var x2 = state.positions[y][2];
             if (x0 != 0 && x0 == x1 && x1 == x2) return x0;
        }

        for (x in 0 ... state.positions.length) {
             var y0 = state.positions[0][x];
             var y1 = state.positions[1][x];
             var y2 = state.positions[2][x];
             if (y0 != 0 && y0 == y1 && y1 == y2) return y0;
        }
        
        var p00 = state.positions[0][0];
        var p11 = state.positions[1][1];
        var p22 = state.positions[2][2];
        if (p00 != 0 && p00 == p11 && p11 == p22) return p00;

        var p20 = state.positions[0][2];
        var p02 = state.positions[2][0];
        if (p20 != 0 && p20 == p11 && p11 == p02) return p20;

        return 0;
    }
        
    public function display(state :State) {
        trace('-------');
        for (y in 0 ... state.positions.length) {
            var s = '|';
            for (x in 0 ... state.positions[y].length) {
                s += state.positions[y][x] + '|';
            }
            trace(s);
            trace('-------');
        }
    }
}

class MonteCarlo {
    var board :Board;
    var max_moves = 9 * 9;
    var max_time = 1;
    var states :Array<State>;
    var wins :Map<Int, Int>;
    var plays :Map<Int, Int>;
    
    public function new(board :Board, ?args) {
        // Takes an instance of a Board and optionally some keyword
        // arguments.  Initializes the list of game states and the
        // statistics tables.
        this.board = board;
        states = [];
        wins = new Map();
        plays = new Map();
    }

    public function update(state) {
        // Takes a game state, and appends it to the history.
    }

    public function get_play(states :Array<State>) :Null<Play> {
        // Causes the AI to calculate the best move from the
        // current game state and return it.
        var state = states[states.length - 1];
        var player = state.player;
        var legal = board.legal_plays(states);

        if (legal.length == 0) return null;
        if (legal.length == 1) return legal[0];

        states = [ for (play in legal) board.next_state(state, play) ];

        var begin = Date.now().getSeconds();
        var games = 0;
        while (Date.now().getSeconds() - begin < max_time) {
            run_simulation();
            games++;
        }

        trace('$games games simulated in ' + (Date.now().getSeconds() - begin) + ' seconds');
        /*
        var move = max(
            (self.wins[player].get(S,0) / self.plays[player].get(S,1), p)
            for p, S in states
        )[1]

        for x in sorted(((100 * self.wins[player].get(S,0)
                          / self.plays[player].get(S,1),
                          self.wins[player].get(S,0),
                          self.plays[player].get(S,0), p)
                         for p, S in states), reverse=True):
            print "{3}: {0:.2f}% ({1} / {2})".format(*x)

        return move
        */
        return null;
    }

    public function run_simulation() {
        // Plays out a "random" game from the current position,
        // then updates the statistics tables with the result.
    }
}

class Test {
    static function main() {
        var board = new Board();
        var new_state1 = board.next_state(board.start(), { x: 0, y: 0 });
        //var new_state2 = board.next_state(new_state1, { x: 1, y: 1 });
        //var new_state3 = board.next_state(new_state2, { x: 2, y: 2 });
        board.display(new_state1);
        //trace('Won? ' + board.winner([ board.start(), new_state1, new_state2, new_state3 ]));
        var ai = new MonteCarlo(board);
        trace('AI plays: ' + ai.get_play([new_state1]));
    }
}
