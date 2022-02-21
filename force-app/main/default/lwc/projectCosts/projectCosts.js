import { LightningElement, api, track } from 'lwc';
import getProjectCostsRecords from '@salesforce/apex/CostSheetAsPdfExtensionHelper.getProjectCostsRecords';

const columns = [
    {
        label: 'Account (Main)',
        fieldName: 'accountMain',
        type: 'text',
        sortable: false,
        wrapText: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Account (Expence)',
        fieldName: 'accountExpence',
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
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
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
        cellAttributes: {
            alignment: 'right',
            currencyCode: 'USD',
            step: '0.01' }
    }
]

export default class ProjectCosts extends LightningElement {
    
    columns = columns;
    defaultSortDirection = 'asc';
    costs = [];

    @api
    recordId;

    connectedCallback() {
        getProjectCostsRecords({ projectId: this.recordId})
            .then(costMap => {
                this.processProjectCosts(costMap);
            });
    }

    processProjectCosts(costMap) {
        if (costMap == null) return;
        let costs = [];
        for (const [key, records] of Object.entries(costMap)) {
            let subtotal = 0.0;
            for (const record of records) {
                subtotal += record.amount;
            }
            costs.push({ 
                section: key,
                data: records,
                subtotal: subtotal,
                sortDirection: 'asc',
                sortedBy: null
            });
        }
        this.costs = costs;
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

    onExpandAllHandler() {
        let accordion = this.template.querySelector(".project-costs");
        let openSections = [];
        this.costs.forEach(function(costGroup) {
            openSections.push(costGroup.section);
        })
        accordion.activeSectionName = openSections;
    }
    onCollapseAllHandler() {
        let accordion = this.template.querySelector(".project-costs");
        accordion.activeSectionName = [];
    }
}