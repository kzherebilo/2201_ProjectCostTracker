@isTest
private class ProjectCostSummaryTest {
    
    @isTest 
    private static void projectCostSummary_Test() {

        ProjectCostDataFactory.setupTestData();
        Id projectId = [SELECT Id FROM Project__c LIMIT 1].Id;
        List<Project_Cost__c> projectCostList 
            = [SELECT Id FROM Project_Cost__c];
        
        Test.startTest();
        PageReference pageRef = Page.ProjectCostSummary;
        pageRef.getParameters().put('id', String.valueOf(projectId));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController stdSetController
            = new ApexPages.StandardSetController(projectCostList);
        stdSetController.setSelected(projectCostList);
        ProjectCostSummaryExtension controller
            = new ProjectCostSummaryExtension(stdSetController);
        System.assertEquals(controller.project.Id, projectId);
        CostSheetTable componentController = new CostSheetTable();
        componentController.setProjectId(projectId);
        System.assertEquals(componentController.getProjectId(), projectId);
        System.debug('PRIMARY COSTS MAP: '
            + componentController.primaryCosts);
        System.debug('PRIMARY COSTS LAST CELL IDX: '
            + componentController.primaryCostsLastCellIdx);
        System.debug('PRIMARY COSTS CELL WIDTH: '
            + componentController.primaryCostsCellWidth);
        System.assertEquals(componentController.primaryCostsTotalRowName,
            ProjectCostHelper.PRIMARY_COSTS_TOTAL_ROW_NAME);
        System.debug('PRIMARY COSTS HEADER: '
            + componentController.primaryCostsHeaderList);
        System.debug('SECONDARY COSTS MAP: '
            + componentController.secondaryCosts);
        System.debug('SECONDARY COSTS TOTAL LABEL: '
            + componentController.secondaryCostsTotalRowName);
        System.debug('OVERALL TOTAL AMOUNT: '
            + componentController.overallTotal);
        System.debug('EMPTY TABLE FLAG: '
            + componentController.isEmptyTable);
        System.debug('EMPTY TABLE MESSAGE: '
            + componentController.emptyTableMessage);
        System.debug('PRIMARY ACCOUNT NAMES: '
            + componentController.primaryAccountNames);
        Test.stopTest();
    }
}
