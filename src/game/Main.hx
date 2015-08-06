
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

    // var final_output: RenderTexture;
    // static public var final_batch: Batcher;
    // var final_view: Sprite;
    // var final_shader: Shader;

    // static public var text_shader: phoenix.Shader;

    override function config(config :luxe.AppConfig) {
        // if you have errors about the window being created, lower this to 2, or 0. it can also be 8
        config.render.antialiasing = 4;

        return config;
    }

    override function ready() {        
        Luxe.resources.load_json('assets/parcel.json').then(function(jsonParcel) {
            var parcel = new Parcel({
                oncomplete: assets_loaded,
                onfailed: function(err) {
                    trace('Parcel loading failed; $err');
                }
            });
            parcel.from_json(jsonParcel.asset.json);

            new ParcelProgress({
                parcel: parcel,
                background: Luxe.renderer.clear_color,
                oncomplete: function(_) {}
            });

            parcel.load();
        }).error(function(s) {
            trace('Error $s');
            throw s;
        });

        //because the text effects are set through shaders,
        //if you share a shader across text items, and change "just one"
        //they all get affected. For this reason, the default bitmap font
        //shader will refuse effects set on it via text objects because
        //it directly affects the shared shader for the debug console etc
        //so, for unique items, you want a unique shader for each effect.
        // text_shader = Luxe.renderer.shaders.bitmapfont.shader.clone('text-shader');
    }

    function assets_loaded(_) {
        // trace('assets_loaded');
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
        }
        */
    }
    
    /*
    function setup_render_to_texture() {
        final_output = new RenderTexture({ id: 'render-to-texture', width: Luxe.screen.w, height: Luxe.screen.h });
        final_batch = Luxe.renderer.create_batcher({ no_add: true });
        final_shader = Luxe.resources.shader('full');
        final_shader.set_vector2('resolution', Luxe.screen.size );
        final_view = new Sprite({
            centered: false,
            pos: new Vector(0,0),
            size: Luxe.screen.size,
            texture: final_output,
            shader: final_shader, //Luxe.renderer.shaders.textured.shader,
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
    */
}
