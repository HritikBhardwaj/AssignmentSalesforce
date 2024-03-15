trigger AccountTrigger on Account (after update) {
    // Trigger handler
    if (Trigger.isAfter && Trigger.isUpdate) {
        Set<Id> updatedAccountIds = new Set<Id>();

        // Collecting the Ids of Accounts where the profile_completed__c has been updated to true
        for (Account updatedAccount : Trigger.new) {
            Account oldAccount = Trigger.oldMap.get(updatedAccount.Id);
            if (updatedAccount.profile_completed__c && !oldAccount.profile_completed__c) {
                updatedAccountIds.add(updatedAccount.Id);
            }
        }

        // Perform callout asynchronously for the updated accounts
        if (!updatedAccountIds.isEmpty()) {
            AccountTriggerHandler.performCalloutAsync(updatedAccountIds);
            System.debug('Accounts with Profile Completed updated: ' + updatedAccountIds);
        }
    }
}