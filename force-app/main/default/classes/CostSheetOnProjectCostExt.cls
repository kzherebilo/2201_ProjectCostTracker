public without sharing class CostSheetOnProjectCostExt {

    public Project__c project { get; private set; }
    public String renderedContentType { get; private set; }

    public CostSheetOnProjectCostExt(ApexPages.StandardSetController controller) {
        ID projectId = Apexpages.currentPage().getParameters().get('id');
        this.project = [SELECT Id, Name
            FROM Project__c 
            WHERE Id =: projectId LIMIT 1];
        renderedContentType = 'application/pdf#' + 'CostSheet.pdf';
    }
}
