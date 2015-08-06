
package game.states;

import luxe.utils.Maths;
import snow.api.Promise;
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
import core.Card;
import core.GameSetup;
import core.Minimax;
import core.enums.Events;
import core.HexLibrary;
import game.entities.Button;
import game.entities.TileEntity;
import game.entities.CardEntity;
import game.entities.MinionEntity;
import game.entities.Notification;
import game.entities.FPS;
import game.components.Indicators.ActionIndicator;
import game.components.Indicators.AttackIndicator;
import game.components.Indicators.MoveIndicator;
import phoenix.Batcher;

import org.gesluxe.Gesluxe;
import org.gesluxe.events.GestureEvent;
import org.gesluxe.gestures.TransformGesture;

using core.HexLibrary.HexTools;

class PlayScreenState extends State {
    static public var StateId = 'PlayScreenState';

    var scene :Scene;
    // var background :Visual;
    static public var game :core.Game; // HACK to expose the game var!! (used in GameSetup)
    var hexMap :Map<String, HexTile>;
    var minionMap :Map<Int, MinionEntity>;
    var eventQueue :List<Event>;
    var idle :Bool;
    var text :Text;
    var statusText :Text;

    var debugBackground :Sprite;
    var debugFPS :FPS;

    var minionActionState :MinionActionsState;
    var ownHand :HandState;
    var enemyHand :HandState;

    var hudBatcher :Batcher;

    var transformGesture :TransformGesture;
    var current_camera_zoom :Float;
    var minimum_zoom :Float;
    var maximum_zoom :Float;

    public function new() {
        super({ name: StateId });

        GameSetup.initialize();

        scene = new Scene('PlayScreenScene');

        minionActionState = new MinionActionsState();
        Main.states.add(minionActionState);

        // hudBatcher = Main.final_batch;
        hudBatcher = Luxe.renderer.create_batcher({ name: 'hud_batcher', layer: 4 });

        ownHand = new HandState('own-hand', hudBatcher, Luxe.screen.h + 5, false);
        Main.states.add(ownHand);
        Main.states.enable(ownHand.stateId);

        enemyHand = new HandState('enemy-hand', hudBatcher, -60, true);
        Main.states.add(enemyHand);
        Main.states.enable(enemyHand.stateId);

        Gesluxe.init();

        transformGesture = new TransformGesture();
        transformGesture.events.listen(GestureEvent.GESTURE_BEGAN, onTransformGesture);
        transformGesture.events.listen(GestureEvent.GESTURE_CHANGED, onTransformGesture);
        transformGesture.events.listen(GestureEvent.GESTURE_ENDED, onTransformGesture);

        Luxe.events.listen('card_clicked', function(data :{ entity :CardEntity, card :Card }) {
            if (!Main.states.enabled(PlayCardState.StateId)) {
                Main.states.enable(PlayCardState.StateId, { game: game, card: data.card });
            } else {
                Main.states.disable(PlayCardState.StateId);
            }
        });
    }

    // TODO: Make this into an Component, e.g. https://gist.github.com/underscorediscovery/2cd52a89470421c51301
    function onTransformGesture(event :GestureEventData) {
        if (transformGesture.scale != 1) {
            var new_zoom = current_camera_zoom * transformGesture.scale;
            Luxe.camera.zoom = luxe.utils.Maths.clamp(new_zoom, minimum_zoom, maximum_zoom);
        }

        // Panning
        Luxe.camera.pos.x -= transformGesture.offsetX / Luxe.camera.zoom;
        Luxe.camera.pos.y -= transformGesture.offsetY / Luxe.camera.zoom;
    }

    function onTransformGestureEnded(event :GestureEventData) {
        current_camera_zoom = Luxe.camera.zoom;
    }

    override public function onmousewheel(event :MouseEvent) {
        // https://gist.github.com/underscorediscovery/2cd52a89470421c51301
        if (event.y == 0) return;
        var zoom_speed = 0.3;
        var new_zoom = Luxe.camera.zoom + (event.y > 0 ? -zoom_speed : zoom_speed);
        Luxe.camera.zoom = Maths.clamp(new_zoom, minimum_zoom, maximum_zoom);
    }

