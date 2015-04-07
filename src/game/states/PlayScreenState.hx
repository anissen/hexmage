
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

class ActionIndicator extends Component {
    public var pulse_speed :Float = 0.8;
    public var pulse_size :Float = 1.08;
    var initial_scale :Vector;

    override function init() {
        initial_scale = entity.scale.clone();
    }

    override function onadded() {
        Actuate
            .tween(entity.scale, pulse_speed, { x: pulse_size, y: pulse_size })
            .reflect()
            .repeat();
    }

    override function onremoved() {
        if (initial_scale == null) return;
        Actuate
            .tween(entity.scale, 0.3, { x: initial_scale.x, y: initial_scale.y });
    }
}

class MoveIndicator extends Component {
    var bg :Sprite;

    override function onadded() {
        bg = new Sprite({
            color: new ColorHSV(0, 0, 1),
            geometry: Luxe.draw.circle({ r: 70 }),
            scale: new Vector(0, 0),
            parent: entity,
            depth: -10
        });
        Actuate.tween(bg.scale, 0.4, { x: 1.0, y: 1.0 });
    }

    override function onremoved() {
        Actuate
            .tween(bg.scale, 0.3, { x: 0.0, y: 0.0 })
            .onComplete(bg.destroy);
    }
}

class AttackIndicator extends Component {
    var bg :Sprite;

    override function onadded() {
        bg = new Sprite({
            color: new Color(1, 0, 0),
            geometry: Luxe.draw.circle({ r: 65 }),
            scale: new Vector(0, 0),
            parent: entity,
            depth: -5
        });
        Actuate.tween(bg.scale, 0.4, { x: 1.0, y: 1.0 });
    }

    override function onremoved() {
        Actuate
            .tween(bg.scale, 0.3, { x: 0.0, y: 0.0 })
            .onComplete(bg.destroy);
    }
}

class PlayScreenState extends State {
    var scene :Scene;
    var background :Visual;
    var game :core.Game;
    var minionMap :Map<Int, MinionEntity>;
    var eventQueue :List<Event>;
    var idle :Bool;

    public function new() {
        super({ name: 'PlayScreenState' });
        scene = new Scene('PlayScreenScene');
    }

    function handle_next_event() {
        if (eventQueue.isEmpty()) {
            idle = true;
            return;
        }
        handle_event(eventQueue.pop());
    }

    function handle_event(event :Event) {
        trace('Handling event $event');
        idle = false;
        switch (event) {
            case MinionMoved(data): {
                //trace('Minion with ID ${data.minionId} moved from ${data.from} to ${data.to}!');
                var minionEntity = id_to_minion_entity(data.minionId);
                var newPos = tile_to_pos(data.to.x, data.to.y);
                Actuate
                    .tween(minionEntity.pos, 0.6, { x: newPos.x, y: newPos.y })
                    .onComplete(function() {
                        update_move_indicator(game.minion(data.minionId));
                        handle_next_event();
                    });
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
                            .onComplete(function() {
                                update_move_indicator(game.minion(data.minionId));
                                handle_next_event();
                            });
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
            case MinionEntered(data): {
                var minion = game.minion(data.minionId);
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

                update_move_indicator(minion);

                handle_next_event();
                // minionEntity.scale.set_xy(0, 0);
                // Actuate
                //     .tween(minionEntity.scale, 0.8, { x: 1.0, y: 1.0 })
                //     .onComplete(function() {
                //         handle_next_event();
                //     });
            }
            case TurnStarted: {
                trace('Player: ' + game.current_player.name);
                if (game.current_player.name == 'AI Player') { // HACK HACK HACK
                    trace('Actions for AI:');
                    trace(game.actions());
                    var actions = tests.SimpleTestGame.AIPlayer.actions_for_turn(game);
                    game.do_turn(actions);
                } else {
                    for (minion in game.minions_for_player(game.current_player)) {
                        update_move_indicator(minion);
                    }
                }
                handle_next_event();
            }
            case TurnEnded: {
                for (minion in game.minions_for_player(game.current_player)) {
                    var minionEntity = minionMap[minion.id];
                    if (minionEntity.has('MoveIndicator')) {
                        minionEntity.remove('MoveIndicator');
                    }
                    if (minionEntity.has('AttackIndicator')) {
                        minionEntity.remove('AttackIndicator');
                    }
                    if (minionEntity.has('ActionIndicator')) {
                        minionEntity.remove('ActionIndicator');
                    }
                }
                handle_next_event();
            }
            case _: {
                trace('$event is unhandled');
                handle_next_event();
            }
        }
    }

    function update_move_indicator(minion :core.Minion) {
        if (minion == null) return;
        if (minion.player.name != 'Human Player') return; // HACK
        //if (minion.player.id != game.current_player.id) return;

        var minionEntity = minionMap[minion.id];
        var canAttack = false;
        var canMove = false;
        for (action in game.actions_for_minion(minion)) {
            switch (action) {
                case Move(_): {
                    trace('Minion ${minion.name} can move!');
                    canMove = true;
                    if (!minionEntity.has('MoveIndicator')) {
                        minionEntity.add(new MoveIndicator({ name: 'MoveIndicator' }));
                    }
                }
                case Attack(_): {
                    trace('Minion ${minion.name} can attack!');
                    canAttack = true;
                    if (!minionEntity.has('AttackIndicator')) {
                        minionEntity.add(new AttackIndicator({ name: 'AttackIndicator' }));
                    }
                }
                case _: 
            }
        }

        trace('Minion ${minion.name} can move: $canMove & can attack: $canAttack!');

        if (!canMove && minionEntity.has('MoveIndicator')) {
            minionEntity.remove('MoveIndicator');
        }

        if (!canAttack && minionEntity.has('AttackIndicator')) {
            minionEntity.remove('AttackIndicator');
        }

        if (!canAttack && !canMove && minionEntity.has('ActionIndicator')) {
            minionEntity.remove('ActionIndicator');
        } else if (canAttack || canMove && !minionEntity.has('ActionIndicator')) {
            minionEntity.add(new ActionIndicator({ name: 'ActionIndicator' }));
        }
    }

    override function init() {
        // trace("INIT PlayScreenState");
    }

    override function onenter<T>(_value :T) {
        // trace("ENTER PlayScreenState");
        setup();
    }

    override function onleave<T>(_value :T) {
        // trace("LEAVE PlayScreenState");
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
        minionMap = new Map();
        eventQueue = new List<Event>();
        idle = true;
        game = tests.SimpleTestGame.create_game();
        game.listen(function(event) {
            eventQueue.add(event);
            if (idle) handle_next_event();
        });

        background = new Visual({
            pos: new Vector(0, 0),
            size: Luxe.screen.size.clone(),
            color: new ColorHSV(200, 0.5, 0.7),
            scene: scene,
            depth: -100
        });

        var boardSize = game.board_size();
        var tileSize = 140;
        for (y in 0 ... boardSize.y) {
            for (x in 0 ... boardSize.x) {
                var tile = new Sprite({
                    pos: tile_to_pos(x, y),
                    color: new ColorHSV(360 * Math.random(), 0.5, 0.5),
                    size: new Vector(tileSize, tileSize),
                    scale: new Vector(0, 0),
                    scene: scene,
                    depth: -50
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
                game.end_turn();
            }
        });

        game.start();
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
