
package core;

import core.Tag;
import core.Tags.HasTags;

using Lambda;

// typedef EntityTypes = Array<T: HasTags>;
//typedef EntityType = HasTags;


// TODO: Create query object from game
class MinionQuery {
    var game :Game;
    var minion :Minion;
    var result :Array<Minion>;

    public function new(game :Game, minion :Minion, result :Array<Minion>) {
        this.game = game;
        this.minion = minion;
        this.result = result;
    }

    function create(res :Array<Minion>) {
        return new MinionQuery(game, minion, res);
    }

    public function friendly() :MinionQuery {
        return create(Query.friendly(game.minions(), minion.playerId));

    }

    // public function nearby() :MinionQuery {
    //     // return Query.nearby(game.minions(), minion.pos);
    //     return create(game.minions().filter(function (entity) {
    //         //if (!entity.tags.has(PosX) || !entity.tags.has(PosY)) return false;
    //         return true;
    //     });
    // }

    public function create_effects(func :Minion->core.enums.Commands.PartialEffectData) :core.enums.Commands {
        return [ 
            for (entity in result) {
                var effectData :core.enums.Commands.EffectData = cast func(entity);
                effectData.minionId = entity.id;
                Effect(effectData); 
            }
        ];
    }

    public function buff(tag :Tag, value :Int = 1) {
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

    // public function minions() {
    //     return result;
    // }
}

// BETTER IDEA: Make game and board available from static contexts!!!

class Query {
    static public function has<T:HasTags>(entities :Array<T>, tag :Tag) :Array<T> {
        return entities.filter(Has(tag));
    }
    
    static public function friendly<T:HasTags>(entities :Array<T>, playerId :Int) :Array<T> {
        return entities.filter(function (entity) {
            return entity.tags[PlayerId] == playerId;
        });
    }
    
    // static public function nearby<T:HasTags>(entities :Array<T>, pos :String) :Array<T> {
    //     return entities.filter(function (entity) {
    //         //if (!entity.tags.has(PosX) || !entity.tags.has(PosY)) return false;
    //         return (Math.abs(entity.tags[PosX] - x) +  Math.abs(entity.tags[PosY] - y)) == 1;
    //     });
    // }
    
    static public function Has<T:HasTags>(tag :Tag) :T->Bool {
        return function(entity) {
            return entity.tags.has(tag);
        };
    }
}
