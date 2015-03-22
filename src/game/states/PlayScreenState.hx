
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

typedef ButtonOptions = {
    > luxe.options.SpriteOptions,
    text :String,
    text_color :Color,
    callback :Void->Void
}

class Button extends Sprite {
    var text :Text;
    var callback :Void->Void;

    public function new(options :ButtonOptions) {
        super(options);

        text = new Text({
            pos: Vector.Multiply(this.size, 0.5),
            text: options.text,
            color: options.text_color,
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            parent: this
        });

        callback = options.callback;
    }

    override public function onmousedown(e :MouseEvent) {
        if (e.button == MouseButton.left && point_inside(e.pos)) callback();
    }
}

/*
class PlayerTurnActions {
    static public function actions_for_turn(game :Game) :Array<Action> {
        var newGame = game.clone();
        var actions = [];
        while (true) {
            newGame.print();

            var available_actions = newGame.get_actions();
            if (available_actions.length == 0)
                return actions;

            Sys.println("Available actions:");
            for (i in 0 ... available_actions.length) {
                // trace(available_actions[i]);
                Sys.println('[${i + 1}] ${action_to_string(available_actions[i], newGame)}');
            }
            var end_turn_index = available_actions.length + 1;
            Sys.println('[$end_turn_index] End turn');

            Sys.println('Select action (1-$end_turn_index): ');
            Sys.print(">>> ");
            var selection = Sys.stdin().readLine();
            var actionIndex = Std.parseInt(selection);
            if (actionIndex != null && actionIndex > 0 && actionIndex <= end_turn_index) {
                if (actionIndex == end_turn_index)
                    return actions;

                var action = available_actions[actionIndex - 1];
                newGame.do_action(action);
                actions.push(action);
                continue;
            }

            Sys.println('$selection is an invalid action index');
        }
    }
}
*/

class MoveIndicator extends Component {
    public var pulse_speed :Float = 1;
    public var pulse_size :Float = 1.1;
    var initial_scale :Vector;
    var visual :Visual;

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

    public function new() {
        super({ name: 'PlayScreenState' });
        scene = new Scene('PlayScreenScene');
        actions = [];
        game = tests.SimpleTestGame.create_game(take_turn);
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

        var id_to_minion = new Map();
        var boardSize = game.get_board_size();
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

                var minions = game.get_minions();
                for (m in minions) {
                    var pos = game.get_minion_pos(m);
                    var minion = new Visual({
                        pos: tile_to_pos(pos.x, pos.y),
                        color: new ColorHSV(100 * m.player.id, 0.8, 0.8),
                        geometry: Luxe.draw.circle({ r: 60 }),
                        scene: scene
                    });
                    id_to_minion[m.id] = minion;

                    new Text({
                        text: '${m.name}\n${m.attack}/${m.life}',
                        color: new Color(1, 1, 1, 1),
                        align: TextAlign.center,
                        align_vertical: TextAlign.center,
                        point_size: 20,
                        scene: scene,
                        parent: minion
                    });
                }

                var actions = game.get_actions();
                for (action in actions) {
                    switch (action) {
                        case Move(m):
                            var minion = id_to_minion[m.minionId];
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
                game.take_turn();
            }
        });

        // TODO:
        // · Make minions clickable
        // · Show possible moves when clicked
        // · Perform a move by clicking on a tile
        // · Append the move action to "actions"
        // · Update state (e.g. by reacting to a Moved-event)
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
