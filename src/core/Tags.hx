
package core;

import core.Tag;

typedef TagsType = Map<Tag, Int>;

interface HasTags {
    var tags :Tags;
}

abstract Tags(TagsType) from TagsType to TagsType {
    public inline function new(tags :TagsType) {
        this = tags;
    }
    
    @:arrayAccess
    public inline function get(tag :Tag) :Int {
        return this.get(tag);
    }
    
    @:arrayAccess
    public inline function set(tag :Tag, value :Int) :Int {
        this.set(tag, value);
        return value;
    }
    
    public inline function has(tag :Tag) :Bool {
        return this.exists(tag);
    }
    
    public inline function enabled(tag :Tag) :Bool {
        return this[tag] > 0;
    }
    
    public inline function enable(tag :Tag) :Void {
        this[tag] = 1;
    }
    
    public inline function disable(tag :Tag) :Void {
        this[tag] = 0;
    }

    public inline function keys() {
        return this.keys();
    }

    public inline function clone() {
        return [ for (key in this.keys()) key => this[key] ];
    }
    
    @:to
    public inline function toString() {
        return [ for (tag in this.keys()) '$tag: ${this[tag]}' ].join('|'); 
    }
}
