using Lambda;
//using QueryTools;

/*
class NEW1_037:
    events = [
        OWN_TURN_END.on(Buff(RANDOM_OTHER_FRIENDLY_MINION, "NEW1_037e"))
    ]
*/

//typedef Buff = {  }

enum Action {
    EndTurn;
    Effect(tag :Tag, value :Int);
}

enum Event {
    TurnEnded;
}

class Game {
    var event_listeners :Map<Event, Void->Action>;
    
    public function new() {
        event_listeners = new Map();
    }
    
    public function do_action(action :Action) {
        switch (action) {
            case EndTurn: emit_event(TurnEnded);
            case _:
        }
    }
    
    public function on_event(event :Event, func :Void->Action) {
        event_listeners[event] = func;
    }
    
    public function emit_event(event :Event) {
        if (event_listeners.exists(event)) {
            var func = event_listeners[event];
            func();
        }
    }
}

enum Tag {
    Health;
    Attack;
    CanAttack;
    Healing;
    PosX;
    PosY;
    PlayerId;
}

typedef TagMapType = Map<Tag, Int>;
    
//@:forward
abstract TagMap(TagMapType) from TagMapType to TagMapType {
    public inline function new(tags :TagMapType) {
        this = tags;
    }
    
    @:arrayAccess
    public inline function get(tag :Tag) {
        return this.get(tag);
    }
    
    @:arrayAccess
    public inline function set(tag :Tag, value :Int) :Int {
        this.set(tag, value);
        return value;
    }
    
    public function has(tag :Tag) {
        return this.exists(tag);
    }
    
    public function enabled(tag :Tag) {
        return this[tag] > 0;
    }
    
    public function enable(tag :Tag) {
        this[tag] = 1;
    }
    
    public function disable(tag :Tag) {
        this[tag] = 0;
    }
    
    public function print() {
        for (tag in this.keys()) trace('$tag: ${this[tag]}');
    }
}

class Entity {
    public var name (get, null) :String;
    public var tags :TagMap;
    
    public function new(name :String, tags :TagMap) {
        this.name = name;
        this.tags = tags;
    }

    function get_name() {
        return name;
    }
}
        
class Query {
    static public function has(entities :Array<Entity>, tag :Tag) :Array<Entity> {
        return entities.filter(Has(tag));
    }
    
    static public function friendly(entities :Array<Entity>, playerId :Int) :Array<Entity> {
        return entities.filter(function (entity) {
            return entity.tags[PlayerId] == playerId;
        });
    }
    
    static public function neighbors(entities :Array<Entity>, x :Int, y :Int) :Array<Entity> {
        return entities.filter(function (entity) {
            return (Math.abs(entity.tags[PosX] - x) +  Math.abs(entity.tags[PosY] - y)) == 1;
        });
    }
    
    static public function Has(tag :Tag) :Entity->Bool {
        return function(entity) {
            return entity.tags.has(tag);
        };
    }
}

class Test {
    static function main() {
        var game = new Game();
        var minionFunc = function() {
            trace('minionFunc triggered!');
            return EndTurn;
        };
        game.on_event(TurnEnded, minionFunc);
        game.do_action(EndTurn);
        
        var unicorn = new Entity('Unicorn', [
            Health => 6,
            Attack => 1,
            Healing => 1,
            CanAttack => 1,
            PosX => 2,
            PosY => 3,
            PlayerId => 1
        ]);
        
        unicorn.tags.print();
        
        clear();

        damage(unicorn, 2);
        
        trace('--> Can attack: ${unicorn.tags[CanAttack]}');
        
        //disarm(unicorn);
        trace('--> Can attack: ${unicorn.tags[CanAttack]}');        
        
        var troll = new Entity('Troll', [
            Health => 2,
            Attack => 2
        ]);
        
        var entities = [unicorn, troll];
        
        clear();
        
        trace('Entities with health');
        var has_health = Query.has(entities, Health);
        for (entity in has_health) trace('· ' + entity.name);
        
        clear();
    
        trace('Entities that can attack and have > 2 health');
        var result = entities.filter(function(entity) {
            return entity.tags.enabled(CanAttack) && entity.tags[Health] > 2;
        });
        for (entity in result) trace('· ' + entity.name);
        
        trace('Nearby friendly entities');
        // Should be entities.neighbors(2, 2).friendly(1)
        var neighbors = Query.neighbors(entities, 2, 2);
        var friendly = Query.friendly(neighbors, 1);
        for (entity in friendly) trace('· ' + entity.name);
        
        test_heal_effect();
    }
    
    static function test_heal_effect() {
        clear();
        trace('test_heal_effect:');
        
        var unicorn = new Entity('Unicorn', [
            Healing => 1,
            PosX => 2,
            PosY => 3,
            PlayerId => 1
        ]);
        
        var bunny = new Entity('Bunny', [
            Health => 1,
            PosX => 2,
            PosY => 4,
            PlayerId => 1
        ]);
        
        trace('Bunny health: ${bunny.tags[Health]}');
        trace('Unicorn healing nearby friends:');
        var entities = [unicorn, bunny];
        var neighbors = Query.neighbors(entities, unicorn.tags[PosX], unicorn.tags[PosY]);
        var friendly = Query.friendly(neighbors, unicorn.tags[PlayerId]);
        for (entity in friendly) {
            trace('· Healing ' + entity.name);
            entity.tags[Health] += 1;
        }
        trace('Bunny health: ${bunny.tags[Health]}');
    }
    
    static function damage(entity :Entity, amount :Int) {
        trace('${entity.name} takes $amount damage');
        entity.tags[Health] = entity.tags[Health] - amount;
    }
    
    static function disarm(entity :Entity) {
        trace('${entity.name} is disarmed');
        entity.tags.disable(CanAttack);
    }
    
    static function clear() {
        trace('\n-----------------------\n');
    }
    
}
