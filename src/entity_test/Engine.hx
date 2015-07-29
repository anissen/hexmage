package ;

import Events;

typedef ActionListenerType = Action->(Event->Void)->Void;
typedef EventListenerType = Event->(Action->Void)->Void;

class Engine {
    var action_listeners :Array<ActionListenerType>;
    var event_listeners :Array<EventListenerType>;
    
    public function new() {
        action_listeners = [];
        event_listeners = [];
    }
    
    public function do_action(action :Action) {
        for (listener in action_listeners) listener(action, emit_event);
    }

    public function handle_actions(func :ActionListenerType) {
        action_listeners.push(func);
    }
            
    public function handle_events(func :EventListenerType) {
        event_listeners.push(func);
    }
    
    public function emit_event(event :Event) {
        var actions = [];
        for (listener in event_listeners) listener(event, do_action);
    }
}
