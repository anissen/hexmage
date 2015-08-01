
package core.enums;

typedef PartialEffectData = { tags :Tags, description :String };
typedef EffectData = { > PartialEffectData, minionId :Int };

enum Command {
    Damage(characterId :Int, amount :Int);
    DrawCard;
    Effect(data :EffectData);
    // Print(s :String);
}

typedef Commands = Array<Command>;
