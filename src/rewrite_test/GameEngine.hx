
package core;

import core.enums.Actions;
import core.enums.Commands;
import core.enums.Events;

class GameEngine {
    public var actions :MessageQueue<Action>;
    public var commands :MessageQueue<Command>;
    public var events :MessageQueue<Event>;

    public function new() {
        actions = new MessageQueue<Action>({ serializable: true });
        commands = new MessageQueue<Command>();
        events = new MessageQueue<Event>();
        /*
        events.on = function(event) {
            trace('Event: $event');
            switch (event) {
                case MinionKilled(id): events.emit([SheepSpawned(id)]);
                case _:
            }
        };
        
        actions.on = function(action) {
            var events = switch (action) {
                case KillAllMinions: [MinionKilled(1), MinionKilled(2)];
            };
            events.emit(events);
        };
        actions.emit([KillAllMinions]);
        */
    }
}
