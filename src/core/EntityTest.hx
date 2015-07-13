
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
    
    public function set_tag(tag :Tag, tag_value :Int) :Void {
        tags.set(tag, tag_value);
    }
    
    public function unset_tag(tag :Tag) :Void {
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

    static public function Has(tag :Tag) {
        return function(entity) {
            return (entity.getTag(tag) != null);
        };
    }
}

class Test {
    static function main() {
        var unicorn = new Entity('Unicorn');
        unicorn.set_tag(Health, 6);
        unicorn.set_tag(Attack, 1);
        unicorn.set_tag(Healing, 1);
        unicorn.set_tag(CanAttack, 1);
        damage(unicorn, 2);
        unicorn.listTags();
        trace('--> Can attack: ${unicorn.getBoolTag(CanAttack)}');
        
        var troll = new Entity('Troll');
        troll.set_tag(Health, 2);
        troll.set_tag(Attack, 2);
        
        var entities = [unicorn, troll];

        var has_health :Array<Entity> = entities.filter(Entity.Has(Health));        
        trace('Entities with health');
        for (entity in has_health) {
            trace('· ' + entity.getName());     
        }
    
        var has_healing = entities.filter(Entity.Has(Healing));
        trace('Entities with healing');
        for (entity in has_healing) {
            trace('· ' + entity.getName());     
        }
    }
    
    static function damage(entity :Entity, amount :Int) {
        entity.set_tag(Health, entity.getTag(Health) - amount);
    }
}
