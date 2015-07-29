package ;

import Query;
import Tag;
import Events;

using Lambda;
using Query;

/*
class NEW1_037:
    events = [
        OWN_TURN_END.on(Buff(RANDOM_OTHER_FRIENDLY_MINION, "NEW1_037e"))
    ]
*/

class Test {
    static function main() {
        // main_test();
        // clear();
        // test_heal_effect();

        engine_test();
    }

    static function engine_test() {
        var dummyEntity = new Entity('Dummy', [ Health => 1 ]);
        trace(dummyEntity);

        var engine = new Engine();
        engine.handle_actions(function(action, emit_event) {
            switch (action) {
                case EndTurn: 
                    emit_event(TurnEnded(0));
                    trace('Doing some logic between TurnEnded and TurnStarted');
                    emit_event(TurnStarted(1));
                case Effect(entity, tags):
                    trace('Action: Effect');
                    for (tag in tags.keys()) {
                        trace('Setting $tag to ${tags[tag]}');
                        entity.tags[tag] = tags[tag];
                    }
                    emit_event(EffectTriggered(entity, tags));
            }
        });
        engine.handle_events(function(event, do_action) {
            switch (event) {
                case TurnEnded(playerId): trace('Event: TurnEnded for player $playerId');
                case TurnStarted(playerId):
                    trace('Event: TurnStarted for player $playerId');
                    trace('Fake an effect: Swap health/attack on entity...');
                    do_action(Effect(dummyEntity, [ Health => dummyEntity.tags[Attack], Attack => dummyEntity.tags[Health] ]));
                case EffectTriggered(entity, tags): trace('Event: EffectTriggered');
                case _: [];
            }
        });

        engine.do_action(EndTurn);

        trace(dummyEntity);
    }

    static function main_test() {
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
            return [ for (entity in nearby_friends) Effect(entity, [ Health => entity.tags[Health] + 1 ]) ];
        };
        engine.handle_events(function(event, _) {
           switch (event) {
               case TurnEnded(_): unicornFunc();
               case EffectTriggered(entity, tags): trace('EffectTriggered func!'); [];
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
