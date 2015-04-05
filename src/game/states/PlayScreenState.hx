
package game.states;

import luxe.Color;
import luxe.Input.KeyEvent;
import luxe.Input.Key;
import luxe.Input.MouseEvent;
import luxe.Input.MouseButton;
import luxe.Scene;
import luxe.Sprite;
import luxe.States;
import luxe.Text;
import luxe.tween.Actuate;
import luxe.Vector;
import luxe.Visual;
import luxe.Component;

import core.Events;

import game.entities.Button;
import game.entities.MinionEntity;
import game.components.OnClick;

class MoveIndicator extends Component {
    public var pulse_speed :Float = 1;
    public var pulse_size :Float = 1.1;
    var initial_scale :Vector;

    override function init() {
        initial_scale = entity.scale.clone();
        Actuate
            .tween(entity.scale, pulse_speed, { x: pulse_size, y: pulse_size })
            .reflect()
            .repeat();
    }

    override function onremoved() {
        Actuate
            .tween(entity.scale, 0.3, { x: initial_scale.x, y: initial_scale.y });
    }
}

class PlayScreenState extends State {
    var scene :Scene;
    var background :Visual;
    var game :core.Game;
    var actions :core.Actions.Actions;
    var minionMap :Map<Int, MinionEntity>;
    var eventQueue :List<Event>;

    public function new() {
        super({ name: 'PlayScreenState' });
        scene = new Scene('PlayScreenScene');
        minionMap = new Map();
        actions = [];
        eventQueue = new List<Event>();
        game = tests.SimpleTestGame.create_game(take_turn);
        game.listen(function(event) {
            eventQueue.add(event);
            if (eventQueue.length == 1) handle_next_event();
        });
    }

    function handle_next_event() {
        if (eventQueue.isEmpty()) return;
        handle_event(eventQueue.pop());
    }

    function handle_event(event :Event) {
        trace('Handling event $event');
        switch (event) {
            case MinionMoved(data): {
                //trace('Minion with ID ${data.minionId} moved from ${data.from} to ${data.to}!');
                var minionEntity = id_to_minion_entity(data.minionId);
                var newPos = tile_to_pos(data.to.x, data.to.y);
                Actuate
                    .tween(minionEntity.pos, 0.8, { x: newPos.x, y: newPos.y })
                    .onComplete(handle_next_event);
            }
            case MinionAttacked(data): {
                var minionEntity = id_to_minion_entity(data.minionId);
                var minionPos = minionEntity.pos.clone();
                var victimPos = id_to_minion_entity(data.victimId).pos;
                Actuate
                    .tween(minionEntity.pos, 0.2, { x: victimPos.x, y: victimPos.y })
                    .onComplete(function() {
                        Actuate
                            .tween(minionEntity.pos, 0.3, { x: minionPos.x, y: minionPos.y })
                            .onComplete(handle_next_event);
                    });
            }
            case MinionDied(data): {
                var minionEntity = id_to_minion_entity(data.minionId);
                Actuate
                    .tween(minionEntity.scale, 0.2, { x: 0, y: 0 })
                    .onComplete(function() {
                        minionMap.remove(data.minionId);
                        minionEntity.destroy();
                        handle_next_event();
                    });
            }
            case _: trace('$event is unhandled');
        }
    }

    override function init() {
        trace("INIT PlayScreenState");
    }

    override function onenter<T>(_value :T) {
        trace("ENTER PlayScreenState");
        setup();
    }

    override function onleave<T>(_value :T) {
        trace("LEAVE PlayScreenState");
        cleanup();
    }

    function reset() {
        cleanup();
        setup();
    }

    function id_to_minion_entity(id :Int) :MinionEntity {
        return minionMap[id];
    }

    function tile_to_pos(x, y) :Vector {
        var tileSize = 140;
        return new Vector(180 + tileSize / 2 + x * (tileSize + 10), 20 + tileSize / 2 + y * (tileSize + 10));
    }

    function setup() {
        background = new Visual({
            pos: new Vector(0, 0),
            size: Luxe.screen.size.clone(),
            color: new ColorHSV(200, 0.5, 0.7),
            scene: scene
        });

        var boardSize = game.board_size();
        var tileSize = 140;
        Actuate
            .tween(background.color, 0.3, { h: 240, s: 0.5, v: 0.7 })
            .onComplete(function() {
                for (y in 0 ... boardSize.y) {
                    for (x in 0 ... boardSize.x) {
                        var tile = new Sprite({
                            pos: tile_to_pos(x, y),
                            color: new ColorHSV(360 * Math.random(), 0.5, 0.5),
                            size: new Vector(tileSize, tileSize),
                            scale: new Vector(0, 0),
                            scene: scene
                        });
                        tile.rotation_z = -25 + 50 * Math.random();
                        Actuate
                            .tween(tile, 0.2, { rotation_z: 0 })
                            .delay((y * boardSize.x + x) / 20);
                        Actuate
                            .tween(tile.scale, 0.2, { x: 1, y: 1 })
                            .delay((y * boardSize.x + x) / 20);
                    }
                }

                var minions = game.minions();
                for (minion in minions) {
                    var pos = game.minion_pos(minion);
                    var minionEntity = new MinionEntity({
                        minion: minion,
                        pos: tile_to_pos(pos.x, pos.y),
                        scene: scene
                    });
                    minionMap[minion.id] = minionEntity;
                    minionEntity.events.listen('clicked', minion_clicked);

                    new Text({
                        text: '${minion.name}\n${minion.attack}/${minion.life}',
                        color: new Color(1, 1, 1, 1),
                        align: TextAlign.center,
                        align_vertical: TextAlign.center,
                        point_size: 20,
                        scene: scene,
                        parent: minionEntity
                    });
                }

                var actions = game.actions();
                for (action in actions) {
                    switch (action) {
                        case Move(m):
                            var minion = minionMap[m.minionId];
                            if (!minion.has('MoveIndicator'))
                                minion.add(new MoveIndicator({ name: 'MoveIndicator' }));
                        case _:
                    }
                }
            });

        var buttonWidth  = 150;
        var buttonHeight = 50;
        new Button({
            centered: false,
            pos: Vector.Subtract(Luxe.screen.size, new Vector(buttonWidth + 20, buttonHeight + 20)),
            size: new Vector(buttonWidth, buttonHeight),
            color: new Color(0, 0, 0),
            text: 'End Turn',
            text_color: new Color(1, 1, 1),
            callback: function() {
                trace('End Turn pressed!');
                game.do_end_turn();
            }
        });
    }

    function minion_clicked(data :ClickedEventData) {
        if (!game.is_current_player(data.minion.player)) return;
        // trace('${data.minion.name} was clicked!');
        if (!Main.states.enabled('MinionActionsState')) {
            Main.states.enable('MinionActionsState', { game: game, minionId: data.minion.id });
        } else {
            Main.states.disable('MinionActionsState');
        }
    }

    function take_turn(game :core.Game) :core.Actions.Actions {
        var turn_actions = actions.copy();
        actions = [];
        return turn_actions;
    }

    function cleanup() {
        scene.empty();
    }

    override function onkeyup(e :KeyEvent) {
        switch (e.keycode) {
            case Key.key_r: reset();
            case Key.escape: Luxe.shutdown(); //Main.switch_to_state('TitleScreenState');
        }
    }
}
