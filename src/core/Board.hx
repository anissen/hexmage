
package core;

import core.Minion;
import core.enums.Actions;

import core.HexLibrary;
import core.TileId;

typedef Tile = { hex :Hex, ?claimed :Int, mana :Int, ?minion :Minion };
// typedef Tiles = Array<Array<Tile>>;
typedef PositionedTile = {
    > Tile,
    id: TileId,
}

class Board {
    // var boardSize :Point;
    // var board :Tiles;
    var tiles :Map<TileId, Tile>;
    
    public function new(tiles :Map<TileId, Tile>) {
        // boardSize = { x: boardWidth, y: boardHeight };
        // board = [ for (y in 0 ... boardSize.y) 
        //             [ for (x in 0 ... boardSize.x) (create_tile != null) ? create_tile(x, y) : { mana: 1 } ]
        //         ];
        this.tiles = tiles;
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
        // function create_tile(x, y) {
        //     var tile = tile({ x: x, y: y });
        //     return { claimed: tile.claimed, mana: (tile.mana != null ? tile.mana : 1 /* HACK */), minion: (tile.minion != null ? tile.minion.clone() : null) };
        // }
        // return new Board(boardSize.x, boardSize.y, create_tile);
        var newTiles = new Map<TileId, Tile>();
        for (key in tiles.keys()) {
            var tile = tiles[key];
            newTiles[key] = { hex: tile.hex, claimed: tile.claimed, mana: tile.mana, minion: (tile.minion != null ? tile.minion.clone() : null) };
        }
        return new Board(newTiles);
    }

    public function tile(key :TileId) :Tile {
        return tiles[key];
    }

    public function filter_tiles(func :PositionedTile -> Bool) :Array<PositionedTile> {
        var result = [];
        for (key in tiles.keys()) {
            var positionedTile :PositionedTile = cast tiles[key];
            positionedTile.id = key;
            if (func(positionedTile)) {
                result.push(positionedTile);
            }
        }
        return result;
    }

    public function claimed_tiles_for_player(playerId :Int) :Array<PositionedTile> {
        return filter_tiles(function(tile) {
            return (tile.claimed == playerId);
        });
    }

    public function mana_for_player(playerId :Int) :Int {
        var mana = 0;
        for (tile in claimed_tiles_for_player(playerId)) {
            mana += (tile.mana != null ? tile.mana : 0);
        }
        return mana;
    }

    /*
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
    */

    public function minions() :Array<Minion> {
        var minions = [];
        for (tile in tiles) {
            if (tile.minion != null) minions.push(tile.minion);
        }
        return minions;
    }
        
    public function minions_for_player(playerId :Int) :Array<Minion> {
        var minions = [];
        for (tile in tiles) {
            if (tile.minion != null && tile.minion.playerId == playerId) {
                minions.push(tile.minion);
            }
        }
        return minions;
    }
        
    public function minion(id :Int) :Minion {
        for (tile in tiles) {
            if (tile.minion != null && tile.minion.id == id) return tile.minion;
        }
        return null;
    }

    public function minion_pos(minion :Minion) :TileId {
        if (minion == null) throw 'Minion is null';
        for (key in tiles.keys()) {
            var tile = tiles[key];
            if (tile.minion != null && tile.minion.id == minion.id) return key;
        }
        throw 'Minion not found on board!';
    }

    // Colors: http://stackoverflow.com/questions/287871/print-in-terminal-with-colors-using-python
    // static function reset()    { return "\033[0m";  }
    // static function yellow()   { return "\033[93m"; }
    // static function green()    { return "\033[92m"; }
    // static function red()      { return "\033[91m"; }
    // static function bright()   { return "\033[1m";  }
    // static function dim()      { return "\033[2m";  }
    // static function darkgrey()      { return "\033[90m";  }
    // static function yellow_bg()      { return "\033[47m";  }
}
