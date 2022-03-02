import { api, LightningElement } from 'lwc';
import getPrimaryAccountNames from '@salesforce/apex/ProjectCostHelper.getPrimaryAccountNames';
import getPrimaryCosts from '@salesforce/apex/ProjectCostHelper.getPrimaryCosts';
import getSecondaryCosts from '@salesforce/apex/ProjectCostHelper.getSecondaryCosts';
import getProjectCostConstants from '@salesforce/apex/ProjectCostHelper.getProjectCostConstants';

export default class ProjectCostSummary extends LightningElement {

    @api
    projectId;

    constants = {};
    costTableData;
    costTableHeader;
    primaryAccountNameList;
    overallTotal = 0.0;
    isRendered = false;

    connectedCallback() {
        if (this.projectId == null) return;
        this.isRendered = true;
        getProjectCostConstants()
            .then(constantMap => {
                const parameters = {
                    projectId: this.projectId
                }
                this.processConstants(constantMap);
                return getPrimaryAccountNames(parameters);
            })
            .then(primaryAccountNameList => {
                const parameters = {
                    projectId: this.projectId,
                    primaryAccountNameList: primaryAccountNameList
                }
                this.primaryAccountNameList = primaryAccountNameList;
                this.initializeHeader();
                return getPrimaryCosts(parameters);
            })
            .then(costMap => {
                const parameters = {
                    projectId: this.projectId
                }
                this.processPrimaryCosts(costMap);
                return getSecondaryCosts(parameters);
            })
            .then(costMap => {
                this.processSecondaryCosts(costMap);
            })
            .catch(error => {
                console.log(error);
            });
    }

    processConstants(constantMap) {
        if (constantMap == null) return;
        let constants = {};
        Object.assign(constants, this.constants);
        for (const [key, value] of Object.entries(constantMap)) {
            constants[key] = value;
        }
        this.constants = constants;
    }

    processPrimaryCosts(costMap) {
        if (costMap == null) return;
        let costList = [];
        for (const [key, costByClassList] of Object.entries(costMap)) {
            let costGroupLabel;
            let costGroupClass;
            let formattedCostList = [];
            costByClassList.forEach(amount => {
                formattedCostList.push(this.currencyFormatter().format(amount));
            });
            costGroupClass = 'slds-truncate slds-text-align_right ';
            if (key == this.constants.PRIMARY_COSTS_TOTAL_ROW_NAME) {
                costGroupLabel = '';
                costGroupClass += 'slds-text-title_bold ';
                this.overallTotal
                    += costByClassList[this.primaryAccountNameList.length];
            } else {
                costGroupLabel = key;
            }            
            costList.push({
                id    : 'PRIMARY_' + key,
                name  : key,
                label : costGroupLabel,
                data  : formattedCostList,
                class : costGroupClass
            });
        }
        this.costTableData = costList;
    }

    processSecondaryCosts(costMap) {
        if (costMap == null) return;
        let costList = [...this.costTableData];
        let overallTotalList = [];
        const styleClass = 'slds-truncate slds-text-align_right ';
        for (const [key, costByName] of Object.entries(costMap)) {
            let costGroupLabel;
            let costGroupClass;
            let formattedCostList = [];
            formattedCostList[this.primaryAccountNameList.length]
                = this.currencyFormatter().format(costByName);
            costGroupClass = styleClass;
            if (key == this.constants.SECONDARY_COSTS_TOTAL_ROW_NAME) {
                costGroupLabel = '';
                costGroupClass += 'slds-text-title_bold ';
                this.overallTotal += costByName;
            } else {
                costGroupLabel = key;
            }           
            costList.push({
                id    : 'SECONDARY_' + key,
                name  : key,
                label : costGroupLabel,
                data  : formattedCostList,
                class : costGroupClass
            });
        }
        overallTotalList[this.primaryAccountNameList.length]
            = this.currencyFormatter().format(this.overallTotal);
        costList.push({
            id    : 'OVERALL_TOTAL',
            name  : 'Overall Total',
            label : '',
            data  : overallTotalList,
            class : styleClass + 'slds-text-title_bold slds-m-vertical_x-small'
        });
        this.costTableData = costList;
    }

    initializeHeader() {
        let header = [];
        let headerClass = 'slds-truncate slds-text-align_right';
        header.push({
            label: '',
            title: 'Cost Group',
            class: headerClass
        });
        this.primaryAccountNameList.forEach(accountName => {
            header.push({
                label: accountName,
                title: accountName,
                class: headerClass
            });
        });
        header.push({
            label: 'Total',
            title: 'Total',
            class: headerClass
        });
        this.costTableHeader = header;
    }

    currencyFormatter() {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        });
    }
}