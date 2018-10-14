# Context Detective #

This is a simple bit of Apex, paired with a custom object, that will help you explore the various limits that are applied by Salesforce in different execution contexts where Apex can run.

The main thing we're trying to surface with this is figuring out when Apex is running in a "synchronous" context vs an "asynchronous" context, which is not as intuitive as you might hope.

## Sample Results ##

![Here are the standard contexts the ContextDetective will expose](/data/contexts.png)

## Building the DX Project ##

By default this repo is set up as DX project for you to run ContextDetective in a scratch org. Clone this repo to your local machine and then execute the following build script from the repository root folder:

`./build`

This build script is a convenience, and will run the following commands in sequence:

1. `sfdx force:org:create -s -f config/context-detective-scratch-def.json -a 'context-detective'`
2. `sfdx force:source:push`
3. `sfdx force:user:permset:assign -n Context_Detective`
4. `sfdx force:apex:execute -f investigate.apex`
5. `sfdx force:org:open -p lightning/o/Context__c/list?filterName=All`

This will cause a number of Context__c records to be created, which you can inspect to gain insight into what limits are applied where.

If there are additional contexts you'd like to investigate, from your Apex inside those contexts simply call `ContextDetective.dumpContext('Some Description of your Context');`.

*Keep in mind that some of the contexts that are checked are scheduled and will take a minute or two to execute, so you will likely need to refresh the Context__c list view until the scheduled stuff appears.*
