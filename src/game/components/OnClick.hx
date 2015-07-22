
package game.components;

import luxe.Component;
import luxe.Visual;
import luxe.Sprite;
import luxe.Input.MouseEvent;
import luxe.Input.MouseButton;

class OnClick extends Component {
    var visual :Visual;
    var callback :Void->Void;
    var fixed_on_screen :Bool;

    public function new(callback :Void->Void, fixed_on_screen :Bool = true) {
        super();
        this.callback = callback;
        this.fixed_on_screen = fixed_on_screen;
        if (callback == null) throw 'Callback is null';
    }

    override function init() {
        visual = cast entity;
        if (visual == null) throw 'Entity "${entity.name}" is not a Visual';
    }

    override function onmousedown(e :MouseEvent) {
        if (e.button != MouseButton.left) return;
        
        var pos = (fixed_on_screen ? e.pos : Luxe.camera.screen_point_to_world(e.pos));
        if (!Luxe.utils.geometry.point_in_geometry(pos, visual.geometry)) return;
            
        callback();
    }
}
