/**
 * I had to split Queueable testing out into a new class because I kept getting this error at runtime:
 *
 * System.AsyncException: Queueable cannot be implemented with other system interfaces.
 */
public with sharing class ContextDetectiveQueueable implements Queueable {

	private final String contextDescription;

	public ContextDetectiveQueueable(String contextDescription) {
		this.contextDescription = contextDescription;
	}

	public void execute(QueueableContext qc) {
		ContextDetective.dumpContext(contextDescription);
	}

}