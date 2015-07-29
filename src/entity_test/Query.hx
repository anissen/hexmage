package ;

import Tag;

using Lambda;

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
