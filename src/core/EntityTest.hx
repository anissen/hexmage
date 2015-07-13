
using Lambda;

enum Tag {
    Health;
    Attack;
    CanAttack;
    Healing;
}

class Entity {
    var name :String;
    var tags :Map<Tag, Int>;
    
    public function new(name :String, tags :Map<Tag, Int>) {
        this.name = name;
        this.tags = tags; //new Map<Tag,Int>();
    }
    
    public function set_tag(tag :Tag, tag_value :Int) :Void {
        tags.set(tag, tag_value);
    }
    
    public function unset_tag(tag :Tag) :Void {
        tags.remove(tag);
    }
    
    public function get_tag(tag :Tag) :Null<Int> {
        return tags.get(tag);
    }
    
    public function get_bool_tag(tag :Tag) :Bool {
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
            return (entity.get_tag(tag) != null);
        };
    }
}

class Test {
    static function main() {
        var unicorn = new Entity('Unicorn', [
            Health => 6,
            Attack => 1,
            Healing => 1,
            CanAttack => 1
        ]);
        // unicorn.set_tag(Health, 6);
        // unicorn.set_tag(Attack, 1);
        // unicorn.set_tag(Healing, 1);
        // unicorn.set_tag(CanAttack, 1);
        damage(unicorn, 2);
        unicorn.listTags();
        trace('--> Can attack: ${unicorn.get_bool_tag(CanAttack)}');
        
        var troll = new Entity('Troll', [
            Health => 2,
            Attack => 2
        ]);
        // troll.set_tag(Health, 2);
        // troll.set_tag(Attack, 2);
        
        var entities = [unicorn, troll];

        trace('Entities with health');
        var has_health = entities.filter(Entity.Has(Health));        
        for (entity in has_health) trace('· ' + entity.getName());
    
        trace('Entities with healing');
        var has_healing = entities.filter(Entity.Has(Healing));
        for (entity in has_healing) trace('· ' + entity.getName());
    }
    
    static function damage(entity :Entity, amount :Int) {
        entity.set_tag(Health, entity.get_tag(Health) - amount);
    }
}
