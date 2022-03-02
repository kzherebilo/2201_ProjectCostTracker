public without sharing class ProjectCostSummaryExtension {

/******************************** PROPERTIES **********************************/

    public Project__c project { get; private set; }
    public Boolean isDetailedViewEnabled { get; private set; }
    public String documentTitle {
        get {
            return 'Project Cost Summary';
        }
    }


/******************************* CONSTRUCTORS *********************************/

    public ProjectCostSummaryExtension(
                ApexPages.StandardSetController controller) {

        Map<String, String> parameters;
        parameters = Apexpages.currentPage().getParameters();
        this.isDetailedViewEnabled = Boolean.valueOf(parameters.get('details'));
        this.project = [SELECT Id, Name FROM Project__c
            WHERE Id =: parameters.get('id') LIMIT 1];
        String generatedFilename = this.project.Name
            + ' - ' + documentTitle + '.pdf';
        Apexpages.currentPage().getHeaders().put(
            'content-disposition', 'inline; filename=' + generatedFilename);
    }
}
