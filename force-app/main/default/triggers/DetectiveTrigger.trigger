/**
 * Faciliates testing limits in various contexts.
 */
trigger DetectiveTrigger on Account (before insert, before update) {

	ContextDetective.dumpContext('Normal trigger');
}