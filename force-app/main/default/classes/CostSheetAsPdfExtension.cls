public class CostSheetAsPdfExtension {

    public CostSheetAsPdfExtension(ApexPages.StandardController controller) {      
        // Add a file name for the PDF file
        // This is supposed to set the file name, but it doesn't work
        renderedContentType = 'application/pdf#' + this.RENDERED_FILENAME;
        // This is a work-around to set the file name
        // ApexPages.currentPage().getHeaders().put('content-disposition',
        //     'attachment; filename=' + this.RENDERED_FILENAME);
    }

    public final String RENDERED_FILENAME = 'Cost-Sheet.pdf';

    public String renderedContentType { get; private set; }

}