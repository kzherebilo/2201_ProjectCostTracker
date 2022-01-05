public without sharing class CostSheetAsPdfExtensionHelper {

    public static Map<String, List<Decimal>> getPrimaryCosts(ID projectId,
        List<String> primaryAccountNameList) {
        
        Map<String, List<Decimal>> costMap = new Map<String, List<Decimal>> ();
        List<Decimal> defaultTotalAmountList = new List<Decimal> ();
        Integer costRowSize = primaryAccountNameList.size();

        for (Integer i = 0; i < costRowSize; i++) {
            defaultTotalAmountList.add(0.0);
        }

        for (Project_Cost__c projectCost : [SELECT Amount__c, Class__r.Name,
                Account_Line__r.Name, Account_Line__r.Category__c,
                Account_Line__r.Display_Name_with_hierarchy__c
                FROM Project_Cost__c
                WHERE Related_Project__r.Id =: projectId
                AND Class__c != null AND Account_Line__c != null
                AND (Account_Line__r.Category__c = 'Primary'
                OR Account_Line__r.Category__c = 'Secondary')]) {

            String accountCategory = projectCost.Account_Line__r.Category__c;
            String accountName = projectCost.Account_Line__r.Name;
            String costClass = projectCost.Class__r.Name;
            Integer columnIdx = 0;
            if (accountCategory == 'Primary'
                    && primaryAccountNameList.contains(accountName)) {
                columnIdx = primaryAccountNameList.indexOf(accountName);
                if (!costMap.containsKey(costClass)) {
                    costMap.put(costClass, new List<Decimal> (defaultTotalAmountList));
                }
                costMap.get(costClass)[columnIdx] += projectCost.Amount__c;
                // costMap.get(costClass)[costRowSize - 1] += projectCost.Amount__c;
            }
            // if (projectCost.Account_Line__r.Category__c == 'Secondary') {
                
            // }
        }

        return costMap;
    }

    public static List<Project_Cost__c> getProjectCosts(ID projectId) {
        return [SELECT Amount__c, Class__r.Name,
            Account_Line__r.Name, Account_Line__r.Category__c,
            Account_Line__r.Display_Name_with_hierarchy__c
            FROM Project_Cost__c
            WHERE Related_Project__r.Id =: projectId
            AND Class__c != null AND Account_Line__c != null
            AND (Account_Line__r.Category__c = 'Primary'
            OR Account_Line__r.Category__c = 'Secondary')];
    }
}
