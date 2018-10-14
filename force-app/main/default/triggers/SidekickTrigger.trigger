trigger SidekickTrigger on Sidekick__e (after insert) {
    ContextDetective.dumpContext('Platform Event trigger');
}