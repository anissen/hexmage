
package core;

class Point
{
    public function new(x:Float, y:Float)
    {
        this.x = x;
        this.y = y;
    }
    public var x:Float;
    public var y:Float;
}

class Hex {
    public function new(q :Int, r :Int, s :Int) {
        this.q = q;
        this.r = r;
        this.s = s;
    }
    public var q :Int;
    public var r :Int;
    public var s :Int;

    public var key(get, null) :String;

    public function get_key() :String {
        return '$q,$r';
    }    
}

class HexTools {
    static public function add(a :Hex, b :Hex) :Hex {
        return new Hex(a.q + b.q, a.r + b.r, a.s + b.s);
    }

    static public function subtract(a :Hex, b :Hex) :Hex {
        return new Hex(a.q - b.q, a.r - b.r, a.s - b.s);
    }

    static public function scale(a :Hex, k :Int) :Hex {
        return new Hex(a.q * k, a.r * k, a.s * k);
    }

    static public var directions:Array<Hex> = [new Hex(1, 0, -1), new Hex(1, -1, 0), new Hex(0, -1, 1), new Hex(-1, 0, 1), new Hex(-1, 1, 0), new Hex(0, 1, -1)];

    static public function direction(dir:Int) :Hex {
        return directions[dir];
    }

    static public function neighbor(hex:Hex, dir:Int) :Hex {
        return add(hex, direction(dir));
    }

    static public var diagonals:Array<Hex> = [new Hex(2, -1, -1), new Hex(1, -2, 1), new Hex(-1, -1, 2), new Hex(-2, 1, 1), new Hex(-1, 2, -1), new Hex(1, 1, -2)];

    static public function diagonalNeighbor(hex:Hex, dir:Int) :Hex {
        return add(hex, diagonals[dir]);
    }

    static public function length(hex :Hex) :Int {
        return Std.int((Math.abs(hex.q) + Math.abs(hex.r) + Math.abs(hex.s)) / 2);
    }

    static public function distance(a :Hex, b :Hex) :Int {
        return length(subtract(a, b));
    }

    static public function ring(center :Hex, radius :Int) :Array<Hex> {
        var results = [];
        var hex = add(center, scale(direction(4), radius));
        for (i in 0...6) {
            for (j in 0...radius) {
                results.push(hex);
                hex = neighbor(hex, i);
            }
        }
        return results;
    }

    static public function neighbors(hex :Hex) :Array<Hex> {
        return ring(hex, 1);
    }

    static public function rings(center :Hex, start_radius :Int = 1, radius :Int = 1) :Array<Hex> {
        var results = [];
        for (k in start_radius ... start_radius + radius) {
            results = results.concat(ring(center, k));
        }
        return results;
    }

    static public function reachable(start :Hex, is_walkable :Hex -> Bool, movement :Int = 1) :Array<Hex> {
        var result = [];
        var visited = new Map();
        visited[start.key] = start;
        var fringes = [];
        fringes.push([start]);

        for (k in 1 ... movement + 1) {
            fringes.push([]);
            for (hex in fringes[k - 1]) {
                for (dir in 0 ... 6) {
                    var neighbor = neighbor(hex, dir);
                    if (visited.exists(neighbor.key) || !is_walkable(neighbor)) continue;
                    visited[neighbor.key] = neighbor;
                    fringes[k].push(neighbor);
                    result.push(neighbor);
                }
            }
        }

        return result;
    }
}

class FractionalHex
{
    public function new(q:Float, r:Float, s:Float)
    {
        this.q = q;
        this.r = r;
        this.s = s;
    }
    public var q:Float;
    public var r:Float;
    public var s:Float;

    static public function hexRound(h:FractionalHex):Hex
    {
        var q:Int = Math.round(h.q);
        var r:Int = Math.round(h.r);
        var s:Int = Math.round(h.s);
        var q_diff:Float = Math.abs(q - h.q);
        var r_diff:Float = Math.abs(r - h.r);
        var s_diff:Float = Math.abs(s - h.s);
        if (q_diff > r_diff && q_diff > s_diff)
        {
            q = -r - s;
        }
        else
            if (r_diff > s_diff)
            {
                r = -q - s;
            }
            else
            {
                s = -q - r;
            }
        return new Hex(q, r, s);
    }


