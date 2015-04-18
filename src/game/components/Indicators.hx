
package game.components;

import luxe.Component;
import luxe.Vector;
import luxe.Sprite;
import luxe.Color;
import luxe.tween.Actuate;

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
            geometry: Luxe.draw.circle({ r: 65 }),
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
            geometry: Luxe.draw.circle({ r: 61 }),
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
