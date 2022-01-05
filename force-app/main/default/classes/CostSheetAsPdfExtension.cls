public without sharing class CostSheetAsPdfExtension {

/********************************* CONSTANTS **********************************/
    public final String RENDERED_FILENAME;
    @TestVisible
    private final ID PROJECT_ID;
    private final List<String> PRIMARY_ACCOUNT_NAME_LIST;

/******************************** PROPERTIES **********************************/    
    public String renderedContentType { get; private set; }
    public Map<String, List<Decimal>> primaryCosts {
        get {
            Map<String, List<Decimal>> costMap 
                = CostSheetAsPdfExtensionHelper.getPrimaryCosts(
                PROJECT_ID, PRIMARY_ACCOUNT_NAME_LIST);
            // Map<String, List<Decimal>> costMap = new Map<String, List<Decimal>> {
            //     'Appliance' => new List<Decimal> { 0.0, 1236.01, 0.0 },
            //     'Demolition/Preservation' => new List<Decimal> {0.0, 0.0, 2500.00},
            //     'Driveway/Landscaping' => new List<Decimal> {0.0, 0.0, 1536.32},
            //     'Electrical' => new List<Decimal> {0.0, 0.0, 152.26}
            // };

            this.numberOfPrimaryLines = costMap.size();
            return costMap;
        }
    }
    public Integer numberOfDataColumns {
        get {
            return PRIMARY_ACCOUNT_NAME_LIST.size();
        }
    }
    public Integer numberOfPrimaryLines { get; private set; }
    public List<Project_Cost__c> projectCostList {
        get {
            return CostSheetAsPdfExtensionHelper.getProjectCosts(PROJECT_ID);
        }
    }

/********************************** FIELDS ************************************/




/******************************** CONSTRACTOR *********************************/
    public CostSheetAsPdfExtension(ApexPages.StandardController controller) {
        this.PROJECT_ID = (ID) controller.getRecord().Id;
        this.RENDERED_FILENAME = 'Cost-Sheet.pdf'; 
        this.PRIMARY_ACCOUNT_NAME_LIST = new List<String> {
            'Labor', 'Materials', 'Paid on Contract'
        };
        // Add a file name for the PDF file
        // This is supposed to set the file name, but it doesn't work
        renderedContentType = 'application/pdf#' + this.RENDERED_FILENAME;
        // This is a work-around to set the file name
        // ApexPages.currentPage().getHeaders().put('content-disposition',
        //     'attachment; filename=' + this.RENDERED_FILENAME);
    }

/********************************** METHODS ***********************************/

}