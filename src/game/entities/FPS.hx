package game.entities;

import luxe.Text;
import luxe.Color;
import luxe.Vector;
import luxe.Log.*;
import luxe.options.TextOptions;

class FPS extends Text {

    public function new( ?_options:luxe.options.TextOptions ) {
        def(_options, {});
        def(_options.name, "fps");
        def(_options.pos, new Vector(5, 5));
        def(_options.point_size, 16);
        def(_options.align, TextAlign.left);

        super(_options);
    }

    public override function update(dt:Float) {
        text = 'FPS : ' + Math.round(1.0 / Luxe.debug.dt_average);
    }

}
