
package game.extensions;

import core.Point;
import luxe.Vector;

class PointTools {
    static public function tile_to_world(p :Point) :Vector {
        var minSize = Math.min(Luxe.screen.w, Luxe.screen.h);
        var tileCount = 5;
        var tileMargin = 10;
        var tileSize = (minSize - tileMargin * tileCount) / tileCount; // 120;
        return new Vector(Luxe.screen.w / 2 - (tileSize * tileCount / 2) + tileMargin + tileSize / 2 + p.x * (tileSize + tileMargin), Luxe.screen.h / 2 - (tileSize * tileCount / 2) + tileMargin + tileSize / 2 + p.y * (tileSize + tileMargin));
    }
}
