using Lambda;
using EntityTest2.QueryTools;

/*
class NEW1_037:
    events = [
        OWN_TURN_END.on(Buff(RANDOM_OTHER_FRIENDLY_MINION, "NEW1_037e"))
    ]
*/

enum Action {
    EndTurn;
    Effect(entity :Entity, tag :Tag, value :Int);
}
typedef Actions = Array<Action>;

enum Event {
    TurnEnded;
    EffectTriggered(entity :Entity, tag :Tag, value :Int);
}

class Engine {
    var event_listeners :Array<Event->Actions>;
    
    public function new() {
        event_listeners = [];
    }
    
    public function do_action(action :Action) {
        trace('engine::do_action: $action');
        var actions = switch (action) {
            case EndTurn: emit_event(TurnEnded);
            case Effect(entity, tag, value): entity.tags[tag] = value; emit_event(EffectTriggered(entity, tag, value));
            case _: [];
        };
        for (action in actions) do_action(action);
    }
            
    public function handle_events(func :Event->Actions) {
        event_listeners.push(func);
    }  
    
    public function emit_event(event :Event) :Actions {
        var actions = [];
        for (listener in event_listeners) actions = actions.concat(listener(event));
        return actions;
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
    
    @:to
    public function toString() {
        return [ for (tag in this.keys()) '$tag: ${this[tag]}' ].join('|'); 
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
        
class QueryTools {
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
            if (!entity.tags.has(PosX) || !entity.tags.has(PosY)) return false;
            return (Math.abs(entity.tags[PosX] - x) +  Math.abs(entity.tags[PosY] - y)) == 1;
        });
    }
    
    static public function Has(tag :Tag) :Entity->Bool {
        return function(entity) {
            return entity.tags.has(tag);
        };
    }
}

class EntityTest2 {
    static function main() {
        var unicorn = new Entity('Unicorn', [
            Health => 6,
            Attack => 1,
            Healing => 1,
            CanAttack => 1,
            PosX => 2,
            PosY => 3,
            PlayerId => 1
        ]);
        
        trace(unicorn.tags);
        
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
        var has_health = entities.has(Health);
        for (entity in has_health) trace('· ' + entity.name);
        
        clear();
    
        trace('Entities that can attack and have > 2 health');
        var result = entities.filter(function(entity) {
            return entity.tags.enabled(CanAttack) && entity.tags[Health] > 2;
        });
        for (entity in result) trace('· ' + entity.name);
        
        trace('Nearby friendly entities');
        // Should be entities.neighbors(2, 2).friendly(1)
        var friendly_neighbors = entities.neighbors(2, 2).friendly(1);
        for (entity in friendly_neighbors) trace('· ' + entity.name);
        
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
        
        var engine = new Engine();
        var unicornFunc = function() {
            trace('Unicorn healing nearby friends:');
            var entities = [unicorn, bunny];
            var nearby_friends = entities
                .neighbors(unicorn.tags[PosX], unicorn.tags[PosY])
                .friendly(unicorn.tags[PlayerId]);
            return [ for (entity in nearby_friends) Effect(entity, Health, entity.tags[Health] + 1) ];
        };
        engine.handle_events(function(event) {
           return switch (event) {
               case TurnEnded: unicornFunc();
               case EffectTriggered(entity, tag, value): trace('EffectTriggered func!'); [];
               case _: [];
           }
        });
        engine.do_action(EndTurn);
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
