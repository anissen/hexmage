
package core;

typedef PlayerOptions = { id :Int, name :String, ?take_turn :Game->Array<core.Actions.Action> };
typedef Players = Array<Player>;

@:forward
abstract Player(PlayerOptions) from PlayerOptions to PlayerOptions {
    inline public function new(p :PlayerOptions) {
        this = p;
    }

    inline public function clone() {
        return { id: this.id, name: this.name, take_turn: this.take_turn };
    }
    
    @:op(A == B)
    inline static public function equals(lhs :Player, rhs :Player) :Bool {
        return (lhs == null && rhs == null) || (lhs != null && rhs != null && lhs.id == rhs.id);
    }

    @:toString
    inline public function toString() :String {
        return '[${this.name}, id: ${this.id}]';
    }
}