    static public function hexLerp(a:Hex, b:Hex, t:Float):FractionalHex
    {
        return new FractionalHex(a.q + (b.q - a.q) * t, a.r + (b.r - a.r) * t, a.s + (b.s - a.s) * t);
    }


    static public function hexLinedraw(a:Hex, b:Hex):Array<Hex>
    {
        var N:Int = HexTools.distance(a, b);
        var results:Array<Hex> = [];
        var step:Float = 1.0 / Math.max(N, 1);
        for (i in 0...N + 1)
        {
            results.push(FractionalHex.hexRound(FractionalHex.hexLerp(a, b, step * i)));
        }
        return results;
    }

}

class OffsetCoord
{
    public function new(col:Int, row:Int)
    {
        this.col = col;
        this.row = row;
    }
    public var col:Int;
    public var row:Int;
    static public var EVEN:Int = 1;
    static public var ODD:Int = -1;

    static public function qoffsetFromCube(offset:Int, h:Hex):OffsetCoord
    {
        var col:Int = h.q;
        var row:Int = h.r + Std.int((h.q + offset * (h.q & 1)) / 2);
        return new OffsetCoord(col, row);
    }


    static public function qoffsetToCube(offset:Int, h:OffsetCoord):Hex
    {
        var q:Int = h.col;
        var r:Int = h.row - Std.int((h.col + offset * (h.col & 1)) / 2);
        var s:Int = -q - r;
        return new Hex(q, r, s);
    }


    static public function roffsetFromCube(offset:Int, h:Hex):OffsetCoord
    {
        var col:Int = h.q + Std.int((h.r + offset * (h.r & 1)) / 2);
        var row:Int = h.r;
        return new OffsetCoord(col, row);
    }


    static public function roffsetToCube(offset:Int, h:OffsetCoord):Hex
    {
        var q:Int = h.col - Std.int((h.row + offset * (h.row & 1)) / 2);
        var r:Int = h.row;
        var s:Int = -q - r;
        return new Hex(q, r, s);
    }

}

class Orientation
{
    public function new(f0:Float, f1:Float, f2:Float, f3:Float, b0:Float, b1:Float, b2:Float, b3:Float, start_angle:Float)
    {
        this.f0 = f0;
        this.f1 = f1;
        this.f2 = f2;
        this.f3 = f3;
        this.b0 = b0;
        this.b1 = b1;
        this.b2 = b2;
        this.b3 = b3;
        this.start_angle = start_angle;
    }
    public var f0:Float;
    public var f1:Float;
    public var f2:Float;
    public var f3:Float;
    public var b0:Float;
    public var b1:Float;
    public var b2:Float;
    public var b3:Float;
    public var start_angle:Float;
}

class Layout
{
    public function new(orientation:Orientation, size:Point, origin:Point)
    {
        this.orientation = orientation;
        this.size = size;
        this.origin = origin;
    }
    public var orientation:Orientation;
    public var size:Point;
    public var origin:Point;
    static public var pointy:Orientation = new Orientation(Math.sqrt(3.0), Math.sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0, Math.sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0, 0.5);
    static public var flat:Orientation = new Orientation(3.0 / 2.0, 0.0, Math.sqrt(3.0) / 2.0, Math.sqrt(3.0), 2.0 / 3.0, 0.0, -1.0 / 3.0, Math.sqrt(3.0) / 3.0, 0.0);

    static public function hexToPixel(layout:Layout, h:Hex):Point
    {
        var M:Orientation = layout.orientation;
        var size:Point = layout.size;
        var origin:Point = layout.origin;
        var x:Float = (M.f0 * h.q + M.f1 * h.r) * size.x;
        var y:Float = (M.f2 * h.q + M.f3 * h.r) * size.y;
        return new Point(x + origin.x, y + origin.y);
    }

    static public function pixelToHex(layout:Layout, p:Point):FractionalHex
    {
        var M:Orientation = layout.orientation;
        var size:Point = layout.size;
        var origin:Point = layout.origin;
        var pt:Point = new Point((p.x - origin.x) / size.x, (p.y - origin.y) / size.y);
        var q:Float = M.b0 * pt.x + M.b1 * pt.y;
        var r:Float = M.b2 * pt.x + M.b3 * pt.y;
        return new FractionalHex(q, r, -q - r);
    }

