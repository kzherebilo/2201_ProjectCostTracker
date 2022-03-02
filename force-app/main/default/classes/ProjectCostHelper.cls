public without sharing class ProjectCostHelper {

/********************************** CONSTANTS *********************************/

    public static final String PRIMARY_COSTS_TOTAL_ROW_NAME = '__SUBTOTAL__';
    public static final String SECONDARY_COSTS_TOTAL_ROW_NAME = '__SUBTOTAL__';
    public static final String ANY_COSTS_TOTAL_COLUMN_NAME = 'Total';
    public static final Decimal DEFAULT_COST_COLUMN_WIDTH = 13.0;
    public static final String OTHER_DIRECT_SECTION_NAME = 'Other';

/************************ PROJECT COST SUMMARY METHODS ************************/

    @AuraEnabled
    public static Map<String, List<Decimal>> getPrimaryCosts(ID projectId,
        List<String> primaryAccountNameList) {
        
        Map<String, List<Decimal>> costMap = new Map<String, List<Decimal>> ();
        List<Decimal> defaultTotalAmountList = new List<Decimal> ();
        Integer costRowSize = primaryAccountNameList.size() + 1;
        Set<String> zeroCostLineNameSet = new Set<String> ();
        List<Project_Cost__c> costList = [
            SELECT Amount__c,
                    Classification__r.Name,
                    Account_Expense__r.Name
            FROM Project_Cost__c
            WHERE Related_Project__r.Id =: projectId
                AND Account_Expense__c != null
                AND Account_Expense__r.Cost_Type__c = 'Primary Project Cost'
            ORDER BY Classification__r.Name ASC NULLS LAST
        ];
        if (costList == null || costList.isEmpty()) return costMap;

        for (Integer i = 0; i < costRowSize; i++) {
            defaultTotalAmountList.add(0.0);
        }

        for (Project_Cost__c projectCost : costList) {
            String accountName = projectCost.Account_Expense__r.Name;
            String costClass = projectCost.Classification__r.Name;
            costClass = String.isBlank(costClass) 
                ? 'Unclassified'
                : projectCost.Classification__r.Name;
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

    @AuraEnabled
    public static Map<String, Decimal> getSecondaryCosts(ID projectId) {

        Map<String, Decimal> costMap = new Map<String, Decimal> ();
        Decimal totalAmount = 0.0;
        List<Project_Cost__c> costList = [
            SELECT Amount__c,
                   Account_Expense__r.Name,
                   Account_Expense__r.Display_Name_with_hierarchy__c
            FROM Project_Cost__c
            WHERE Related_Project__r.Id =: projectId
                AND Account_Expense__c != null
                AND Account_Expense__r.Cost_Type__c = 'Project Cost'
        ];
        if (costList == null || costList.isEmpty()) return costMap;

        for (Project_Cost__c projectCost : costList) {
            String accountName
                = projectCost.Account_Expense__r.Name;
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

    @AuraEnabled
    public static List<String> getPrimaryAccountNames(ID projectId) {
        List<String> accountNames = new List<String> ();
        for (AggregateResult accountName : [SELECT Account_Expense__r.Name
                FROM Project_Cost__c
                WHERE Related_Project__r.Id =: projectId
                AND Account_Expense__c != null
                AND Amount__c != 0.0
                AND Account_Expense__r.Cost_Type__c = 'Primary Project Cost'
                GROUP BY Account_Expense__r.Name]) {
            accountNames.add((String) accountName.get('Name'));
        }
        accountNames.sort();
        return accountNames;
    }

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/
/*                                                                            */
/*                           LWC RELATED METHODS                              */
/*                                                                            */
/******************************************************************************/

    @AuraEnabled
    public static Map<String, List<ProjectCostWrapper>> getProjectCostsRecords(
            ID projectId) {

        Map<String, List<ProjectCostWrapper>> costMap;
        List<Project_Cost__c> costList = [
            SELECT Date__c,
                    Amount__c,
                    Memo__c,
                    Classification__r.Name,
                    Account_Main__r.Name,
                    Account_Expense__r.Name,
                    Account_Expense__r.Cost_Type__c,
                    Vendor__c,
                    Vendor__r.Name
            FROM Project_Cost__c
            WHERE Related_Project__r.Id =: projectId
                AND Account_Expense__c != null
                AND (Account_Expense__r.Cost_Type__c = 'Primary Project Cost'
                    OR Account_Expense__r.Cost_Type__c = 'Project Cost')
            ORDER BY Account_Expense__r.Cost_Type__c ASC
        ];
        // Guards
        if (costList == null || costList.isEmpty()) return costMap;
        // Initialize Project Cost Map
        costMap = new Map<String, List<ProjectCostWrapper>>();
        // Populate Project Cost Map with Project_Cost__c records; each record
        // is wrapped in an instance of ProjectCostWrapper class, because
        // complex relationship fields with dot-notation are not allowed in
        // LWC Datatable component
        for(Project_Cost__c cost : costList) {
            ProjectCostWrapper costWrapper = new ProjectCostWrapper ();
            costWrapper.vendorUrl 
                = cost.Vendor__c != null ? '/' + cost.Vendor__c : null;
            costWrapper.vendorName = cost.Vendor__r.Name;
            costWrapper.accountMain = cost.Account_Main__r.Name;
            costWrapper.accountExpense = cost.Account_Expense__r.Name;
            costWrapper.costClass = cost.Classification__r.Name;
            costWrapper.costDate = cost.Date__c;
            costWrapper.amount = cost.Amount__c;
            costWrapper.description = cost.Memo__c;
            if(cost.Account_Expense__r.Cost_Type__c == 'Primary Project Cost') {
                if (!costMap.containsKey(cost.Account_Expense__r.Name)) {
                    costMap.put(cost.Account_Expense__r.Name,
                        new List<ProjectCostWrapper>());
                }
                costMap.get(cost.Account_Expense__r.Name).add(costWrapper);
            } else {
                if (!costMap.containsKey(OTHER_DIRECT_SECTION_NAME)) {
                    costMap.put(OTHER_DIRECT_SECTION_NAME,
                        new List<ProjectCostWrapper>());
                }
                costMap.get(OTHER_DIRECT_SECTION_NAME).add(costWrapper);
            }
        }
        return costMap;
    }

    @AuraEnabled
    public static Map<String, String> getProjectCostConstants() {
        Map<String, String> constantMap = new Map<String, String> ();
        constantMap.put('PRIMARY_COSTS_TOTAL_ROW_NAME',
            PRIMARY_COSTS_TOTAL_ROW_NAME);
        constantMap.put('SECONDARY_COSTS_TOTAL_ROW_NAME',
            SECONDARY_COSTS_TOTAL_ROW_NAME);
        constantMap.put('ANY_COSTS_TOTAL_COLUMN_NAME',
            ANY_COSTS_TOTAL_COLUMN_NAME);
        return constantMap;
    }


/******************************************************************************/
/*                                                                            */
/*                        LWC RELATED INNER CLASSES                           */
/*                                                                            */
/******************************************************************************/
    
    public class ProjectCostWrapper {
        @AuraEnabled public String vendorUrl;
        @AuraEnabled public String vendorName;
        @AuraEnabled public String accountMain;
        @AuraEnabled public String accountExpense;
        @AuraEnabled public String costClass;
        @AuraEnabled public Date costDate;
        @AuraEnabled public String description;
        @AuraEnabled public Double amount;
    }

}