
package game.states;

import core.Card;
import core.GameSetup;
import core.Minimax;
import core.Point;
import game.entities.CardEntity;
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

import core.enums.Events;

import game.entities.Button;
import game.entities.MinionEntity;
import game.components.Indicators.ActionIndicator;
import game.components.Indicators.AttackIndicator;
import game.components.Indicators.MoveIndicator;
import snow.api.Promise;

using game.extensions.PointTools;

class PlayScreenState extends State {
    static public var StateId = 'PlayScreenState';

    var scene :Scene;
    var background :Visual;
    var game :core.Game;
    var minionMap :Map<Int, MinionEntity>;
    var eventQueue :List<Event>;
    var idle :Bool;
    var text :Text;

    var minionActionState :MinionActionsState;
    var ownHand :HandState;
    var enemyHand :HandState;

    public function new() {
        super({ name: StateId });

        GameSetup.initialize();

        scene = new Scene('PlayScreenScene');

        minionActionState = new MinionActionsState();
        Main.states.add(minionActionState);

        ownHand = new HandState('own-hand', Luxe.screen.h - 20, false);
        Main.states.add(ownHand);
        Main.states.enable(ownHand.stateId);

        enemyHand = new HandState('enemy-hand', -40, true);
        Main.states.add(enemyHand);
        Main.states.enable(enemyHand.stateId);

        Luxe.events.listen('card_clicked', function(data :{ entity :CardEntity, card :Card }) {
            if (!Main.states.enabled(PlayCardState.StateId)) {
                Main.states.enable(PlayCardState.StateId, { game: game, card: data.card });
            } else {
                Main.states.disable(PlayCardState.StateId);
            }
        });
    }

    function handle_next_event() {
        if (eventQueue.isEmpty()) {
            idle = true;
            return;
        }
        handle_event(eventQueue.pop());
    }

