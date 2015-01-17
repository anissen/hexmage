

// TODO:
// [x] Two players, each with a unit
// [x] Make unit 1 move at random
// [x] Make unit 1 attack unit 2
// [x] Make unit 1 kill unit 2
// [x] Choose the best action for unit 1
// [ ] Make rule for unit 1 (+ 1 damage)

typedef Point = { x :Int, y :Int };
//typedef Rule = { effect :Void->Void };
typedef Player = { id :Int, name :String };

typedef MinionOptions = { player: Player, id :Int, name :String, attack :Int, life :Int, rules :Rules };

@:forward
abstract Minion(MinionOptions) from MinionOptions to MinionOptions {
    inline public function new(m :MinionOptions) {
        this = m;
    }
    
    @:op(A == B)
    inline static public function equals(lhs :Minion, rhs :Minion) :Bool {
        return (lhs == null && rhs == null) || (lhs != null && rhs != null && lhs.id == rhs.id);
    }

    @:toString
    inline public function toString() :String {
        return '[${this.name} (${this.attack}/${this.life}) owner: ${this.player.name}]';
    }
}



/*
class Minion {
    var player: Player;
    var id :Int;
    var name :String;
    var attack :Int;
    var life :Int;
    
    public function new(_options :MinionOptions) {
        player = _options.player;
        id = _options.id;
        name = _options.name;
        attack = _options.life;
    }
}
*/

typedef Tile = { ?minion :Minion };
typedef Board = Array<Array<Tile>>;

enum RuleTrigger {
    OwnTurnStart;
}
enum RuleEffect {
    Scripted(f :Board->Void);
}
typedef Rule = { trigger :RuleTrigger, effect :RuleEffect };
typedef Rules = Array<Rule>;

typedef MoveAction = { minionId :Int, pos :Point };
typedef AttackAction = { minionId :Int, victimId :Int };

enum Action {
    Move(p :MoveAction);
    Attack(a :AttackAction);
}

class Game {
    var tiles = { x: 1, y: 3 };
    static var player1 = { id: 0, name: 'Princess' };
    static var player2 = { id: 1, name: 'Troll' };
    var board :Board;
    var rules :Rules;
    
    public function new() {
        board = [ for (y in 0 ... tiles.y) [for (x in 0 ... tiles.x) create_tile(x, y)]];
        rules = new Rules();
    }

    function create_tile(x :Int, y :Int) :Tile {
        if (x == 0 && y == 0) return { minion: new Minion({ player: player2, id: 0, name: 'Goblin 1', attack: 2, life: 2, rules: new Rules() }) };
        //if (x == 1 && y == 0) return { minion: new Minion({ player: player2, id: 1, name: 'Goblin 2', attack: 2, life: 2 }) };
        //if (x == 2 && y == 0) return { minion: new Minion({ player: player2, id: 2, name: 'Goblin 3', attack: 2, life: 2 }) };
        function plus_one_attack_per_turn(b :Board) :Void {
            var m = get_minion(3);
            m.attack += 1;
        }

        if (x == 0 && y == 2) return { minion: new Minion({ player: player1, id: 3, name: 'Unicorn', attack: -2, life: 3, rules: [{ trigger: OwnTurnStart, effect: Scripted(plus_one_attack_per_turn) }] }) };
        return {};
    }
    
    public function test() {
        print_board();
        
        for (x in 0 ... 5) {
            trace('');
            trace('========== TURN #${x+1} ==========');
            for (minion in get_minions_for_player(player1.id)) {
                handle_rules_for_minion(minion);
            }

            var actions = get_best_actions_for_player(player1);
            if (actions.length == 0) {
                trace('No available action!');
                continue;
            } else if (actions.length > 1) {
                trace('${actions.length} best actions to choose from!: ');
                //for (a in actions) trace('action: $a');
            }
            var randomBestAction = actions[Math.floor(actions.length * Math.random())];
            // trace('chosen action: $randomBestAction');
            do_action(randomBestAction);
            print_board();
            print_score_board();
        }
    }

    function handle_rules_for_minion(m :Minion /* + event type */) {
        for (rule in m.rules) {
            var applicable = switch (rule.trigger) {
                case OwnTurnStart: true;
                default: false;
            };
            if (!applicable) continue;
            switch (rule.effect) {
                case Scripted(f): trace('Doing scripted action'); f(board);
                default: throw 'Unhandled rule effect!';
            }
        }
    }

    function clone_minion(m :Minion) :Minion {
        return new Minion({ id: m.id, player: m.player, name: m.name, attack: m.attack, life: m.life, rules: m.rules });
    }
    
    function clone_board(b :Board) :Board {
        return [ 
            for (row in b) [
                for (tile in row) { minion: (tile.minion != null ? clone_minion(tile.minion) : null) }
            ] 
        ];

    }

