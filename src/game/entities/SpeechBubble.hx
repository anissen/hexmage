
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
    depth :Int,
    text :String,
    ?duration :Float
}

class SpeechBubble extends Component {
    var sx : Int = 60;
    var sy : Int = 60;
    var speech_text :luxe.Text;
    var speech_bubble :NineSlice;
    var text :String;
    var duration :Null<Float>;

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

        var unique_shader = Luxe.renderer.shaders.bitmapfont.shader.clone('blah-text');
        unique_shader.set_float('thickness', 1.0);
        unique_shader.set_float('smoothness', 0.8);
        unique_shader.set_float('outline', 0.75);
        unique_shader.set_vector4('outline_color', new Vector(1,0,0,1));

        speech_text = new Text({
            text: '',
            pos: new Vector(18, 41),
            shader: unique_shader,
            color: new Color(0, 0, 0, 0),
            align: TextAlign.left,
            align_vertical: TextAlign.center,
            point_size: 24,
            parent: speech_bubble,
            depth: 101
        });

        text = _options.text;
        duration = _options.duration;
    }

    override function init() {
        
    }

    override function onadded() {
        speech_bubble.create(get_corrected_pos(entity.pos), 60, 60);

        speech_text.text = text;
        Actuate.tween(speech_bubble.color, 0.3, { a: 1 }).ease(luxe.tween.easing.Linear.easeNone);

        Actuate.tween(speech_text.color, 0.5, { a: 1 }, true).ease(luxe.tween.easing.Linear.easeNone);
        resize_container(speech_text.geom.text_width, speech_text.geom.text_height, 0.5);
        speech_bubble.visible = true;
        speech_text.visible = true;

        entity.transform.listen_pos(function(v) {
            speech_bubble.pos = get_corrected_pos(v);
        });
        

        if (duration != null) {
            Luxe.timer.schedule(duration, this.remove.bind(this.name));
        }
    }

    override function onremoved() {
        speech_text.text = '';
        Actuate.tween(speech_bubble.color, 0.4, { a: 0 }, true).ease(luxe.tween.easing.Linear.easeNone);
        Actuate.tween(speech_text.color, 0.4, { a: 0 }, true).ease(luxe.tween.easing.Linear.easeNone);

        resize_container(0, 0, 0.4).onComplete(function() {
            speech_bubble.visible = false;
            speech_text.visible = false;
        });
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

    function resize_container(width :Float, height :Float, duration :Float = 0.4, margin :Float = 5) {
        return resize(
                speech_bubble.left + margin + width  + margin + speech_bubble.right, 
                speech_bubble.top  + margin + height + margin + speech_bubble.bottom,
                duration);
    }

    // static public function ShowSequence(options :SpeechBubbleShowSequenceOptions) {
    //     var component = new SpeechBubble(options);
    //     component.text = options.text;
    //     Luxe.timer.schedule(options.duration, component.destroy);
    //     return component;
    // }
}
