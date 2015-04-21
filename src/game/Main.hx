
package game;

import luxe.Input.KeyEvent;
import luxe.Input.Key;
import luxe.States;
import luxe.tween.Actuate;
import luxe.Sprite;
import luxe.Color;
import luxe.Vector;
import luxe.Parcel;
import luxe.ParcelProgress;

import phoenix.Batcher.BlendMode;
import phoenix.RenderTexture;
import phoenix.Texture;
import phoenix.Batcher;
import phoenix.Shader;

import game.states.*;

class Main extends luxe.Game {
    static public var states :States;

    var final_output: RenderTexture;
    var final_batch: Batcher;
    var final_view: Sprite;
    var final_shader: Shader;

    override function ready() {
        // Luxe.loadJSON("assets/parcel.json", function(jsonParcel) {
        //     var parcel = new Parcel();
        //     parcel.from_json(jsonParcel.json);

        //     new ParcelProgress({
        //         parcel: parcel,
        //         background: Luxe.renderer.clear_color,
        //         oncomplete: assets_loaded
        //     });
            
        //     parcel.load();
        // });
        assets_loaded(null);
    }

    function assets_loaded(_) {
        Actuate.defaultEase = luxe.tween.easing.Quad.easeInOut;

        // setup_render_to_texture();

        states = new States({ name: 'state_machine' });
        states.add(new TitleScreenState());
        states.add(new PlayCardState());
        states.add(new PlayScreenState());

        states.set(PlayScreenState.StateId);
    }

    override function onkeyup(e :KeyEvent) {
        if (e.keycode == Key.enter && e.mod.alt) {
            app.app.window.fullscreen = !app.app.window.fullscreen;
        } /* else if (e.keycode == Key.key_s) {
            if (final_view.shader == final_shader) {
                final_view.shader = Luxe.renderer.shaders.textured.shader;
            } else {
                final_view.shader = final_shader;
            }
        } */
    }

    function setup_render_to_texture() {
        final_output = new RenderTexture(Luxe.resources, Luxe.screen.size);
        final_batch = Luxe.renderer.create_batcher({ no_add: true });
        final_shader = Luxe.loadShader('assets/shaders/full.glsl');
        final_shader.set_vector2('resolution', Luxe.screen.size );
        final_view = new Sprite({
            centered: false,
            pos: new Vector(0,0),
            size: Luxe.screen.size,
            texture: final_output,
            shader: Luxe.renderer.shaders.textured.shader,
            batcher: final_batch
        });
    }

    override function onprerender() {
        if (final_output == null) return;

        final_shader.set_float('time', Luxe.time);
        Luxe.renderer.target = final_output;
        Luxe.renderer.clear(new Color(0,0,0,1));
    }

    override function onpostrender() {
        if (final_batch == null) return;

        Luxe.renderer.target = null;
        Luxe.renderer.clear(new Color(1,0,0,1));
        Luxe.renderer.blend_mode(BlendMode.src_alpha, BlendMode.zero);
        final_batch.draw();
        Luxe.renderer.blend_mode();
    }
}
