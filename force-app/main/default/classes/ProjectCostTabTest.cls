@isTest
private class ProjectCostTabTest {

    @isTest
    private static void projectCostTab_Test() {
        ProjectCostDataFactory.setupTestData();
        Id projectId = [SELECT Id FROM Project__c LIMIT 1].Id;
        Map<String, List<ProjectCostHelper.ProjectCostWrapper>> costMap
            = ProjectCostHelper.getProjectCostsRecords(projectId);
        System.assert(costMap.size() > 0);
        System.debug(costMap.keySet());
    }
}
