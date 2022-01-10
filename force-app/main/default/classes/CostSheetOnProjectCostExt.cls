public without sharing class CostSheetOnProjectCostExt {

    public ID projectId { get; private set; }
    public String renderedContentType { get; private set; }
    public List<String> primaryAccountNameList {
        get {
            return CostSheetAsPdfExtensionHelper.getPrimaryAccountNames(
                projectId);
        }
    }

    public CostSheetOnProjectCostExt(ApexPages.StandardSetController controller) {
        this.ProjectId = Apexpages.currentPage().getParameters().get('id');
        renderedContentType = 'application/pdf#' + 'CostSheet.pdf';
    }
}
