
package game.components;

import luxe.Component;
import luxe.Visual;
import luxe.Sprite;
import luxe.Input.MouseEvent;
import luxe.Input.MouseButton;

class OnClick extends Component {
    var visual :Visual;
    var callback :Void->Void;

    public function new(callback :Void->Void) {
        super();
        this.callback = callback;
        if (callback == null) throw 'Callback is null';
    }

    override function init() {
        visual = cast entity;
        if (visual == null) throw 'Entity "${entity.name}" is not a Visual';
    }

    override function onmousedown(e :MouseEvent) {
        if (e.button == MouseButton.left && Luxe.utils.geometry.point_in_geometry(e.pos, visual.geometry)) {
            callback();
        }
    }
}
