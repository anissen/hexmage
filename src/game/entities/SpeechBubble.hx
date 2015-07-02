
package game.entities;

import luxe.Component;
import luxe.Entity;
import luxe.Scene;
import luxe.Visual;
import luxe.Text;
import luxe.options.TextOptions;
import luxe.Color;
import luxe.Vector;
import luxe.NineSlice;
import luxe.tween.Actuate;

typedef SpeechBubbleOptions = {
    scene :Scene,
    depth :Int
}

class SpeechBubble extends Component {
    var sx : Int = 60;
    var sy : Int = 60;
    var text :luxe.Text;
    var speech_bubble :NineSlice;

    public function new(_options :SpeechBubbleOptions) {
        super({ name: 'SpeechBubble' });

        speech_bubble = new NineSlice({
            name_unique: true,
            texture: Luxe.resources.texture('assets/images/speech_bubble.png'),
            top: 10,
            left: 10,
            right: 10,
            bottom: 10,
            color: new Color(1, 1, 1, 0),
            scene: _options.scene,
            depth: _options.depth
        });
        speech_bubble.visible = false;
    }

    override function init() {
        entity.transform.listen_pos(function(v) {
            speech_bubble.pos = get_corrected_pos(v);
        });

        var unique_shader = Luxe.renderer.shaders.bitmapfont.shader.clone('blah-text');
        unique_shader.set_float('thickness', 1.0);
        unique_shader.set_float('smoothness', 0.8);
        unique_shader.set_float('outline', 0.75);
        unique_shader.set_vector4('outline_color', new Vector(1,0,0,1));

        text = new Text({
            text: '',
            pos: new Vector(15, 35),
            shader: unique_shader,
            color: new Color(0, 0, 0, 0),
            align: TextAlign.left,
            align_vertical: TextAlign.center,
            point_size: 24,
            parent: speech_bubble,
            depth: 101
        });
        
        speech_bubble.create(get_corrected_pos(entity.pos), 60, 60);
        speech_bubble.visible = true;
    }

    override function onadded() {
        
    }

    override function onremoved() {
        hide();
    }

    function get_corrected_pos(v :Vector) :Vector {
        return Vector.Add(v, new Vector(20, -90));
    }

    function sizechange() {
        speech_bubble.size = new Vector(sx, sy);
    }

    function resize(width :Float, height :Float, duration :Float) {
        return Actuate.tween(this, duration, { sx: width, sy: height }, true).onUpdate(sizechange);
    }

    function hide() {
        text.text = '';
        Actuate.tween(speech_bubble.color, 0.4, { a: 0 }, true).ease(luxe.tween.easing.Linear.easeNone);
        Actuate.tween(text.color, 0.4, { a: 0 }, true).ease(luxe.tween.easing.Linear.easeNone);

        resize_container(0, 0, 0.4).onComplete(function() {
            speech_bubble.visible = false;
            text.visible = false;
        });
    }

    function resize_container(width :Float, height :Float, duration :Float = 0.4, margin :Float = 5) {
        return resize(
                speech_bubble.left + margin + width  + margin + speech_bubble.right, 
                speech_bubble.top  + margin + height + margin + speech_bubble.bottom,
                duration);
    }

    // TODO: Make this a static function that adds/removes this component!
    public function show(_text :String, _duration :Float = 5) {
        text.text = _text;
        Actuate.tween(speech_bubble.color, 0.3, { a: 1 }).ease(luxe.tween.easing.Linear.easeNone);

        Actuate.tween(text.color, 0.5, { a: 1 }, true).ease(luxe.tween.easing.Linear.easeNone);
        resize_container(text.geom.text_width, text.geom.text_height, 0.5);
        speech_bubble.visible = true;
        text.visible = true;

        Luxe.timer.schedule(_duration, hide);
    }
}
