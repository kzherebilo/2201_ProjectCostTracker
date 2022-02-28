import { LightningElement, api, track } from 'lwc';
import getProjectCostsRecords from '@salesforce/apex/ProjectCostHelper.getProjectCostsRecords';
import getPrimaryAccountNames from '@salesforce/apex/ProjectCostHelper.getPrimaryAccountNames';
import getPrimaryCosts from '@salesforce/apex/ProjectCostHelper.getPrimaryCosts';
import getSecondaryCosts from '@salesforce/apex/ProjectCostHelper.getSecondaryCosts';
import getProjectCostConstants from '@salesforce/apex/ProjectCostHelper.getProjectCostConstants';
import { NavigationMixin } from 'lightning/navigation';

const SUMMARY_SECTION_NAME = 'Project Cost Summary'
const COLUMNS = [
    {
        label: 'Vendor',
        fieldName: 'vendorUrl',
        type: 'url',
        sortable: true,
        wrapText: true,
        cellAttributes: { alignment: 'left' },
        typeAttributes: { 
            label: {
                fieldName: 'vendorName'
            }
        }
    },
    {
        label: 'Account (Main)',
        fieldName: 'accountMain',
        type: 'text',
        sortable: false,
        wrapText: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Account (Expense)',
        fieldName: 'accountExpense',
        type: 'string',
        sortable: false,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Class',
        fieldName: 'costClass',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Date',
        fieldName: 'costDate',
        type: 'date-local',
        sortable: true,
        cellAttributes: { alignment: 'left' },
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
    {
        label: 'Notes',
        fieldName: 'description',
        type: 'text',
        sortable: false,
        wrapText: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Amount',
        fieldName: 'amount',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'right' },
        typeAttributes: {
            currencyCode: 'USD',
            step: '0.01' 
        }
    }
]


export default class ProjectCosts extends NavigationMixin(LightningElement) {
    
    costs;
    summarySectionName = SUMMARY_SECTION_NAME;
    columns = COLUMNS;
    defaultSortDirection = 'asc';
    isCostsListNotEmpty = false;
    isComponentLoading = true;
    collapseExpandAllButtonLabel = 'Show Details';
    
    costSummary;
    overallTotal = 0.0;
    primaryAccountNames;
    constants;
    exportOptionsMenu = [
        {
            label: 'Include Details',
            value: 'details',
            active: false
        }
    ];

    @api
    recordId;

    connectedCallback() {
        getProjectCostsRecords({ projectId: this.recordId })
            .then(costMap => {
                this.processProjectCosts(costMap);
                this.isComponentLoading = false;
            })
            .catch(error => {
                console.log(error);
            });
        getProjectCostConstants()
            .then(constantMap => {
                const parameters = {
                    projectId: this.recordId
                }
                this.processConstants(constantMap);
                return getPrimaryAccountNames(parameters);
            })
            .then(primaryAccountNames => {
                const parameters = {
                    projectId: this.recordId,
                    primaryAccountNameList: primaryAccountNames
                }
                this.primaryAccountNames = primaryAccountNames;
                return getPrimaryCosts(parameters);
            })
            .then(costMap => {
                const parameters = {
                    projectId: this.recordId
                }
                this.processPrimaryCosts(costMap);
                return getSecondaryCosts(parameters);
            })
            .then(costMap => {
                this.processSecondaryCosts(costMap);
                console.log(this.costSummary);
            })
            .catch(error => {
                console.log(error);
            });
    }

    processProjectCosts(costMap) {
        if (costMap == null) return;
        let costs = [];
        for (const [key, records] of Object.entries(costMap)) {
            let subtotal = 0;
            for (const record of records) {
                subtotal += record.amount;
            }
            const sectionLabel = key + '    ('
                + this.currencyFormatter().format(subtotal) + ')';
            costs.push({ 
                section: key,
                sectionLabel: sectionLabel, 
                data: records,
                subtotal: subtotal,
                sortDirection: 'asc',
                sortedBy: null
            });
        }
        this.costs = costs;
        this.isCostsListNotEmpty = (costs.length > 0);
    }

    processConstants(constantMap) {
        if (constantMap == null) return;
        let constants = {};
        for (const [key, value] of Object.entries(constantMap)) {
            constants[key] = value;
        }
        this.constants = constants;
    }

