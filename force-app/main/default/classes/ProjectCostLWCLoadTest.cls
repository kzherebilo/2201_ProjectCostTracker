//@isTest(SeeAllData = true)
public class ProjectCostLWCLoad_Test {

    //@isTest
    public static void setupData() {
        System.savepoint sp = Database.setSavepoint();
        try {
            Account__c accountMain = [SELECT Id FROM Account__c
                WHERE Name = 'Accounts Payable' LIMIT 1];
            Vendor__c vendor = [SELECT Id FROM Vendor__c LIMIT 1];
            List<Account__c> accountLineList = new List<Account__c>();
            accountLineList.add([SELECT Id FROM Account__c
                WHERE Name = 'Materials' AND Cost_Type__c = 'Primary_Project_Cost'
                LIMIT 1]);
            accountLineList.add([SELECT Id FROM Account__c
                WHERE Name = 'Paid On Contract' AND Cost_Type__c = 'Primary_Project_Cost'
                LIMIT 1]);
            accountLineList.add([SELECT Id FROM Account__c
                WHERE Name = 'Labor' AND Cost_Type__c = 'Primary_Project_Cost'
                LIMIT 1]);
            accountLineList.add([SELECT Id FROM Account__c
                WHERE Cost_Type__c = 'Project_Cost'
                LIMIT 1]);
            List<Classification__c> costClassList = [SELECT Id FROM Classification__c];
            Project__c project = new Project__c();
            insert project;
            
            List<Project_Cost__c> projectCostList = new List<Project_Cost__c> ();
            for(Integer i = 0; i < 1000; i++) {
                Project_Cost__c projectCost = new Project_Cost__c();
                projectCost.Related_Project__c = project.Id;
                projectCost.Account_Main__c = accountMain.Id;
                projectCost.Account_Line__c 
                    = accountLineList[Math.mod(i, accountLineList.size())].Id;
                projectCost.Vendor__c = vendor.Id;
                projectCost.Date__c = Date.today();
                projectCost.Amount__c = 100.0;
                projectCost.Description__c
                    = 'Test Record. To be deleted upon load testing';
                projectCost.Class__c
                    = costClassList[Math.mod(i, costClassList.size())].Id;
                projectCostList.add(projectCost);
            }
            insert projectCostList;            
            projectCostList = [SELECT Id FROM Project_Cost__c
                WHERE Related_Project__c =: project.Id ];
        }
        catch (Exception e) {
            Database.rollback(sp);
        }
    }
}