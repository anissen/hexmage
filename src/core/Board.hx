
package core;

import core.enums.Actions;
import core.HexLibrary;
import core.TileId;

typedef Tile = { hex :Hex, ?claimed :Int, mana :Int /*, ?minion :Card */ };
typedef PositionedTile = {
    > Tile,
    id: TileId,
}

// Board consists of Tiles
// Tile: Key (hex)

class Board {
    var tiles :Map<TileId, Tile>;
    
    public function new(tiles :Map<TileId, Tile>) {
        this.tiles = tiles;
    }

    public function clone_board() :Board {
        var newTiles = new Map<TileId, Tile>();
        for (key in tiles.keys()) {
            var tile = tiles[key];
            newTiles[key] = { hex: tile.hex, claimed: tile.claimed, mana: tile.mana /*, minion: (tile.minion != null ? tile.minion.clone() : null) */ };
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

    public function each_tile(func :PositionedTile -> Void) :Void {
        for (key in tiles.keys()) {
            var positionedTile :PositionedTile = cast tiles[key];
            positionedTile.id = key;
            func(positionedTile);
        }
    }

    public function claimed_tiles_for_player(playerId :Int) :Array<PositionedTile> {
        return filter_tiles(function(tile) {
            return (tile.claimed == playerId);
        });
    }

    public function mana_for_player(playerId :Int) :Int {
        var mana = 0;
        for (tile in claimed_tiles_for_player(playerId)) {
            mana += tile.mana;
        }
        return mana;
    }

    /*
    public function minions() :Array<Card> {
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
    */
}