    function get_best_actions_for_player(player :Player) :Array<Action> {
        var bestScore = -1000;
        var bestActions = [];
        var oldBoard = clone_board(board);
        var actions = [];
        for (minion in get_minions_for_player(player.id)) {
            actions = actions.concat(get_moves_for_minion(minion));
            actions = actions.concat(get_attacks_for_minion(minion));    
        }
        for (action in actions) {
            board = clone_board(oldBoard);
            // print_board();
            simulate_action(action);
            var score = score_board(board, player);
            // trace('score for doing $action: $score');
            if (score == bestScore) { 
                bestActions.push(action);
            } else if (score > bestScore) {
                bestActions = [action];
                bestScore = score;
            }
        }
        board = oldBoard;
        return bestActions;
    }

    function get_tile(pos :Point) {
        return board[pos.y][pos.x];
    }

    function do_action(action :Action) {
        switch (action) {
            case Move(m):
                var minion = get_minion(m.minionId);
                trace('MOVE: $minion moves to ${m.pos}');
                move(m);
            case Attack(a):
                var minion = get_minion(a.minionId);
                var victim = get_minion(a.victimId);
                trace('ATTACK: $minion attacks $victim');
                attack(a);
                trace('... $victim now has ${victim.life} life');
        }
    }

    function simulate_action(action :Action) {
        switch (action) {
            case Move(m): move(m);
            case Attack(a): attack(a);
        }
    }
    
    function print_score_board() {
        var p = player1;
        trace('=> Score: ${score_board(board, p)} to ${p.name} (player ${p.id})');
    }
    
    function score_board(b :Board, player :Player) {
        // score the players own stuff only
        function get_score_for_player(p) {
            var score = 0;
            for (row in b) {
                for (tile in row) {
                    if (tile.minion == null) continue;
                    if (tile.minion.player != p) continue;
                    score += tile.minion.attack + tile.minion.life;
                }
            }
            return score;
        }
         
        var score = get_score_for_player(player);
        var otherPlayers = [player1, player2];
        otherPlayers.remove(player);
        for (p in otherPlayers) {
            score -= get_score_for_player(p);
        }
        return score;
    }
    
    function pick_random_move(arr :Array<MoveAction>) :MoveAction {
        return arr[Math.floor(arr.length * Math.random())];
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

    function print_board() {
        trace("Board:");
        for (row in board) {
            var s = "";
            for (tile in row) {
                s += (tile.minion != null ? '[${tile.minion.player.id}]' : "[ ]");
            }     
            trace(s);
        }
    }
        
    function get_minions_for_player(playerId :Int) :Array<Minion> {
        var minions = [];
        for (row in board) {
            for (tile in row) {
                if (tile.minion != null && tile.minion.player.id == playerId) minions.push(tile.minion);
            }
        }
        return minions;
    }
        
    function get_minion(id :Int) :Minion {
        for (row in board) {
            for (tile in row) {
                if (tile.minion != null && tile.minion.id == id)
                    return tile.minion;
            }
        }
        return null;
    }

    function get_minion_pos(minion :Minion) :Point {
        for (y in 0 ... board.length) {
            var row = board[y];
            for (x in 0 ... row.length) {
                var tile = row[x];
                if (tile.minion != null && tile.minion == minion) return { x: x, y: y };
            }
        }
        throw 'Minion not found on board!';
    }

    function get_moves_for_minion(minion :Minion) :Array<Action> {
        var pos = get_minion_pos(minion);
        var x = pos.x;
        var y = pos.y;
        var moves = [];
        for (newx in x - 1 ... x + 2) {
            for (newy in y - 1 ... y + 2) {
                if (newx == x && newy == y) continue;
                if (newx < 0 || newx >= tiles.x) continue;
                if (newy < 0 || newy >= tiles.y) continue;
                if (get_tile({ x: newx, y: newy }).minion != null) continue;
                moves.push(Move({ minionId: minion.id, pos: { x: newx, y: newy } }));
            }     
        }
        return moves;
    }

    function get_attacks_for_minion(minion :Minion) :Array<Action> {
        var pos = get_minion_pos(minion);
        var x = pos.x;
        var y = pos.y;
        var attacks = [];
        function add_attack(newx, newy) {
            if (newx < 0 || newx >= tiles.x) return;
            if (newy < 0 || newy >= tiles.y) return;
            var other = get_tile({ x: newx, y: newy }).minion;
            if (other == null || other.player == minion.player) return;
            attacks.push(Attack({ minionId: minion.id, victimId: other.id }));
        }
        add_attack(x, y - 1);
        add_attack(x, y + 1);
        add_attack(x - 1, y);
        add_attack(x + 1, y);
        return attacks;
    }
}

class Test {
    static function main() {
        var game = new Game();
        game.test();
    }
}
