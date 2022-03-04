public without sharing class CostDetailsTable {

/********************************* CONSTANTS **********************************/
    @TestVisible
    private ID PROJECT_ID;
    @TestVisible
    private List<String> TABLE_HEADERS;
    @TestVisible
    private List<String> GROUP_NAME_LIST;
    @TestVisible
    private Map<String, Integer> NUMBER_OF_RECORDS_BY_GROUP;
    @TestVisible
    Map<String, List<ProjectCostHelper.ProjectCostWrapper>> PROJECT_COST_LIST;

/******************************** PROPERTIES **********************************/
    public Map<String, List<ProjectCostHelper.ProjectCostWrapper>> costList {
        get {
            return this.PROJECT_COST_LIST;
        }
    }

    public List<String> headerList {
        get {
            return this.TABLE_HEADERS;
        }
    }

    public List<String> groupNameList {
        get {
            return this.GROUP_NAME_LIST;
        }
    }

    public Map<String, Integer> numberOfRecordsByGroup {
        get {
            return this.NUMBER_OF_RECORDS_BY_GROUP;
        }
    }

    public Integer lastCellIndex {
        get {
            return this.TABLE_HEADERS.size() - 1;
        }
    }

    public String amountCellWidth {
        get {
            Decimal width;
            width = ProjectCostHelper.DEFAULT_COST_COLUMN_WIDTH;
            return String.valueOf(width) + '%';
        }
    }

    public String defaultCellWidth {
        get {
            Decimal width;
            width = 100.0 - ProjectCostHelper.DEFAULT_COST_COLUMN_WIDTH;
            width = width / (this.headerList.size() - 1);
            return  String.valueOf(width) + '%';
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
        this.PROJECT_COST_LIST
            = ProjectCostHelper.getProjectCostsRecords(this.PROJECT_ID);
        this.TABLE_HEADERS = new List<String> {
            'Vendor',
            'Account (Main)',
            'Account (Expense)',
            'Class',
            'Date',
            'Notes',
            'Amount'
        };
        this.NUMBER_OF_RECORDS_BY_GROUP = new Map<String, Integer> ();
        this.GROUP_NAME_LIST = new List<String> (this.PROJECT_COST_LIST.keySet());
        for(String costGroup : this.GROUP_NAME_LIST) {
            this.NUMBER_OF_RECORDS_BY_GROUP.put(costGroup,
                this.PROJECT_COST_LIST.get(costGroup).size());
        }
    }

}