    static public function hexCornerOffset(layout:Layout, corner:Int):Point
    {
        var M:Orientation = layout.orientation;
        var size:Point = layout.size;
        var angle:Float = 2.0 * Math.PI * (corner + M.start_angle) / 6;
        return new Point(size.x * Math.cos(angle), size.y * Math.sin(angle));
    }

    static public function polygonCorners(layout:Layout, h:Hex):Array<Point>
    {
        var corners:Array<Point> = [];
        var center:Point = Layout.hexToPixel(layout, h);
        for (i in 0...6)
        {
            var offset:Point = Layout.hexCornerOffset(layout, i);
            corners.push(new Point(center.x + offset.x, center.y + offset.y));
        }
        return corners;
    }
}


class Tests
{
    public function new()
    {
    }

    static public function equalHex(name:String, a:Hex, b:Hex):Void
    {
        if (!(a.q == b.q && a.s == b.s && a.r == b.r))
        {
            Tests.complain(name);
        }
    }


    static public function equalOffsetcoord(name:String, a:OffsetCoord, b:OffsetCoord):Void
    {
        if (!(a.col == b.col && a.row == b.row))
        {
            Tests.complain(name);
        }
    }


    static public function equalInt(name:String, a:Int, b:Int):Void
    {
        if (!(a == b))
        {
            Tests.complain(name);
        }
    }


    static public function equalHexArray(name:String, a:Array<Hex>, b:Array<Hex>):Void
    {
        Tests.equalInt(name, a.length, b.length);
        for (i in 0...a.length)
        {
            Tests.equalHex(name, a[i], b[i]);
        }
    }


    static public function testHexArithmetic():Void
    {
        Tests.equalHex("hex_add", new Hex(4, -10, 6), HexTools.add(new Hex(1, -3, 2), new Hex(3, -7, 4)));
        Tests.equalHex("hex_subtract", new Hex(-2, 4, -2), HexTools.subtract(new Hex(1, -3, 2), new Hex(3, -7, 4)));
    }


    static public function testHexDirection():Void
    {
        Tests.equalHex("hex_direction", new Hex(0, -1, 1), HexTools.direction(2));
    }


    static public function testHexNeighbor():Void
    {
        Tests.equalHex("hex_neighbor", new Hex(1, -3, 2), HexTools.neighbor(new Hex(1, -2, 1), 2));
    }


    static public function testHexDiagonal():Void
    {
        Tests.equalHex("hex_diagonal", new Hex(-1, -1, 2), HexTools.diagonalNeighbor(new Hex(1, -2, 1), 3));
    }


    static public function testHexDistance():Void
    {
        Tests.equalInt("hex_distance", 7, HexTools.distance(new Hex(3, -7, 4), new Hex(0, 0, 0)));
    }


    static public function testHexRound():Void
    {
        var a:Hex = new Hex(0, 0, 0);
        var b:Hex = new Hex(1, -1, 0);
        var c:Hex = new Hex(0, -1, 1);
        Tests.equalHex("hex_round 1", new Hex(5, -10, 5), FractionalHex.hexRound(FractionalHex.hexLerp(new Hex(0, 0, 0), new Hex(10, -20, 10), 0.5)));
        Tests.equalHex("hex_round 2", a, FractionalHex.hexRound(FractionalHex.hexLerp(a, b, 0.499)));
        Tests.equalHex("hex_round 3", b, FractionalHex.hexRound(FractionalHex.hexLerp(a, b, 0.501)));
        Tests.equalHex("hex_round 4", a, FractionalHex.hexRound(new FractionalHex(a.q * 0.4 + b.q * 0.3 + c.q * 0.3, a.r * 0.4 + b.r * 0.3 + c.r * 0.3, a.s * 0.4 + b.s * 0.3 + c.s * 0.3)));
        Tests.equalHex("hex_round 5", c, FractionalHex.hexRound(new FractionalHex(a.q * 0.3 + b.q * 0.3 + c.q * 0.4, a.r * 0.3 + b.r * 0.3 + c.r * 0.4, a.s * 0.3 + b.s * 0.3 + c.s * 0.4)));
    }


    static public function testHexLinedraw():Void
    {
        Tests.equalHexArray("hex_linedraw", [new Hex(0, 0, 0), new Hex(0, -1, 1), new Hex(0, -2, 2), new Hex(1, -3, 2), new Hex(1, -4, 3), new Hex(1, -5, 4)], FractionalHex.hexLinedraw(new Hex(0, 0, 0), new Hex(1, -5, 4)));
    }


