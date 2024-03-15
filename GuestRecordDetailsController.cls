public without sharing class GuestRecordDetailsController {

    @AuraEnabled(cacheable=true)
    public static Account getAccountDetailsById(String recordId) {
        try {
            // Query the Account details based on the provided recordId
            return [SELECT Id, First_Name__c, Last_Name__c, Phone, Email__c,
            Shoes_size__c,T_shirt_size__c,Date_of_Birth__c
                    FROM Account
                    WHERE Id = :recordId
                    LIMIT 1];
        } catch (Exception e) {
            // Handle any exceptions gracefully
            throw new AuraHandledException('Error fetching account details: ' + e.getMessage());
        }
    }


    @AuraEnabled
    public static void updateAccountRecord(String accountId, Map<String, Object> fieldsToUpdate, Boolean isProfileCompleted) {
        try {
            // Create a new Account record with the provided Id
            Account acc = new Account(Id = accountId);

            // Loop through the fieldsToUpdate map and set the corresponding field values
            for (String fieldName : fieldsToUpdate.keySet()) {
                // Ensure that the value is of the correct type before assigning
                if (fieldName == 'Date_of_Birth__c') {
                acc.put(fieldName, Date.valueOf(String.valueOf(fieldsToUpdate.get(fieldName))));
            } else if (fieldName == 'Shoes_size__c') {
                acc.put(fieldName, Decimal.valueOf(String.valueOf(fieldsToUpdate.get(fieldName))));
            } else {
                acc.put(fieldName, fieldsToUpdate.get(fieldName));
            }
        }

            // Update the Account record
            update acc;

            if (isProfileCompleted) {
            acc.Profile_Completed__c = true;
            update acc;
        }
        } catch (Exception e) {
            // Handle any exceptions gracefully
            throw new AuraHandledException('Error updating account: ' + e.getMessage());
        }
    }
}