    function handle_next_event() {
        if (eventQueue.isEmpty()) {
            idle = true;
            return;
        }
        handle_event(eventQueue.pop());
    }

    function handle_event(event :Event) {
        statusText.text = statusText.text + '\n · ' + DateTools.format(Date.now(), '%H:%M:%S') + ' ' + event.getName();

        idle = false;
        var handler = switch (event) {
            case GameStarted: handle_game_started();
            case GameOver: handle_game_over();
            case TurnStarted(data): handle_turn_started(data);
            case PlayersTurn(data): handle_players_turn(data);
            case TurnEnded(data): statusText.text =  statusText.text + '\n -----------'; handle_turn_ended(data);
            case MinionMoved(data): handle_minion_moved(data);
            case MinionAttacked(data): handle_minion_attacked(data);
            case MinionDied(data): handle_minion_died(data);
            case MinionEntered(data): handle_minion_entered(data);
            case MinionDamaged(data): handle_minion_damaged(data);
            case CardDrawn(data): handle_card_drawn(data);
            case CardPlayed(data): handle_card_played(data);
            case TileClaimed(data): handle_tile_claimed(data);
            case TileReclaimed(data): handle_tile_claimed(data);
            case ManaGained(data): handle_mana_gained(data);
            case ManaSpent(data): handle_mana_spent(data);
            case EffectTriggered(data): handle_effect_triggered(data);
            case _: {
                trace('$event is unhandled');
                new Promise(function(resolve, reject) {
                    resolve();
                });
            }
        }
        handler.then(handle_next_event);
    }

    function handle_game_started() :Promise {
        return new Promise(function(resolve, reject) {
            text.text = 'Game Started!';
            text.color
                .tween(2 * Settings.TweenFactor, { a: 1 })
                .reverse()
                .onComplete(resolve);
        });
    }

    function handle_game_over() :Promise {
        return new Promise(function(resolve, reject) {
            text.text = 'Game Over!';
            text.color
                .tween(2 * Settings.TweenFactor, { a: 1 })
                .reverse()
                .onComplete(resolve);
        });
    }

    function handle_minion_moved(data :MinionMovedData) :Promise {
        return new Promise(function(resolve, reject) {
            Luxe.audio.play('minion_move${Luxe.utils.random.int(1, 4)}'); // minion_move1...3
            var minionEntity = id_to_minion_entity(data.minion.id);
            var newPos = game.tile_to_world(data.to); //data.to.tile_to_world();
            Actuate
                .tween(minionEntity.pos, 0.6 * Settings.TweenFactor, { x: newPos.x, y: newPos.y })
                .onComplete(function() {
                    update_move_indicator(game.minion(data.minion.id));
                    resolve();
                });
        });
    }

    function handle_minion_attacked(data :MinionAttackedData) :Promise {
        return new Promise(function(resolve, reject) {
            Luxe.audio.play('minion_attack1');
            var minionEntity = id_to_minion_entity(data.minion.id);
            var minionPos = minionEntity.pos.clone();
            var victimEntityPos = id_to_minion_entity(data.victim.id).pos;
            Actuate
                .tween(minionEntity.pos, 0.1 * Settings.TweenFactor, { x: victimEntityPos.x, y: victimEntityPos.y })
                .onComplete(function() {
                    Actuate
                        .tween(minionEntity.pos, 0.2 * Settings.TweenFactor, { x: minionPos.x, y: minionPos.y })
                        .onComplete(function() {
                            update_move_indicator(game.minion(data.minion.id));
                            resolve();
                        });
                });
        });
    }

