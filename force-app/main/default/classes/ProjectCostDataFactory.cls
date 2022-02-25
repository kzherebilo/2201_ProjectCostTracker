@isTest
public class ProjectCostDataFactory {

    public static void setupTestData() {

        Vendor__c vendor = new Vendor__c();
        Project__c project = new Project__c();
        Account__c accountMain = new Account__c();
        Classification__c costClass = new Classification__c();
        List<Account__c> accountLineList = new List<Account__c>();
        List<Project_Cost__c> projectCostList = new List<Project_Cost__c>();
        
        insert project;
        
        vendor.Name = 'Test Vendor';
        insert vendor;
        
        costClass.Name = 'General';
        insert costClass;
        
        accountMain.Name = 'Test Account Main';
        accountMain.Cost_Type__c = 'Other';
        insert accountMain;
        
        accountLineList.add(new Account__c(
            Name = 'Primary Project Cost Account Test',
            Cost_Type__c = 'Primary Project Cost'
        ));
        accountLineList.add(new Account__c(
            Name = 'Secondary Project Cost Account Test',
            Cost_Type__c = 'Project Cost'
        ));
        insert accountLineList;

        projectCostList.add(new Project_Cost__c(
            Related_Project__c = project.Id,
            Account_Main__c = accountMain.Id,
            Account_Expense__c = accountLineList[0].Id,
            Vendor__c = vendor.Id,
            Date__c = Date.today(),
            Amount__c = 1.0,
            Memo__c = 'Test Project Cost',
            Classification__c = costClass.Id
        ));
        projectCostList.add(new Project_Cost__c(
            Related_Project__c = project.Id,
            Account_Main__c = accountMain.Id,
            Account_Expense__c = accountLineList[1].Id,
            Vendor__c = vendor.Id,
            Date__c = Date.today(),
            Amount__c = 1.0,
            Memo__c = 'Test Project Cost'
        ));
        insert projectCostList;
    }
}