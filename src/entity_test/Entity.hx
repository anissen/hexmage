package ;

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
