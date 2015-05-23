
package core.enums;

enum Command {
    Damage(characterId :Int, amount :Int);
    DrawCard;
    // Print(s :String);
}

typedef Commands = Array<Command>;
