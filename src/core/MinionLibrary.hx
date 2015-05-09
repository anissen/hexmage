
package core;

import core.Minion;

class MinionLibrary {
    static var minions = new Map<String, Minion>();

    static public function Add(minion :Minion) {
        if (minion.name.length == 0)
            throw 'Cannot add minion with empty name';
        if (minions.exists(minion.name))
            throw 'Minion with name "${minion.name}"" already exists!';
        minions.set(minion.name, minion);
    }

    public var nextMinionId(default, null) :Int;

    public function new(nextId :Int) {
        nextMinionId = nextId;
    }

    public function create(name :String, player :Player) {
        var minionPrototype = minions.get(name);
        if (minionPrototype == null)
            throw 'Minion with name "$name" does not exist!';

        var minion = minionPrototype.clone();
        minion.id = nextMinionId++;
        minion.playerId = player.id;
        return minion;
    }
}
