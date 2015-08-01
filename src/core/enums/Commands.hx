
package core.enums;

typedef EffectData = { minionId :Int, tags :Tags, description :String };

enum Command {
    Damage(characterId :Int, amount :Int);
    DrawCard;
    Effect(data :EffectData);
    // Print(s :String);
}

typedef Commands = Array<Command>;
