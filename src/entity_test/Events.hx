package ;

enum Action {
    EndTurn;
    Effect(entity :Entity, tags :TagMap);
}
typedef Actions = Array<Action>;

enum Event {
    TurnEnded(playerId :Int);
    TurnStarted(playerId :Int);
    // EffectTriggered(entity :Entity, tag :Tag, value :Int);
    EffectTriggered(entity :Entity, tags :TagMap);
}
typedef Events = Array<Event>;
