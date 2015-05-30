
package game.states;

import core.Card;
import core.GameSetup;
import core.Minimax;
import game.entities.CardEntity;
import game.entities.TileEntity;
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

import core.HexLibrary;

using core.HexLibrary.HexTools;

typedef HexTileOptions = {
    > luxe.options.VisualOptions,
    r :Float,
    hex :Hex
}

class HexTile extends luxe.Visual {
    public var hex :Hex;
    public var walkable :Bool;
    var text :Text;

    public function new(options :HexTileOptions) {
        super({
            pos: options.pos,
            color: new Color(0.55, 0.10, 0.55),
            geometry: Luxe.draw.ngon({ sides: 6, r: options.r, angle: 30, solid: true }),
            depth: -50
        });

        this.hex = options.hex;
        this.walkable = true;

        new Visual({
            pos: options.pos,
            color: new Color(0.85, 0.1, 0.85),
            geometry: Luxe.draw.ngon({ sides: 6, r: options.r, angle: 30 }),
            depth: -50
        });

        text = new Text({
            text: options.hex.key,
            // pos: new Vector(options.size.x / 2, options.size.y - 10), //Vector.Divide(options.size, 2),
            color: new Color(0, 0, 1, 1),
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            point_size: 20,
            scene: options.scene,
            parent: this,
            depth: -50
        });
    }

    // override function onmousedown(e :MouseEvent) {
    //     if (Luxe.utils.geometry.point_in_geometry(e.pos, this.geometry)) {
    //         if (e.button == MouseButton.left) {
    //             this.events.fire('clicked');
    //         } else {
    //             this.walkable = !this.walkable;
    //             this.color = walkable ? new Color(0.55, 0.10, 0.55) : new Color(0.25, 0.10, 0.25);
    //         }
    //     }
    // }

    public function claimed(playerId :Int) :Promise {
        this.color.tween(0.3, { h: 100 - playerId * 100, s: 0.6, v: 1 }); // HACK
        // center.color.tween(0.3, { h: 100 - playerId * 100, s: 0.6, v: 0.8 }); // HACK

        return new Promise(function(resolve, reject) {
            resolve();
        });
    }

    // public function flash(delay :Float = 0.0) {
    //     this.color
    //         .tween(0.8, { g: 0.9 })
    //         .reverse()
    //         .delay(delay);
    // }

    public function set_mana_text(mana :Int) {
        // text.text = '$mana mana';
    }
}

class PlayScreenState extends State {
    static public var StateId = 'PlayScreenState';

    var scene :Scene;
    var background :Visual;
    var game :core.Game;
    // var tiles :Array<Array<TileEntity>>;
    var hexMap :Map<String, HexTile>;
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
            case TileClaimed(data): handle_tile_claimed(data);
            case TileReclaimed(data): handle_tile_claimed(data);
            case ManaGained(data): handle_mana_gained(data);
            case ManaSpent(data): handle_mana_spent(data);
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
                pos: game.tile_to_world(pos), //pos.tile_to_world(),
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

        // TODO: Clear mana for claimed tiles?

        return new Promise(function(resolve, reject) {
            resolve();
        });
    }

    function handle_mana_gained(data :ManaGainedData) :Promise {
        // var tile = tiles[data.tileId.y][data.tileId.x];
        // var tile = hexMap['${data.tileId.x},${data.tileId.y}'];
        // tile.set_mana_text(data.total);

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
        // var tile = tiles[data.tileId.y][data.tileId.x];
        // var tile = hexMap['${data.tileId.x},${data.tileId.y}'];
        // tile.set_mana_text(data.left);

        if (!data.player.ai) {
            ownHand.highlight_cards(game);
        } else {
            enemyHand.highlight_cards(game);
        }

        return new Promise(function(resolve, reject) {
            resolve();
        });
    }

    function handle_tile_claimed(data :TileClaimedData) :Promise {
        // var tile = tiles[data.tileId.y][data.tileId.x];
        var tile = hexMap[data.tileId];
        if (tile == null) { // TEMPORARY HACK!!!
            return new Promise(function(resolve, reject) {
                resolve();
            });
        }

        return tile.claimed(data.minion.playerId);
    }

    function handle_players_turn(data :PlayersTurnData) :Promise {
        if (data.player.name == 'AI Player') { // HACK HACK HACK
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
            return ownHand.add_card(data.card, game);
        } else {
            return enemyHand.add_card(data.card, game); 
        }
    }

    function handle_card_played(data :CardPlayedData) :Promise {
        if (data.player.name == 'Human Player') {
            return ownHand.play_card(data.card);
        } else {
            return enemyHand.play_card(data.card);
        }
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

        setup_map();

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
