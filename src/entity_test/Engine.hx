package ;

import Events;

class MessageBus<T> {
    var listeners :Array<T->Void>;
    
    public function new() {
        listeners = [];
    }
    
    public function emit(action :T) {
        for (listener in listeners) listener(action);
    }

    public function on(func :T->Void) {
        listeners.push(func);
    }
}

class Engine {
    public var actions :MessageBus<Action>;
    public var events :MessageBus<Event>;
    
    public function new() {
        actions = new MessageBus();
        events = new MessageBus();
    }
}
