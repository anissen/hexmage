
package game.components;

import luxe.Component;
import luxe.Visual;
import luxe.Sprite;
import luxe.Input.MouseEvent;
import luxe.Input.MouseButton;

typedef OnClickOptions = {
    callback :Void->Void,
    ?fixed_to_screen :Bool
}

class OnClick extends Component {
    var visual :Visual;
    var callback :Void->Void;
    var fixed_to_screen :Bool;

    public function new(options :OnClickOptions) {
        super();
        callback = options.callback;
        fixed_to_screen = (options.fixed_to_screen ? options.fixed_to_screen : false);
        if (callback == null) throw 'Callback is null';
    }

    override function init() {
        visual = cast entity;
        if (visual == null) throw 'Entity "${entity.name}" is not a Visual';
    }

    override function onmousedown(e :MouseEvent) {
        if (e.button != MouseButton.left) return;
        
        var pos = (fixed_to_screen ? e.pos : Luxe.camera.screen_point_to_world(e.pos));
        if (!Luxe.utils.geometry.point_in_geometry(pos, visual.geometry)) return;
            
        callback();
    }
}