    static public function testLayout():Void
    {
        var h:Hex = new Hex(3, 4, -7);
        var flat:Layout = new Layout(Layout.flat, new Point(10, 15), new Point(35, 71));
        Tests.equalHex("layout", h, FractionalHex.hexRound(Layout.pixelToHex(flat, Layout.hexToPixel(flat, h))));
        var pointy:Layout = new Layout(Layout.pointy, new Point(10, 15), new Point(35, 71));
        Tests.equalHex("layout", h, FractionalHex.hexRound(Layout.pixelToHex(pointy, Layout.hexToPixel(pointy, h))));
    }


    static public function testConversionRoundtrip():Void
    {
        var a:Hex = new Hex(3, 4, -7);
        var b:OffsetCoord = new OffsetCoord(1, -3);
        Tests.equalHex("conversion_roundtrip even-q", a, OffsetCoord.qoffsetToCube(OffsetCoord.EVEN, OffsetCoord.qoffsetFromCube(OffsetCoord.EVEN, a)));
        Tests.equalOffsetcoord("conversion_roundtrip even-q", b, OffsetCoord.qoffsetFromCube(OffsetCoord.EVEN, OffsetCoord.qoffsetToCube(OffsetCoord.EVEN, b)));
        Tests.equalHex("conversion_roundtrip odd-q", a, OffsetCoord.qoffsetToCube(OffsetCoord.ODD, OffsetCoord.qoffsetFromCube(OffsetCoord.ODD, a)));
        Tests.equalOffsetcoord("conversion_roundtrip odd-q", b, OffsetCoord.qoffsetFromCube(OffsetCoord.ODD, OffsetCoord.qoffsetToCube(OffsetCoord.ODD, b)));
        Tests.equalHex("conversion_roundtrip even-r", a, OffsetCoord.roffsetToCube(OffsetCoord.EVEN, OffsetCoord.roffsetFromCube(OffsetCoord.EVEN, a)));
        Tests.equalOffsetcoord("conversion_roundtrip even-r", b, OffsetCoord.roffsetFromCube(OffsetCoord.EVEN, OffsetCoord.roffsetToCube(OffsetCoord.EVEN, b)));
        Tests.equalHex("conversion_roundtrip odd-r", a, OffsetCoord.roffsetToCube(OffsetCoord.ODD, OffsetCoord.roffsetFromCube(OffsetCoord.ODD, a)));
        Tests.equalOffsetcoord("conversion_roundtrip odd-r", b, OffsetCoord.roffsetFromCube(OffsetCoord.ODD, OffsetCoord.roffsetToCube(OffsetCoord.ODD, b)));
    }


    static public function testOffsetFromCube():Void
    {
        Tests.equalOffsetcoord("offset_from_cube even-q", new OffsetCoord(1, 3), OffsetCoord.qoffsetFromCube(OffsetCoord.EVEN, new Hex(1, 2, -3)));
        Tests.equalOffsetcoord("offset_from_cube odd-q", new OffsetCoord(1, 2), OffsetCoord.qoffsetFromCube(OffsetCoord.ODD, new Hex(1, 2, -3)));
    }


    static public function testOffsetToCube():Void
    {
        Tests.equalHex("offset_to_cube even-", new Hex(1, 2, -3), OffsetCoord.qoffsetToCube(OffsetCoord.EVEN, new OffsetCoord(1, 3)));
        Tests.equalHex("offset_to_cube odd-q", new Hex(1, 2, -3), OffsetCoord.qoffsetToCube(OffsetCoord.ODD, new OffsetCoord(1, 2)));
    }


    static public function testAll():Void
    {
        Tests.testHexArithmetic();
        Tests.testHexDirection();
        Tests.testHexNeighbor();
        Tests.testHexDiagonal();
        Tests.testHexDistance();
        Tests.testHexRound();
        Tests.testHexLinedraw();
        Tests.testLayout();
        Tests.testConversionRoundtrip();
        Tests.testOffsetFromCube();
        Tests.testOffsetToCube();
    }

    static public function complain(name:String):Void
    {
        trace("FAIL ", name);
    }
}

