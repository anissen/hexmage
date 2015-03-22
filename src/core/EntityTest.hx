
using Lambda;

enum Tag {
    Health;
    Attack;
    CanAttack;
    Healing;
}

class Entity {
    var name :String;
    var tags :Map<Tag,Int>;
    
    public function new(name :String) {
        this.name = name;
        tags = new Map<Tag,Int>();
    }
    
    public function setTag(tag :Tag, tagValue :Int) :Void {
        tags.set(tag, tagValue);
    }
    
    public function unsetTag(tag :Tag) :Void {
        tags.remove(tag);
    }
    
    public function getTag(tag :Tag) :Null<Int> {
        return tags.get(tag);
    }
    
    public function getBoolTag(tag :Tag) :Bool {
        return (tags.get(tag) > 0);
    }
    
    public function listTags() {
        for (key in tags.keys()) {
            trace(key + ' has value ' + tags[key]);
        }
    }

    public function getName() {
        return name;
    }
}

class Test {
    static function main() {
        var unicorn = new Entity('Unicorn');
        unicorn.setTag(Health, 6);
        unicorn.setTag(Attack, 1);
        unicorn.setTag(Healing, 1);
        unicorn.setTag(CanAttack, 1);
        damage(unicorn, 2);
        unicorn.listTags();
        trace('--> Can attack: ${unicorn.getBoolTag(CanAttack)}');
        
        
        var troll = new Entity('Troll');
        troll.setTag(Health, 2);
        troll.setTag(Attack, 2);
        
        var entities = [unicorn, troll];

        var has_health :Array<Entity> = entities.filter(function(entity) {
            return (entity.getTag(Health) != null);
        });        
        trace('Entities with health');
        for (entity in has_health) {
            trace('· ' + entity.getName());     
        }
    
        var has_healing :Array<Entity> = entities.filter(function(entity) {
            return (entity.getTag(Healing) != null);
        });
        trace('Entities with healing');
        for (entity in has_healing) {
            trace('· ' + entity.getName());     
        }
    }
    
    static function damage(entity :Entity, amount :Int) {
        entity.setTag(Health, entity.getTag(Health) - amount);
    }
}
