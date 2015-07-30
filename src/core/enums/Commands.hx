
package core.enums;

enum Command {
    Damage(characterId :Int, amount :Int);
    DrawCard;
    Effect(minionId :Int, tags :Tags);
    // Print(s :String);
}

typedef Commands = Array<Command>;