    function handle_minion_died(data :MinionDiedData) :Promise {
        var minionEntity = id_to_minion_entity(data.minion.id);
        function create_death_animation() {
            return new Promise(function(resolve, reject) {
                Actuate
                    .tween(minionEntity.scale, 0.2 * Settings.TweenFactor, { x: 0, y: 0 })
                    .onComplete(function() {
                        minionMap.remove(data.minion.id);
                        minionEntity.destroy();
                        resolve();
                    });
            });
        }
        if (data.minion.name == 'Rat King') {
            var speechBubble = new game.entities.SpeechBubble({
                scene: this.scene,
                depth: 10,
                texts: ['Noooooo...'],
                duration: 2
            });
            minionEntity.add(speechBubble);
            return speechBubble.get_promise().then(create_death_animation);
        } else {
            return create_death_animation();
        }
    }

    function handle_minion_entered(data :MinionEnteredData) :Promise {
        return new Promise(function(resolve, reject) {
            // Luxe.audio.play('minion_enter4');
            Luxe.audio.play('minion_enter${Luxe.utils.random.int(1, 4)}'); // minion_enter1...3
            var minion = game.minion(data.minion.id);
            var pos = game.minion_pos(minion);
            var minionEntity = new MinionEntity({
                minion: minion,
                pos: game.tile_to_world(pos),
                scene: scene
            });
            minionMap[minion.id] = minionEntity;
            minionEntity.events.listen('clicked', minion_clicked);

            minionEntity.scale.set_xy(0, 0);
            Actuate
                .tween(minionEntity.scale, 0.3 * Settings.TweenFactor, { x: 1.0, y: 1.0 })
                .onComplete(function() {
                    Luxe.camera.shake(1);

                    update_move_indicator(minion);

                    // if (minion.name == 'Rat King') {
                    //     var speechBubble = new game.entities.SpeechBubble({
                    //         scene: this.scene,
                    //         depth: 10,
                    //         texts: ['I am the Rat King!\nHear me roar!', '*squeak squeak*'],
                    //         duration: 4
                    //     });
                    //     minionEntity.add(speechBubble);
                    //     speechBubble.get_promise().then(resolve);
                    // } else {
                        resolve();
                    // }
                });
        });
    }

    function handle_turn_started(data :TurnStartedData) :Promise {
        if (data.player.ai) {
            Luxe.audio.play('enemy_turn_start');
        } else {
            Luxe.audio.play('own_turn_start');
        }
        for (minion in game.minions_for_player(game.current_player)) {
            update_move_indicator(minion);
        }

        return new Promise(function(resolve, reject) {
            resolve();
        });
    }

    function handle_mana_gained(data :ManaGainedData) :Promise {
        var tile = hexMap[data.tileId];
        tile.set_mana(data.total, data.player.id);

        if (!data.player.ai) {
            ownHand.highlight_cards(game);
        } else {
            enemyHand.highlight_cards(game);
        }

        return new Promise(function(resolve, reject) {
            resolve();
        });
    }

    function handle_mana_spent(data :ManaSpentData) :Promise {
        var tile = hexMap[data.tileId];
        tile.set_mana(data.left, data.player.id);

        if (!data.player.ai) {
            ownHand.highlight_cards(game);
        } else {
            enemyHand.highlight_cards(game);
        }

        return new Promise(function(resolve, reject) {
            resolve();
        });
    }

    function handle_effect_triggered(data :EffectTriggeredData) :Promise {
        var minionEntity = id_to_minion_entity(data.minionId);
        var toast = Notification.Toast({
            pos: minionEntity.pos.clone(),
            text: data.description,
            color: new Color(0, 1, 1),
            randomRotation: 10,
            duration: 4,
            scene: scene
        });
        minionEntity.refresh();
        return new Promise(function(resolve, reject) {
            Luxe.timer.schedule(0.2, resolve);
        });
    }

    function handle_tile_claimed(data :TileClaimedData) :Promise {
        var tile = hexMap[data.tileId];
        return tile.claimed(data.minion.playerId);
    }

