
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

    public function handle_rules_for_minion(m :Minion /* + event type */) {
        for (rule in m.rules) {
            var applicable = switch (rule.trigger) {
                case OwnTurnStart: true;
                default: false;
            };
            if (!applicable) continue;
            switch (rule.effect) {
                case Scripted(f): trace('Doing scripted action'); f(this);
                default: throw 'Unhandled rule effect!';
            }
        }
    }

    function clone_minion(m :Minion) :Minion {
        return new Minion({ id: m.id, player: m.player, name: m.name, attack: m.attack, life: m.life, rules: m.rules });
    }
    
    public function clone_board() :Board {
        function create_tile(x, y) {
            var tile = get_tile({ x: x, y: y });
            return { minion: (tile.minion != null ? clone_minion(tile.minion) : null) };
        }
        return new Board(boardSize.x, boardSize.y, create_tile);
    }

    public function get_tile(pos :Point) {
        return board[pos.y][pos.x];
    }

    public function get_board_size() :Point {
        return boardSize;
    }

    public function do_action(action :Action) {
        switch (action) {
            case Move(m):
                var minion = get_minion(m.minionId);
                // trace('MOVE: $minion moves to ${m.pos}');
                move(m);
            case Attack(a):
                var minion = get_minion(a.minionId);
                var victim = get_minion(a.victimId);
                // trace('ATTACK: $minion attacks $victim');
                attack(a);
                // trace('... $victim now has ${victim.life} life');
            case _: trace('Action $action is unhandled!');
        }
    }
    
    function move(moveAction :MoveAction) {
        var minion = get_minion(moveAction.minionId);
        var currentPos = get_minion_pos(minion);
        get_tile(currentPos).minion = null;
        get_tile(moveAction.pos).minion = minion;
    }
    
    function attack(attackAction :AttackAction) {
        var minion = get_minion(attackAction.minionId);
        var victim = get_minion(attackAction.victimId);
        victim.life -= minion.attack;
        minion.life -= victim.attack;
        if (victim.life <= 0) {
            var pos = get_minion_pos(victim);
            get_tile(pos).minion = null;
        }
        if (minion.life <= 0) {
            var pos = get_minion_pos(minion);
            get_tile(pos).minion = null;
        }
    }

    public function print_board() {
        trace("Board:");
        for (row in board) {
            var s = "";
            for (tile in row) {
                s += (tile.minion != null ? '[${tile.minion.player.id}]' : "[ ]");
            }     
            trace(s);
        }
    }
        
    public function get_minions_for_player(player :Player) :Array<Minion> {
        var minions = [];
        for (row in board) {
            for (tile in row) {
                if (tile.minion != null && tile.minion.player.id == player.id) minions.push(tile.minion);
            }
        }
        return minions;
    }
        
    public function get_minion(id :Int) :Minion {
        for (row in board) {
            for (tile in row) {
                if (tile.minion != null && tile.minion.id == id)
                    return tile.minion;
            }
        }
        return null;
    }

    public function get_minion_pos(minion :Minion) :Point {
        for (y in 0 ... board.length) {
            var row = board[y];
            for (x in 0 ... row.length) {
                var tile = row[x];
                if (tile.minion != null && tile.minion == minion) return { x: x, y: y };
            }
        }
        throw 'Minion not found on board!';
    }
}
