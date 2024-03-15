public class AccountTriggerHandler {
    // Method to perform the callout asynchronously
    @future(callout=true)
    public static void performCalloutAsync(Set<Id> accountIds) {
        List<Account> accountsToUpdate = new List<Account>();

        for (Account acc : [SELECT Id, Email__c, T_shirt_size__c, Shoes_size__c FROM Account WHERE Id IN :accountIds AND profile_completed__c = true]) {
            // Constructing the JSON payload
            String jsonPayload = '{"email":"' + acc.Email__c + '","tshirtSize":"' + acc.T_shirt_size__c + '","shoeSize":' + acc.Shoes_size__c + '}';

            // Making the POST request
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://integrations.commutatus.com/webhook/719ce78d-c2c5-47a8-986a-39d7e7a5652d');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(jsonPayload);

            Http http = new Http();
            HttpResponse res = http.send(req);

            // Check if the callout was successful
            if (res.getStatusCode() == 200) {
                system.debug('response' +res.getbody());
                ResponseData responseData = (ResponseData)JSON.deserialize(res.getbody(), ResponseData.class);
                if(responseData != null){
                    acc.Loyalty_Customer_ID__c = responseData.customer_id;
                    accountsToUpdate.add(acc);
                    
                }
                
                // Update the Loyalty_Customer_ID__c field with the Account Id
                
            }
        }

        // Update the accounts
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
            System.debug('Updated Accounts: ' + accountsToUpdate);
        }
    }
    
    public class ResponseData {
    public String status;
    public String customer_id;
}
}