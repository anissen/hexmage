
package core;

import core.Tag;
import core.Tags.HasTags;

using Lambda;

// typedef EntityTypes = Array<T: HasTags>;
//typedef EntityType = HasTags;

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
            return (Math.abs(entity.tags[PosX] - x) +  Math.abs(entity.tags[PosY] - y)) == 1;
        });
    }
    
    static public function Has<T:HasTags>(tag :Tag) :T->Bool {
        return function(entity) {
            return entity.tags.has(tag);
        };
    }
}
