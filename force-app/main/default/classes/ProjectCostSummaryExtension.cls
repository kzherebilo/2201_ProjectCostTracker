public without sharing class ProjectCostSummaryExtension {

/******************************** PROPERTIES **********************************/

    public Project__c project { get; private set; }
    public Boolean isDetailedViewEnabled { get; private set; }
    public Map<String, String> propertyInfo { get; private set; }
    public List<String> propertyInfoFields { get; private set; }
    public String footerLeftSection { get; private set; }
    public String footerRightSection { get; private set; }
    public String footerCenterSection { get; private set; }
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
        this.project = [
            SELECT Id, 
                   Name,
                   Related_Property__r.Property_Status__c,
                   Related_Property__r.Square_Footage__c,
                   Related_Property__r.Bedrooms__c, 
                   Related_Property__r.Bathrooms__c,
                   Related_Property__r.Street__c, 
                   Related_Property__r.City__c, 
                   Related_Property__r.State__c,
                   Related_Property__r.Zip_Code__c,
                   Related_Property__r.Country__c 
            FROM Project__c
            WHERE Id =: parameters.get('id') LIMIT 1];
        String generatedFilename = this.project.Name
            + ' - ' + documentTitle + '.pdf';
        Apexpages.currentPage().getHeaders().put(
            'content-disposition', 'inline; filename=' + generatedFilename);
        this.initializePropertyInfo();
        this.footerRightSection = this.project.Related_Property__r.Street__c;
        this.footerLeftSection 
            = 'Coordinator: ' + UserInfo.getName() + '\n'
            + 'Last Updated: ' + Datetime.now().format('EEEE MMM dd, HH:mm:ss z yyyy');
        this.footerCenterSection
            = 'FOR INTERNAL USE ONLY\nSECURE & CONFIDENTIAL';
    }

    private void initializePropertyInfo() {
        if (this.project == null) return;
        this.propertyInfo = new Map<String, String> ();
        String street = this.project.Related_Property__r.Street__c;
        String city = this.project.Related_Property__r.City__c;
        String state = this.project.Related_Property__r.State__c;
        String zipCode = this.project.Related_Property__r.Zip_Code__c;
        String country = this.project.Related_Property__r.Country__c;
        String status = this.project.Related_Property__r.Property_Status__c;
        String footage = String.valueOf(
            this.project.Related_Property__r.Square_Footage__c);
        String bedrooms = String.valueOf(
            this.project.Related_Property__r.Bedrooms__c);
        String bathrooms = String.valueOf(
            this.project.Related_Property__r.Bathrooms__c);
        street = String.isBlank(street) ? '' : street.trim() + ', ';
        city = String.isBlank(city) ? '' : city.trim() + ', ';
        state = String.isBlank(state) ? '' : state.trim() + ', ';
        zipCode = String.isBlank(zipCode) ? '' : zipCode.trim() + ', ';
        country = String.isBlank(country) ? '' : country.trim();
        String address = street + city + state + zipCode + country;
        address = String.isBlank(address) ? 'N/A' : address;
        status = status == null ? 'N/A' : status;
        footage = footage == null ? 'N/A' : String.valueOf(footage);
        bedrooms = bedrooms == null ? 'N/A' : String.valueOf(bedrooms);
        bathrooms = bathrooms == null ? 'N/A' : String.valueOf(bathrooms);
        this.propertyInfo.put('Property Address', address);
        this.propertyInfo.put('Property Status', status);
        this.propertyInfo.put('Square Footage', footage);
        this.propertyInfo.put('Bedrooms', bedrooms);
        this.propertyInfo.put('Bathrooms', bathrooms);
        this.propertyInfoFields = new List<String> (this.propertyInfo.keySet());
    }
}