    processPrimaryCosts(costMap) {
        if (costMap == null) return;
        let costSummary = [];
        for (const [key, costsByClass] of Object.entries(costMap)) {
            let cost = {};
            if (key == this.constants.PRIMARY_COSTS_TOTAL_ROW_NAME) {
                cost['class'] = null;
                this.overallTotal 
                    += costsByClass[this.primaryAccountNames.length];
            } else {
                cost['class'] = key;
            }
            for (let i = 0; i < this.primaryAccountNames.length; i++) {
                let fieldName
                    = this.primaryAccountNames[i].replaceAll(' ', '_');
                let fieldValue 
                    = this.currencyFormatter().format(costsByClass[i]);
                cost[fieldName] = fieldValue;
            }
            cost[this.constants.ANY_COSTS_TOTAL_COLUMN_NAME]
                = this.currencyFormatter().format(
                    costsByClass[this.primaryAccountNames.length]);
            costSummary.push(cost);
        }
        this.costSummary = costSummary;
    }

    processSecondaryCosts(costMap) {
        if (costMap == null) return;
        let costSummary = [...this.costSummary];
        for (const [key, costByName] of Object.entries(costMap)) {
            let cost = {};
            if (key == this.constants.SECONDARY_COSTS_TOTAL_ROW_NAME) {
                cost['class'] = null;
                this.overallTotal += costByName;
            } else {
                cost['class'] = key;
            }
            for (let i = 0; i < this.primaryAccountNames.length; i++) {
                let fieldName
                    = this.primaryAccountNames[i].replaceAll(' ', '_');
                cost[fieldName] = null;
            }
            cost['total'] = this.currencyFormatter().format(costByName);
            costSummary.push(cost);
        }
        let cost = {};
        cost['class'] = 'Total';
        for (let i = 0; i < this.primaryAccountNames.length; i++) {
            let fieldName
                = this.primaryAccountNames[i].replaceAll(' ', '_');
            cost[fieldName] = null;
        }
        cost['total'] = this.currencyFormatter().format(this.overallTotal);
        costSummary.push(cost);
        this.costSummary = costSummary;
    }

    currencyFormatter() {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        });
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onSortHandler(event) {
        if (event.target.ariaLabel == null) return;
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const tableLabel = event.target.ariaLabel;
        let cloneCosts = JSON.parse(JSON.stringify(this.costs));
        let costGroup = cloneCosts.filter(costGroup => {
            return costGroup.section === tableLabel })[0];
        costGroup.data.sort(this.sortBy(
            sortedBy, sortDirection === 'asc' ? 1 : -1));
        costGroup.sortDirection = sortDirection;
        costGroup.sortedBy = sortedBy;
        this.costs = cloneCosts;
    }

    onCollapseExpandAllHandler() {
        let accordion = this.template.querySelector(".project-costs");
        let openSections = accordion.activeSectionName;
        if (this.isExpandedView(openSections)) {
            this.setCollapsedView(openSections);
        } else {
            this.setExpandedView(openSections);
        }
        accordion.activeSectionName = openSections;
        this.setCollapseExpandButtonLabel(openSections);
    }

    onCollapseSectionHandler(event) {
        console.log(event.target.ariaLabel);
        if (event.target.ariaLabel == null) return;
        const tableLabel = event.target.ariaLabel;
        let accordion = this.template.querySelector(".project-costs");
        let openSections = [...accordion.activeSectionName];
        openSections.splice(openSections.indexOf(tableLabel), 1);
        accordion.activeSectionName = openSections;
        this.setCollapseExpandButtonLabel(openSections);
    }

    onSectionToggleHandler(event) {
        let openSections = event.target.activeSectionName;
        this.setCollapseExpandButtonLabel(openSections);
    }

    onExportOptionsChange(event) {
        let options = [...this.exportOptionsMenu];
        let optionItem = options.find(item => {
            return item.value === event.detail.value;
        })
        optionItem.active = !optionItem.active;
        this.exportOptionsMenu = options;
    }

    setCollapseExpandButtonLabel(openSections) {
        if (this.isExpandedView(openSections)) {
            this.collapseExpandAllButtonLabel = 'Hide Details';
        } else {
            this.collapseExpandAllButtonLabel = 'Show Details';
        }
    }

    onProjectCostsPDFHandler() {
        let costSheetPageUrl = '/apex/ProjectCostSummary?id=' + this.recordId;
        this[NavigationMixin.Navigate] ({
            type: 'standard__webPage',
            attributes: {
                url: costSheetPageUrl
            }
        });
    }

    isExpandedView(openSections) {
        if (this.costs == null) return false;
        return this.costs.reduce((isOpen, costGroup) => {
            return isOpen || openSections.includes(costGroup.section);
        }, false);
    }

    setCollapsedView(openSections) {
        this.costs.forEach(function(costGroup) {
            if (openSections.includes(costGroup.section)) {
                openSections.splice(openSections.indexOf(
                    costGroup.section), 1);
            }
        });
    }

    setExpandedView(openSections) {
        this.costs.forEach(function(costGroup) {
            openSections.push(costGroup.section);
        });
    }

}