    function handle_event(event :Event) {
        // trace('Handling event $event');
        idle = false;
        var handler = switch (event) {
            case GameStarted: handle_game_started();
            case GameOver: handle_game_over();
            case TurnStarted(data): handle_turn_started(data);
            case PlayersTurn(data): handle_players_turn(data);
            case TurnEnded(data): handle_turn_ended(data);
            case MinionMoved(data): handle_minion_moved(data);
            case MinionAttacked(data): handle_minion_attacked(data);
            case MinionDied(data): handle_minion_died(data);
            case MinionEntered(data): handle_minion_entered(data);
            case MinionDamaged(data): handle_minion_damaged(data);
            case CardDrawn(data): handle_card_drawn(data);
            case CardPlayed(data): handle_card_played(data);
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
            var minionEntity = id_to_minion_entity(data.minion.id);
            var newPos = data.to.tile_to_world();
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
        return new Promise(function(resolve, reject) {
            var minionEntity = id_to_minion_entity(data.minion.id);
            Actuate
                .tween(minionEntity.scale, 0.2 * Settings.TweenFactor, { x: 0, y: 0 })
                .onComplete(function() {
                    minionMap.remove(data.minion.id);
                    minionEntity.destroy();
                    resolve();
                });
        });
    }

    function handle_minion_entered(data :MinionEnteredData) :Promise {
        return new Promise(function(resolve, reject) {
            var minion = game.minion(data.minion.id);
            var pos = game.minion_pos(minion);
            var minionEntity = new MinionEntity({
                minion: minion,
                pos: pos.tile_to_world(),
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
                    resolve();
                });
        });
    }

    function handle_turn_started(data :TurnStartedData) :Promise {
        for (minion in game.minions_for_player(game.current_player)) {
            update_move_indicator(minion);
        }

        return new Promise(function(resolve, reject) {
            resolve();
        });
    }

    function handle_players_turn(data :PlayersTurnData) :Promise {
        if (data.player.name == 'AI Player') { // HACK HACK HACK
            var minimax = new Minimax({
                max_turn_depth: 1,
                max_action_depth: 2,
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
        var minionEntity = id_to_minion_entity(data.minion.id);
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
        if (data.player.name == 'Human Player') {
            return ownHand.add_card(data.card);
        } else {
            return enemyHand.add_card(data.card); 
        }
        return new Promise(function(resolve, reject) {
            resolve();
        });
    }

    function handle_card_played(data :CardPlayedData) :Promise {
        if (data.player.name == 'Human Player') {
            return ownHand.play_card(data.card);
        } else {
            return enemyHand.play_card(data.card);
        }
        return new Promise(function(resolve, reject) {
            resolve();
        });
    }

    function update_move_indicator(minion :core.Minion) {
        if (minion == null) return;

        var minionEntity = minionMap[minion.id];
        if (minionEntity == null) {
            trace('[update_move_indicator] minionEntity is null -- should this be able to happen?');
            trace('Getting minion entity from minion with id: ${minion.id}');
            trace('minionMap:');
            trace(minionMap);
            return;
        }
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

    function setup() {
        minionMap = new Map();
        eventQueue = new List<Event>();
        idle = true;
        game = GameSetup.create_game();
        game.listen(function(event) {
            eventQueue.add(event);
            if (idle) handle_next_event();
        });

        background = new Visual({
            pos: new Vector(0, 0),
            size: Luxe.screen.size.clone(),
            color: new ColorHSV(359, 0.0, 0.13),
            scene: scene,
            depth: -100
        });

        var boardSize = game.board_size();
        var minSize = Math.min(Luxe.screen.w, Luxe.screen.h);
        var tileCount = 5;
        var tileMargin = 10;
        var tileSize = (minSize - tileMargin * tileCount) / tileCount; // 120;
        // var tileSize = 120;
        var tileBorder = 8;
        for (y in 0 ... boardSize.y) {
            for (x in 0 ... boardSize.x) {
                var point :Point = { x: x, y: y };
                var hue = 360 * Math.random();
                var tile = new Sprite({
                    pos: point.tile_to_world(),
                    color: new ColorHSV(hue, 0.5, 1),
                    size: new Vector(tileSize, tileSize),
                    scale: new Vector(0, 0),
                    scene: scene,
                    depth: -50
                });
                new Sprite({
                    pos: new Vector(tileSize / 2, tileSize / 2),
                    size: new Vector(tileSize - tileBorder, tileSize - tileBorder),
                    color: new ColorHSV(hue, 0.5, 0.8),
                    scene: scene,
                    parent: tile,
                    depth: -50
                });
                tile.rotation_z = -25 + 50 * Math.random();
                Actuate
                    .tween(tile, 0.2 * Settings.TweenFactor, { rotation_z: 0 })
                    .delay(((y * boardSize.x + x) / 20) * Settings.TweenFactor);
                Actuate
                    .tween(tile.scale, 0.2 * Settings.TweenFactor, { x: 1, y: 1 })
                    .delay(((y * boardSize.x + x) / 20) * Settings.TweenFactor);
            }
        }

        var buttonWidth  = 150;
        var buttonHeight = 50;
        new Button({
            centered: false,
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
            point_size: 32,
            scene: scene,
            depth: 100
        });

        game.start();
    }

    function minion_clicked(data :ClickedEventData) {
        if (data.minion.playerId != game.current_player.id) return;
        // trace('${data.minion.name} was clicked!');
        if (!Main.states.enabled(MinionActionsState.StateId)) {
            Main.states.enable(MinionActionsState.StateId, { game: game, minionId: data.minion.id });
        } else {
            Main.states.disable(MinionActionsState.StateId);
        }
    }

    function cleanup() {
        scene.empty();
    }

    override function onkeyup(e :KeyEvent) {
        switch (e.keycode) {
            case Key.enter: if (!e.mod.alt) game.end_turn();
            case Key.key_r: reset();
            case Key.escape: Luxe.shutdown(); //Main.states.set(TitleScreenState.StateId);
        }
    }
}
