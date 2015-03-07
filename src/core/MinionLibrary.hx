
package core;

import core.Minion;

class MinionLibrary {
    static var minions = new Map<String, Minion>();

    static public function add(minion :Minion) {
        if (minion.name.length == 0)
            throw 'Cannot add minion with empty name';
        if (minions.exists(minion.name))
            throw 'Minion with ID: ${minion.name} already exists!';
        minions.set(minion.name, minion);
    }

    static public function create(id :String, player :Player) {
        var minion = minions.get(id);
        if (minion == null)
            throw 'Minion with ID: "$id" does not exist!';
        return minion.createNew(player);
    }
}
