package ;

import Tag;

typedef TagMapType = Map<Tag, Int>;

abstract TagMap(TagMapType) from TagMapType to TagMapType {
    public inline function new(tags :TagMapType) {
        this = tags;
    }
    
    @:arrayAccess
    public inline function get(tag :Tag) {
        return this.get(tag);
    }
    
    @:arrayAccess
    public inline function set(tag :Tag, value :Int) :Int {
        this.set(tag, value);
        return value;
    }
    
    public function has(tag :Tag) {
        return this.exists(tag);
    }
    
    public function enabled(tag :Tag) {
        return this[tag] > 0;
    }
    
    public function enable(tag :Tag) {
        this[tag] = 1;
    }
    
    public function disable(tag :Tag) {
        this[tag] = 0;
    }

    public function keys() {
        return this.keys();
    }
    
    @:to
    public function toString() {
        return [ for (tag in this.keys()) '$tag: ${this[tag]}' ].join('|'); 
    }
}
