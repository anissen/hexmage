
package core;

import core.Tag;
import core.Tags.HasTags;

using Lambda;

class MinionQuery {
    var minion :Minion;
    var result :Array<Minion>;

    public function new(_minion :Minion, _result :Array<Minion>) {
        minion = _minion;
        result = _result;
    }

    function create(_result :Array<Minion>) :MinionQuery {
        return new MinionQuery(minion, _result);
    }

    public function friendly() :MinionQuery {
        return create(Query.friendly(result, minion.playerId));
    }

    public function nearby() :MinionQuery {
        return create(Query.nearby(result, minion.tags[PosX], minion.tags[PosY]));
    }

    public function random() :MinionQuery {
        return create([result[Math.floor(result.length * Math.random())]]);
    }

    public function create_effects(func :Minion->core.enums.Commands.PartialEffectData) :core.enums.Commands {
        return [ 
            for (entity in result) {
                var effectData :core.enums.Commands.EffectData = cast func(entity);
                effectData.minionId = entity.id;
                Effect(effectData); 
            }
        ];
    }

    public function buff(tag :Tag, value :Int = 1) :core.enums.Commands {
        return create_effects(create_buff_effect(tag, value));
    }

    function create_buff_effect(tag :Tag, value :Int = 1) {
        return function(minion :Minion) { 
            return {
                description: (value > 0 ? '+' : '') + value + ' ' + tag.getName(), 
                tags: [ tag => minion.tags[tag] + value ]
            }
        };
    }
}

class Query {
    static public function has<T:HasTags>(entities :Array<T>, tag :Tag) :Array<T> {
        return entities.filter(Has(tag));
    }
    
    static public function friendly<T:HasTags>(entities :Array<T>, playerId :Int) :Array<T> {
        return entities.filter(function (entity) {
            return entity.tags[PlayerId] == playerId;
        });
    }
    
    static public function nearby<T:HasTags>(entities :Array<T>, x :Int, y :Int) :Array<T> {
        return entities.filter(function (entity) {
            if (!entity.tags.has(PosX) || !entity.tags.has(PosY)) return false;
            // TODO: Should use Board.Distance(pos1, pos2)
            return (Math.abs(entity.tags[PosX] - x) == 1) || (Math.abs(entity.tags[PosY] - y) == 1);
        });
    }
    
    static public function Has<T:HasTags>(tag :Tag) :T->Bool {
        return function(entity) {
            return entity.tags.has(tag);
        };
    }
}
