/**
 * An inquisitive little class hell-bent on exploring various Apex contexts and the related limits of those contexts.
 */
@RestResource(UrlMapping='/context-detective')
global with sharing class ContextDetective implements Schedulable, Database.Batchable<Object> {

	private final String contextDescription;

	public ContextDetective(String contextDescription) {
		this.contextDescription = contextDescription;
	}

	/**
	 * Kick off a bunch of different permutations of how Apex can be invoked so we can log them.
	 */
	public static void investigate(String description) {

		// call the Apex REST endpoint
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/context-detective');
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
		h.send(req);

		// run a batch
		Database.executeBatch(new ContextDetective('Batchable'));

		// run a queueable
		System.enqueueJob(new ContextDetectiveQueueable('Queueable'));

		// schedule this class
		Datetime nextRun = System.now().addMinutes(1);
		String cron = '0 ' + nextRun.minute() + ' ' + nextRun.hour() + ' ' + nextRun.day() + ' ' + nextRun.month() + ' ? ' + nextRun.year();
		System.schedule('ContextDetective Scheduled', cron, new ContextDetective('Scheduled'));

		// schedule a batch
		System.scheduleBatch(new ContextDetective('ScheduledBatch'), 'ContextDetective ScheduledBatch', 1);

		// call a future
		future();

		// fire a platform event
		EventBus.publish(new Sidekick__e());

		// dump the context we were called from
		dumpContext(description);
	}

	@Future
	public static void future() {
		dumpContext('Future');
	}

	public void execute(SchedulableContext sc) {
		dumpContext('Scheduled');

		// kill the scheduled job
		CronTrigger existingJob = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'ContextDetective Scheduled' LIMIT 1];
		if(existingJob != null)
			System.abortJob(existingJob.Id);
	}

	public Iterable<Object> start(Database.BatchableContext bc) {
		dumpContext(contextDescription + '.start()');
		return new List<Object>{1, 2, 3};
	}

	public void execute(Database.BatchableContext bc, List<Object> records) {
		dumpContext(contextDescription + '.execute()');

		System.enqueueJob(new ContextDetectiveQueueable('Queueable from inside a Batch'));
	}

	public void finish(Database.BatchableContext bc) {
		dumpContext(contextDescription + '.finish()');
	}

	@HttpGet
	global static void httpGet() {
		dumpContext('Apex REST');
	}

	/**
	 * Write a dump of the current limits to an instance of our Context custom object. Use a descriptive name to describe
	 * the current context you're calling from, something like "Inside Chained Queueable", etc.
	 *
	 * @param contextDescription
	 */
	public static void dumpContext(String contextDescription) {

		// we use the description as a unique identifier so we avoid dupes in the table
		upsert new Context__c(
			Name = contextDescription,
			Batch__c = System.isBatch(),
			Future__c = System.isFuture(),
			Queueable__c = System.isQueueable(),
			Scheduled__c = System.isScheduled(),
			AggregateQueries__c = Limits.getLimitAggregateQueries(),
			Callouts__c = Limits.getLimitCallouts(),
			CpuTime__c = Limits.getLimitCpuTime(),
			DMLRows__c = Limits.getLimitDmlRows(),
			DMLStatements__c = Limits.getLimitDmlStatements(),
			EmailInvocations__c = Limits.getLimitEmailInvocations(),
			FutureCalls__c = Limits.getLimitFutureCalls(),
			HeapSize__c = Limits.getLimitHeapSize(),
			MobilePushApexCalls__c = Limits.getLimitMobilePushApexCalls(),
			Queries__c = Limits.getLimitQueries(),
			QueryLocatorRows__c = Limits.getLimitQueryLocatorRows(),
			QueryRows__c = Limits.getLimitQueryRows(),
			QueueableJobs__c = Limits.getLimitQueueableJobs(),
			SoslQueries__c = Limits.getLimitSoslQueries()
		) Context__c.Name;
	}
}