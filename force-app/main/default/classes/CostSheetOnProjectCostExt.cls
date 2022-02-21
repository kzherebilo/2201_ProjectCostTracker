public without sharing class CostSheetOnProjectCostExt {

    public Project__c project { get; private set; }
    public String documentTitle {
        get {
            return 'Project Cost Summary';
        }
    }

    public CostSheetOnProjectCostExt(ApexPages.StandardSetController controller) {
        ID projectId = Apexpages.currentPage().getParameters().get('id');
        this.project = [SELECT Id, Name
            FROM Project__c 
            WHERE Id =: projectId LIMIT 1];
        String generatedFilename = this.project.Name
            + ' - ' + documentTitle + '.pdf';
        Apexpages.currentPage().getHeaders().put(
            'content-disposition', 'inline; filename=' + generatedFilename);
    }
}
