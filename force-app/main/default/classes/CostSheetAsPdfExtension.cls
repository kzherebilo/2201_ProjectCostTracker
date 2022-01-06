public without sharing class CostSheetAsPdfExtension {

/********************************* CONSTANTS **********************************/
    @TestVisible
    private final String RENDERED_FILENAME;
    @TestVisible
    private final ID PROJECT_ID;
    @TestVisible
    private final List<String> PRIMARY_ACCOUNT_NAME_LIST;
    @TestVisible
    private final Map<String, List<Decimal>> PRIMARY_COSTS;
    @TestVisible
    private final Map<String, Decimal> SECONDARY_COSTS;


/******************************** PROPERTIES **********************************/    
    public String renderedContentType { get; private set; }
    public Map<String, List<Decimal>> primaryCosts {
        get {
            return this.PRIMARY_COSTS;
        }
    }
    public Integer primaryCostsLastCellIdx {
        get {
            // The index of the last cell is equal to the size of initial
            // account list because we add additional column for totals in the
            // CostSheetAsPdfExtensionHelper.getPrimaryCosts method
            return PRIMARY_ACCOUNT_NAME_LIST.size();
        }
    }
    public String primaryCostsCellWidth {
        get {
            return String.valueOf(55 / (primaryCostsLastCellIdx + 1)) + '%';
        }
    }
    public String primaryCostsTotalRowName {
        get {
            return CostSheetAsPdfExtensionHelper.PRIMARY_COSTS_TOTAL_ROW_NAME;
        }
    }
    public List<String> primaryCostsHeaderList {
        get {
            List<String> tableHeader;
            tableHeader = new List<String> (this.PRIMARY_ACCOUNT_NAME_LIST);
            tableHeader.add(
                CostSheetAsPdfExtensionHelper.ANY_COSTS_TOTAL_COLUMN_NAME);
            return tableHeader;
        }
    }
    public Map<String, Decimal> secondaryCosts {
        get {
            return this.SECONDARY_COSTS;
        }
    }
    public String secondaryCostsTotalRowName {
        get {
            return CostSheetAsPdfExtensionHelper.SECONDARY_COSTS_TOTAL_ROW_NAME;
        }
    }
    public Decimal overallTotal {
        get {
            Decimal totalAmount = 0.0;
            if (!this.PRIMARY_COSTS.isEmpty()) {
                totalAmount += this.PRIMARY_COSTS.get(primaryCostsTotalRowName)[
                    primaryCostsLastCellIdx];
            }
            if (!this.SECONDARY_COSTS.isEmpty()) {
                totalAmount += this.SECONDARY_COSTS.get(
                    secondaryCostsTotalRowName);
            }
            return totalAmount;
        }
    }
    public Boolean isEmptyTable {
        get {
            return !(this.PRIMARY_COSTS.isEmpty()
                || this.SECONDARY_COSTS.isEmpty());
        }
    }
    public String emptyTableMessage {
        get {
            return 'NO PROJECT COST FOUND';
        }
    }

/********************************** FIELDS ************************************/




/******************************** CONSTRUCTOR *********************************/
    public CostSheetAsPdfExtension(ApexPages.StandardController controller) {
        this.PROJECT_ID = (ID) controller.getRecord().Id;
        this.RENDERED_FILENAME = 'Cost-Sheet.pdf';
        this.PRIMARY_ACCOUNT_NAME_LIST
            = CostSheetAsPdfExtensionHelper.getPrimaryAccountNames(PROJECT_ID);
        this.PRIMARY_COSTS = CostSheetAsPdfExtensionHelper.getPrimaryCosts(
            this.PROJECT_ID, this.PRIMARY_ACCOUNT_NAME_LIST);
        this.SECONDARY_COSTS = CostSheetAsPdfExtensionHelper.getSecondaryCosts(
            this.PROJECT_ID);
        // Add a file name for the PDF file
        // This is supposed to set the file name, but it doesn't work
        renderedContentType = 'application/pdf#' + this.RENDERED_FILENAME;
        // This is a work-around to set the file name
        // ApexPages.currentPage().getHeaders().put('content-disposition',
        //     'attachment; filename=' + this.RENDERED_FILENAME);
    }

/********************************** METHODS ***********************************/

}