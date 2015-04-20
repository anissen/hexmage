
package game.extensions;

import core.Point;
import luxe.Vector;

class PointTools {
    static public function tile_to_world(p :Point) :Vector {
        var tileSize = 120;
        return new Vector(180 + tileSize / 2 + p.x * (tileSize + 10), 10 + tileSize / 2 + p.y * (tileSize + 10));
    }
}