    function handle_players_turn(data :PlayersTurnData) :Promise {
        var playerBackgroundColor = (data.player.ai ? { r: 0.15, g: 0.12, b: 0.12 } : { r: 0.12, g: 0.15, b: 0.12 });
        Luxe.renderer.clear_color.tween(0.5, playerBackgroundColor);

        if (data.player.ai) {
            var minimax = new Minimax({
                max_turn_depth: 3,
                max_action_depth: 3,
                min_delta_score: -4
            });

            var actions = minimax.best_actions(game);
            // trace('AI tested ${minimax.actions_tested} different sets of actions');
            // trace('AI chose $actions');
            trace('AI; Actions chosen: $actions');
            game.do_turn(actions);
        }

        return new Promise(function(resolve, reject) {
            resolve();
        });
    }

    function handle_minion_damaged(data :MinionDamagedData) :Promise {
        Luxe.audio.play('minion_damage1'); // minion_damage1
        var minionEntity = id_to_minion_entity(data.minion.id);
        Notification.Toast({
            pos: minionEntity.pos.clone(),
            text: '${data.damage} damage',
            color: new Color(1, 0, 0),
            randomRotation: 10,
            scene: scene
        });
        return minionEntity.damage(data.damage);
    }

    function handle_turn_ended(data :TurnEndedData) :Promise {
        return new Promise(function(resolve, reject) {
            for (minion in game.minions_for_player(data.player)) {
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
            resolve();
        });
    }

    function handle_card_drawn(data :CardDrawnData) :Promise {
        Luxe.audio.play('card_draw${Luxe.utils.random.int(1, 3)}');
        if (data.player.name == 'Human Player') {
            return ownHand.add_card(data.card, game);
        } else {
            return enemyHand.add_card(data.card, game); 
        }
    }

    function handle_card_played(data :CardPlayedData) :Promise {
        Luxe.audio.play('card_flip${Luxe.utils.random.int(1, 3)}');
        Luxe.audio.play('card_cast1');
        if (data.player.name == 'Human Player') {
            return ownHand.play_card(data.card);
        } else {
            return enemyHand.play_card(data.card);
        }
    }

    function update_move_indicator(minion :core.Minion) {
        if (minion == null) return;

        var minionEntity = minionMap[minion.id];
        // if (minionEntity == null) {
        //     trace('[update_move_indicator] minionEntity is null -- should this be able to happen?');
        //     trace('Getting minion entity from minion with id: ${minion.id}');
        //     trace('minionMap:');
        //     trace(minionMap);
        //     return;
        // }
        var canAttack = false;
        var canMove = false;
        for (action in game.actions_for_minion(minion)) {
            switch (action) {
                case MoveAction(_): {
                    canMove = true;
                    if (!minionEntity.has('MoveIndicator')) {
                        minionEntity.add(new MoveIndicator({ name: 'MoveIndicator' }));
                    }
                }
                case AttackAction(_): {
                    canAttack = true;
                    if (!minionEntity.has('AttackIndicator')) {
                        minionEntity.add(new AttackIndicator({ name: 'AttackIndicator' }));
                    }
                }
                case _: 
            }
        }

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

    function setup_map() {
        var hexSize = 70;
        var margin = 8;

        var layout = new Layout(Layout.pointy, new Point(hexSize + margin, hexSize + margin), new Point(Luxe.screen.mid.x, Luxe.screen.mid.y));

        hexMap = new Map();

        var map_radius :Int = 3;
        for (hex in create_hexagon_map(map_radius)) {
            var pos = Layout.hexToPixel(layout, hex);
            var tile = new HexTile({
                pos: new Vector(pos.x, pos.y),
                r: hexSize,
                hex: hex
            });
            hexMap[hex.key] = tile;
            // tile.events.listen('clicked', function(_) {
            //     tile.flash();
            //     var ring_hexes = hex.reachable(function(h :Hex) :Bool { 
            //         var t = hexMap[h.key];
            //         return (t != null ? t.walkable : false);
            //     }, 2); //Hex.rings(hex, 1, 2);
            //     var count = 0;
            //     for (h in ring_hexes) {
            //         var t = hexMap[h.key];
            //         if (t != null) {
            //             count++;
            //             t.flash(count * 0.02);
            //         }
            //     }
            // });
        }
    }

    function create_hexagon_map(radius :Int = 3) :Array<Hex> {
        var hexes = [];
        for (q in -radius + 1 ... radius) {
            var r1 = Math.round(Math.max(-radius, -q - radius));
            var r2 = Math.round(Math.min(radius, -q + radius));
            for (r in r1 + 1 ... r2) {
                hexes.push(new Hex(q, r, -q - r));
            }
        }
        return hexes;
    }

    override function onenter<T>(_value :T) {
        setup();
    }

    override function onleave<T>(_value :T) {
        cleanup();
    }

    function reset() {
        cleanup();
        setup();
    }

    function id_to_minion_entity(id :Int) :MinionEntity {
        return minionMap[id];
    }

    function setup() {
        minionMap = new Map();
        eventQueue = new List<Event>();
        idle = true;
        game = GameSetup.create_game();
        game.listen(function(event) {
            eventQueue.add(event);
            if (idle) handle_next_event();
        });

        current_camera_zoom = Luxe.camera.zoom;
        minimum_zoom = 0.5;
        maximum_zoom = 2.0;

        Luxe.renderer.clear_color.tween(1, { r: 0.13, g: 0.13, b: 0.13 });

        setup_map();

        var buttonWidth  = 150;
        var buttonHeight = 50;
        new Button({
            centered: false,
            batcher: hudBatcher,
            pos: Vector.Subtract(Luxe.screen.size, new Vector(buttonWidth + 20, buttonHeight + 60)),
            size: new Vector(buttonWidth, buttonHeight),
            color: new Color(0, 0, 0),
            text: 'End Turn',
            text_color: new Color(1, 1, 1),
            scene: scene,
            callback: function() {
                trace('End Turn pressed!');
                game.end_turn();
            }
        });

        text = new Text({
            text: '',
            pos: Luxe.screen.mid.clone(),
            color: new Color(1, 1, 1, 0),
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            point_size: 38,
            scene: scene,
            depth: 100
        });

        var debugBoxWidth = 300;
        debugBackground = new Sprite({
            centered: false,
            pos: new Vector(Luxe.screen.width - debugBoxWidth, 0),
            size: new Vector(debugBoxWidth, Luxe.screen.height - 150),
            color: new Color(0, 0, 0.2),
            scene: scene,
            depth: 100,
            batcher: hudBatcher
        });

        statusText = new Text({
            text: '',
            pos: new Vector(Luxe.screen.width - debugBoxWidth, Luxe.screen.height - 150),
            size: new Vector(debugBoxWidth, Luxe.screen.height),
            color: new Color(1, 1, 1, 1),
            align: TextAlign.left,
            align_vertical: TextAlign.bottom,
            point_size: 20,
            scene: scene,
            depth: 100,
            batcher: hudBatcher
        });

        debugFPS = new FPS();

        toggle_debug();

        game.start();
    }

    function minion_clicked(data :ClickedEventData) {
        if (data.minion.playerId != game.current_player.id) return;
        if (!Main.states.enabled(MinionActionsState.StateId)) {
            Main.states.enable(MinionActionsState.StateId, { game: game, minionId: data.minion.id });
        } else {
            Main.states.disable(MinionActionsState.StateId);
        }
    }

    function cleanup() {
        scene.empty();
    }

    function toggle_debug() {
        debugBackground.visible = !debugBackground.visible;
        statusText.visible = !statusText.visible;
        debugFPS.visible = !debugFPS.visible;
    }

    override function onkeyup(e :KeyEvent) {
        switch (e.keycode) {
            case Key.key_d: toggle_debug();
            case Key.enter: if (!e.mod.alt) game.end_turn();
            case Key.key_r: reset();
            case Key.escape: Luxe.shutdown(); //Main.states.set(TitleScreenState.StateId);
        }
    }
}
