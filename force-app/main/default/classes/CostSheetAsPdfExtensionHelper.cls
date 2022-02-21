public without sharing class CostSheetAsPdfExtensionHelper {

    public static final String PRIMARY_COSTS_TOTAL_ROW_NAME = '__SUBTOTAL__';
    public static final String SECONDARY_COSTS_TOTAL_ROW_NAME = '__SUBTOTAL__';
    public static final String ANY_COSTS_TOTAL_COLUMN_NAME = 'Total';
    public static final Decimal DEFAULT_COST_COLUMN_WIDTH = 13.0;
    public static final String OTHER_DIRECT_SECTION_NAME = 'Other';

    public class ProjectCostGroup {
        @AuraEnabled public String vendor;
        @AuraEnabled public String accountMain;
        @AuraEnabled public String accountExpense;
        @AuraEnabled public String costClass;
        @AuraEnabled public Date costDate;
        @AuraEnabled public String description;
        @AuraEnabled public Double amount;
    }

    public static Map<String, List<Decimal>> getPrimaryCosts(ID projectId,
        List<String> primaryAccountNameList) {
        
        Map<String, List<Decimal>> costMap = new Map<String, List<Decimal>> ();
        List<Decimal> defaultTotalAmountList = new List<Decimal> ();
        Integer costRowSize = primaryAccountNameList.size() + 1;
        Set<String> zeroCostLineNameSet = new Set<String> ();

        for (Integer i = 0; i < costRowSize; i++) {
            defaultTotalAmountList.add(0.0);
        }

        for (Project_Cost__c projectCost : [SELECT Amount__c, Class__r.Name,
                Account_Line__r.Name, Account_Line__r.Cost_Type__c
                FROM Project_Cost__c
                WHERE Related_Project__r.Id =: projectId
                AND Class__c != null AND Account_Line__c != null
                AND Account_Line__r.Cost_Type__c = 'Primary_Project_Cost']) {

            String accountName = projectCost.Account_Line__r.Name;
            String costClass = projectCost.Class__r.Name;
            Integer columnIdx = 0;
            columnIdx = primaryAccountNameList.indexOf(accountName);
            if (!costMap.containsKey(costClass)) {
                costMap.put(costClass, new List<Decimal> (defaultTotalAmountList));
            }
            costMap.get(costClass)[columnIdx] += projectCost.Amount__c;
            costMap.get(costClass)[costRowSize - 1] += projectCost.Amount__c;
        }

        for (String costClass : costMap.keySet()) {
            Decimal costLineTotal = costMap.get(costClass)[costRowSize - 1];
            if (costLineTotal == 0.0) zeroCostLineNameSet.add(costClass);
        }
        for (String costClass : zeroCostLineNameSet) {
            costMap.remove(costClass);
        }

        if (!costMap.isEmpty()) {
            costMap.put(PRIMARY_COSTS_TOTAL_ROW_NAME, defaultTotalAmountList);
        }
        for (String costClass : costMap.keySet()) {
            if (costClass == PRIMARY_COSTS_TOTAL_ROW_NAME) continue;
            for(Integer i = 0; i < costRowSize; i++) {
                costMap.get(PRIMARY_COSTS_TOTAL_ROW_NAME)[i]
                    += costMap.get(costClass)[i];
            }
        }

        return costMap;
    }

    public static Map<String, Decimal> getSecondaryCosts(ID projectId) {

        Map<String, Decimal> costMap = new Map<String, Decimal> ();
        Decimal totalAmount = 0.0;

        for (Project_Cost__c projectCost : [SELECT Amount__c,
                Account_Line__r.Name, Account_Line__r.Cost_Type__c,
                Account_Line__r.Display_Name_with_hierarchy__c
                FROM Project_Cost__c WHERE Related_Project__r.Id =: projectId
                AND Account_Line__c != null
                AND Account_Line__r.Cost_Type__c = 'Project_Cost']) {
            
            String accountName
                = projectCost.Account_Line__r.Display_Name_with_hierarchy__c;
            if (!costMap.containsKey(accountName)) {
                if (projectCost.Amount__c > 0.0) {
                    costMap.put(accountName, projectCost.Amount__c);
                }
            } else {
                costMap.put(accountName, costMap.get(accountName) 
                    + projectCost.Amount__c);
            }
        }
        for (String accountName : costMap.keySet()) {
            totalAmount += costMap.get(accountName);
        }
        if (!costMap.isEmpty()) {
            costMap.put(SECONDARY_COSTS_TOTAL_ROW_NAME, totalAmount);
        }
        return costMap;
    }

    public static List<String> getPrimaryAccountNames(ID projectId) {
        List<String> accountNames = new List<String> ();
        for (AggregateResult accountName : [SELECT Account_Line__r.Name
                FROM Project_Cost__c
                WHERE Related_Project__r.Id =: projectId
                AND Account_Line__c != null
                AND Account_Line__r.Cost_Type__c = 'Primary_Project_Cost'
                GROUP BY Account_Line__r.Name]) {
            accountNames.add((String) accountName.get('Name'));
        }
        accountNames.sort();
        return accountNames;
    }

    @AuraEnabled
    public static Map<String, List<ProjectCostGroup>> getProjectCostsRecords(ID projectId) {
        Map<String, List<ProjectCostGroup>> costMap = new Map<String, List<ProjectCostGroup>>();
        List<String> primaryAccountNames = getPrimaryAccountNames(projectId);
        List<Project_Cost__c> costList = [ SELECT Amount__c, Class__r.Name, Date__c,
            Description__c, Account_Line__r.Name, Account_Line__r.Cost_Type__c,
            Vendor__r.Name, Account_Main__r.Name
            FROM Project_Cost__c
            WHERE Related_Project__r.Id =: projectId
            AND Account_Line__c != null
            AND ((Account_Line__r.Cost_Type__c = 'Primary_Project_Cost' AND Class__c != null)
                OR Account_Line__r.Cost_Type__c = 'Project_Cost') ];
        if (costList == null || costList.isEmpty()) return costMap;
        if(!primaryAccountNames.isEmpty()) {
            for(String accountName : primaryAccountNames) {
                costMap.put(accountName, new List<ProjectCostGroup>());
            }
        }
        for(Project_Cost__c cost : costList) {
            ProjectCostGroup costGroup = new ProjectCostGroup ();
            costGroup.vendor = cost.Vendor__r.Name;
            costGroup.accountMain = cost.Account_Main__r.Name;
            costGroup.accountExpense = cost.Account_Line__r.Name;
            costGroup.costClass = cost.Class__r.Name;
            costGroup.costDate = cost.Date__c;
            costGroup.amount = cost.Amount__c;
            costGroup.description = cost.Description__c;
            if(cost.Account_Line__r.Cost_Type__c == 'Primary_Project_Cost') {
                costMap.get(cost.Account_Line__r.Name).add(costGroup);
            } else {
                if (!costMap.containsKey(OTHER_DIRECT_SECTION_NAME)) {
                    costMap.put(OTHER_DIRECT_SECTION_NAME, new List<ProjectCostGroup>());
                }
                costMap.get(OTHER_DIRECT_SECTION_NAME).add(costGroup);
            }
        }
        return costMap;
    }
}
