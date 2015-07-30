package ;

class Entity {
    public var name (get, null) :String;
    public var tags :Tags;
    
    public function new(name :String, tags :Tags) {
        this.name = name;
        this.tags = tags;
    }

    function get_name() {
        return name;
    }
}
