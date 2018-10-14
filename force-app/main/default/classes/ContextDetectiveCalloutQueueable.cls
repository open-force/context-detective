/**
 * A Queueable that allows callouts.
 */
public with sharing class ContextDetectiveCalloutQueueable implements Queueable, Database.AllowsCallouts {

	private final String contextDescription;

	public ContextDetectiveCalloutQueueable(String contextDescription) {
		this.contextDescription = contextDescription;
	}

	public void execute(QueueableContext qc) {
		ContextDetective.dumpContext(contextDescription);
	}

}