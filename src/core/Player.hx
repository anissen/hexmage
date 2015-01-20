
package core;

typedef Player = { id :Int, name :String, ?take_turn :Game->Array<core.Actions.Action> };
typedef Players = Array<Player>;
