function insert_particle_system() {
        var content = '{
    "emit_time": 0.05,
    "emit_count": 1,
    "direction": 0,
    "direction_random": 360,
    "speed": 1.6517857142857142,
    "speed_random": 0.8482142857142858,
    "end_speed": 0,
    "life": 1.8973214285714284,
    "life_random": 0,
    "rotation": 0,
    "rotation_random": 33.75,
    "end_rotation": 0,
    "end_rotation_random": 81.96428571428571,
    "rotation_offset": 0,
    "pos_offset": {
        "_construct": false,
        "ignore_listeners": false,
        "w": 0,
        "z": 0,
        "y": 0,
        "x": 0
    },
    "pos_random": {
        "_construct": false,
        "ignore_listeners": false,
        "w": 0,
        "z": 0,
        "y": 12.053571428571429,
        "x": 12.053571428571429
    },
    "gravity": {
        "_construct": false,
        "ignore_listeners": false,
        "w": 0,
        "z": 0,
        "y": 0.8928571428571388,
        "x": 0
    },
    "start_size": {
        "_construct": false,
        "ignore_listeners": false,
        "w": 0,
        "z": 0,
        "y": 64,
        "x": 64
    },
    "start_size_random": {
        "_construct": false,
        "ignore_listeners": false,
        "w": 0,
        "z": 0,
        "y": 3.7142857142857144,
        "x": 3.142857142857143
    },
    "end_size": {
        "_construct": false,
        "ignore_listeners": false,
        "w": 0,
        "z": 0,
        "y": 8,
        "x": 8
    },
    "end_size_random": {
        "_construct": false,
        "ignore_listeners": false,
        "w": 0,
        "z": 0,
        "y": 0,
        "x": 0
    },
    "start_color": {
        "v": 0.5,
        "s": 1,
        "h": 60,
        "refreshing": false,
        "is_hsv": true,
        "is_hsl": false,
        "a": 1,
        "b": 0,
        "g": 0.5,
        "r": 0.5
    },
    "end_color": {
        "v": 0.5,
        "s": 1,
        "h": 53.035714285714285,
        "refreshing": false,
        "is_hsv": true,
        "is_hsl": false,
        "a": 0,
        "b": 0,
        "g": 0.4419642857142857,
        "r": 0.5
    }
}';

        var json = haxe.Json.parse(content);

        // grab loaded particle values
        var loaded :luxe.options.ParticleOptions.ParticleEmitterOptions = {
            emit_time: json.emit_time,
            emit_count: json.emit_count,
            direction: json.direction,
            direction_random: json.direction_random,
            speed: json.speed,
            speed_random: json.speed_random,
            end_speed: json.end_speed,
            life: json.life,
            life_random: json.life_random,
            rotation: json.zrotation,
            rotation_random: json.rotation_random,
            end_rotation: json.end_rotation,
            end_rotation_random: json.end_rotation_random,
            rotation_offset: json.rotation_offset,
            pos_offset: new Vector(json.pos_offset.x, json.pos_offset.y),
            pos_random: new Vector(json.pos_random.x, json.pos_random.y),
            gravity: new Vector(json.gravity.x, json.gravity.y),
            start_size: new Vector(json.start_size.x, json.start_size.y),
            start_size_random: new Vector(json.start_size_random.x, json.start_size_random.y),
            end_size: new Vector(json.end_size.x, json.end_size.y),
            end_size_random: new Vector(json.end_size_random.x, json.end_size_random.y),
            start_color: new Color(json.start_color.r, json.start_color.g, json.start_color.b, json.start_color.a),
            end_color: new Color(json.end_color.r, json.end_color.g, json.end_color.b, json.end_color.a)
        };
        // loaded.particle_image = Luxe.resources.texture('assets/images/monkey.png');

        var particles = new luxe.Particles.ParticleSystem({name: 'particles'});
        particles.pos = Luxe.screen.mid.clone();
        particles.add_emitter(loaded);
    }
