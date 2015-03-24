
package core;

enum Command {
    DrawCards(count :Int);
    Print(s :String);
}

typedef Commands = Array<Command>;
