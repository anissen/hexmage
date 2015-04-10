
package core;

import core.Minion;
import core.Actions;

typedef Tile = { ?minion :Minion };
typedef Tiles = Array<Array<Tile>>;

class Board {
    var boardSize :Point;
    var board :Tiles;
    
    public function new(boardWidth :Int, boardHeight :Int, create_tile :Int->Int->Tile) {
        boardSize = { x: boardWidth, y: boardHeight };
        board = [ for (y in 0 ... boardSize.y) [for (x in 0 ... boardSize.x) create_tile(x, y)]];
    }

    // public function handle_rules_for_minion(m :Minion /* + event type */) {
    //     for (rule in m.rules) {
    //         var applicable = switch (rule.trigger) {
    //             case OwnTurnStart: true;
    //             default: false;
    //         };
    //         if (!applicable) continue;
    //         switch (rule.effect) {
    //             case Scripted(f): trace('Doing scripted action'); f(this);
    //             default: throw 'Unhandled rule effect!';
    //         }
    //     }
    // }

    public function clone_board() :Board {
        function create_tile(x, y) {
            var tile = tile({ x: x, y: y });
            return { minion: (tile.minion != null ? tile.minion.clone() : null) };
        }
        return new Board(boardSize.x, boardSize.y, create_tile);
    }

    public function tile(pos :Point) {
        return board[pos.y][pos.x];
    }

    public function filter_tiles(func :Tile -> Bool) :Array<{ tile: Tile, pos :Point }> {
        var tiles = [];
        for (y in 0 ... board.length) {
            var row = board[y];
            for (x in 0 ... row.length) {
                var tile = row[x];
                if (func(tile)) {
                    tiles.push({ tile: tile, pos: { x: x, y: y } });
                }
            }
        }
        return tiles;
    }

    public function board_size() :Point {
        return boardSize;
    }

    public function print() {
        trace("Board:");
        for (row in board) {
            var s = "";
            for (tile in row) {
                s += (tile.minion != null ? '[${tile.minion.id}]' : "[ ]");
            }     
            trace(s);
        }
    }

    public function print_big() {
        function fill(text :String = ' ', maxLength :Int = 7) {
            return StringTools.rpad('', text, maxLength);
        }

        function fit(text :String, maxLength :Int = 7) {
            return StringTools.rpad(text.substr(0, maxLength), ' ', maxLength);
        }

        var playerColors = [green(), red()];
        var playerNames = ['Human Player', 'AI Player']; // HACK

        var s = '\n\nBoard:\n|';
        for (tile in board[0]) {
            s += '———————|';
        }     
        s += '\n';
        for (y in 0 ... board.length) {
            var row = board[y];
            for (i in 0 ... 3) {
                s += '|';
                for (x in 0 ... row.length) {
                    var tile = row[x];
                    if (tile.minion != null) {
                        s += playerColors[tile.minion.playerId];
                    }
                    s += switch (i) {
                        case 0: (tile.minion != null ? fit(playerNames[tile.minion.playerId]).toUpperCase() : fill());
                        case 1: (tile.minion != null ? fit('ID:${tile.minion.id}') : darkgrey() + fit(' ($x,$y)')); //tile.minion.name
                        case 2: (tile.minion != null ? fit('${tile.minion.attack} / ${tile.minion.life}') : fill());
                        case _: '?';
                    };
                    s += reset() + '|';
                }     
                s += '\n';
            }
            s += '|';
            for (tile in row) {
                s += '———————|';
            }     
            s += '\n';
        }
        trace(s);
    }

    public function minions() :Array<Minion> {
        var minions = [];
        for (row in board) {
            for (tile in row) {
                if (tile.minion != null) minions.push(tile.minion);
            }
        }
        return minions;
    }
        
    public function minions_for_player(playerId :Int) :Array<Minion> {
        var minions = [];
        for (row in board) {
            for (tile in row) {
                if (tile.minion != null && tile.minion.playerId == playerId) {
                    minions.push(tile.minion);
                }
            }
        }
        return minions;
    }
        
    public function minion(id :Int) :Minion {
        for (row in board) {
            for (tile in row) {
                if (tile.minion != null && tile.minion.id == id) {
                    return tile.minion;
                }
            }
        }
        return null;
    }

    public function minion_pos(minion :Minion) :Point {
        if (minion == null) throw 'Minion is null';
        for (y in 0 ... board.length) {
            var row = board[y];
            for (x in 0 ... row.length) {
                var tile = row[x];
                if (tile.minion != null && tile.minion.id == minion.id) return { x: x, y: y };
            }
        }
        throw 'Minion not found on board!';
    }

    // Colors: http://stackoverflow.com/questions/287871/print-in-terminal-with-colors-using-python
    static function reset()    { return "\033[0m";  }
    static function yellow()   { return "\033[93m"; }
    static function green()    { return "\033[92m"; }
    static function red()      { return "\033[91m"; }
    static function bright()   { return "\033[1m";  }
    static function dim()      { return "\033[2m";  }
    static function darkgrey()      { return "\033[90m";  }
    static function yellow_bg()      { return "\033[47m";  }
}
