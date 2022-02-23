public without sharing class CostSheetTable {

/********************************* CONSTANTS **********************************/
    @TestVisible
    private ID PROJECT_ID;
    @TestVisible
    private List<String> PRIMARY_ACCOUNT_NAME_LIST;
    @TestVisible
    private Map<String, List<Decimal>> PRIMARY_COSTS;
    @TestVisible
    private Map<String, Decimal> SECONDARY_COSTS;

/******************************** PROPERTIES **********************************/    

    public Map<String, List<Decimal>> primaryCosts {
        get {
            return this.PRIMARY_COSTS;
        }
    }
    public Integer primaryCostsLastCellIdx {
        get {
            // The index of the last cell is equal to the size of initial
            // account list because we add additional column for totals in the
            // ProjectCostHelper.getPrimaryCosts method
            return PRIMARY_ACCOUNT_NAME_LIST.size();
        }
    }
    public String primaryCostsCellWidth {
        get {
            Decimal width;
            width = ProjectCostHelper.DEFAULT_COST_COLUMN_WIDTH;
            return String.valueOf(width) + '%';
        }
    }
    public String primaryCostsTotalRowName {
        get {
            return ProjectCostHelper.PRIMARY_COSTS_TOTAL_ROW_NAME;
        }
    }
    public List<String> primaryCostsHeaderList {
        get {
            List<String> tableHeader;
            tableHeader = new List<String> (this.PRIMARY_ACCOUNT_NAME_LIST);
            tableHeader.add(
                ProjectCostHelper.ANY_COSTS_TOTAL_COLUMN_NAME);
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
            return ProjectCostHelper.SECONDARY_COSTS_TOTAL_ROW_NAME;
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
            return this.PRIMARY_COSTS.isEmpty()
                && this.SECONDARY_COSTS.isEmpty();
        }
    }
    public String emptyTableMessage {
        get {
            return 'NO PROJECT COST FOUND';
        }
    }
    public List<String> primaryAccountNames {
        get {
            return this.PRIMARY_ACCOUNT_NAME_LIST;
        }
    }

/********************************** METHODS ***********************************/
    public ID getProjectId() {
        return this.PROJECT_ID;
    }
    public void setProjectId(ID value) {
        this.PROJECT_ID = value;
        this.populateConstants();
    }

    @TestVisible
    private void populateConstants() {
        this.PRIMARY_ACCOUNT_NAME_LIST
            = ProjectCostHelper.getPrimaryAccountNames(this.PROJECT_ID);
        this.PRIMARY_COSTS = ProjectCostHelper.getPrimaryCosts(
            this.PROJECT_ID, this.PRIMARY_ACCOUNT_NAME_LIST);
        this.SECONDARY_COSTS = ProjectCostHelper.getSecondaryCosts(
            this.PROJECT_ID);
    }
}