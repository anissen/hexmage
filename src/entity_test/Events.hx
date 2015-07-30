package ;

enum Action {
    EndTurn;
    Effect(entity :Entity, tags :Tags);
}
typedef Actions = Array<Action>;

enum Event {
    TurnEnded(playerId :Int);
    TurnStarted(playerId :Int);
    EffectTriggered(entity :Entity, tags :Tags);
}
typedef Events = Array<Event>;
