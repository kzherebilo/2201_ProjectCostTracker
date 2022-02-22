import { LightningElement, api, track } from 'lwc';
import getProjectCostsRecords from '@salesforce/apex/CostSheetAsPdfExtensionHelper.getProjectCostsRecords';
import { NavigationMixin } from 'lightning/navigation';

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
    columns = COLUMNS;
    defaultSortDirection = 'asc';
    isCostsListNotEmpty = false;
    isComponentLoading = true;
    collapseExpandAllButtonLabel = 'Expand All';

    @api
    recordId;

    connectedCallback() {
        getProjectCostsRecords({ projectId: this.recordId})
            .then(costMap => {
                this.processProjectCosts(costMap);
                this.isComponentLoading = false;
            })
            .catch(error => {
                console.log(error);
            });
    }

    processProjectCosts(costMap) {
        if (costMap == null) return;
        let toUSD = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        });
        let costs = [];
        for (const [key, records] of Object.entries(costMap)) {
            let subtotal = 0.0;
            for (const record of records) {
                subtotal += record.amount;
            }
            const sectionLabel = key + '    ('
                + toUSD.format(subtotal) + ')';
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
        const tableLabel = event.target.ariaLabel.split(' ')[0].trim();
        let cloneCosts = JSON.parse(JSON.stringify(this.costs));
        let costGroup = cloneCosts.filter(costGroup => {
            return costGroup.section === tableLabel })[0];
        costGroup.data.sort(this.sortBy(
            sortedBy, sortDirection === 'asc' ? 1 : -1));
        costGroup.sortDirection = sortDirection;
        costGroup.sortedBy = sortedBy;
        this.costs = cloneCosts;
    }

    onCollapseExpandAllHandler(event) {
        let accordion = this.template.querySelector(".project-costs");
        let openSections = accordion.activeSectionName;
        if (openSections.length > 0) {
            openSections = [];
        } else {
            this.costs.forEach(function(costGroup) {
                openSections.push(costGroup.section);
            });
        }
        accordion.activeSectionName = openSections;
        this.setCollapseExpandButtonLabel(openSections);
    }

    onCollapseSectionHandler(event) {
        console.log(event.target.ariaLabel);
        if (event.target.ariaLabel == null) return;
        const tableLabel = event.target.ariaLabel.split(' ')[0].trim();
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

    setCollapseExpandButtonLabel(openSections) {
        if (openSections.length > 0) {
            this.collapseExpandAllButtonLabel = 'Collapse All';
        } else {
            this.collapseExpandAllButtonLabel = 'Expand All';
        }
    }

    onProjectCostsPDFHandler() {
        let costSheetPageUrl = '/apex/CostSheetOnProjectCosts?id='
            + this.recordId;
        this[NavigationMixin.Navigate] ({
            type: 'standard__webPage',
            attributes: {
                url: costSheetPageUrl
            }
        });
    }

}