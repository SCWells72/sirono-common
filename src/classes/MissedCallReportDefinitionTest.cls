/**
 * Testing the MissedCallReportDefinition class.
 */

@isTest
public with sharing class MissedCallReportDefinitionTest {
    /**
     * The MissedCallReportDefinition class has 4 public methods and a single constructor method that takes
     * the parameters given and sets them to the appropriate variables. This method tests those settings.
     **/
    @isTest
    public static void reportDefinitionTest() {
        String TEST_FOLDER_NAME = 'Folder Name';
        String TEST_REPORT_NAME = 'Report Name';
        Datetime TEST_START_DATE = System.today().addDays(-7);
        Datetime TEST_END_DATE = System.today();

        Test.startTest();
        MissedCallReportDefinition reportDefinition = new MissedCallReportDefinition(
                TEST_FOLDER_NAME, TEST_REPORT_NAME, TEST_START_DATE, TEST_END_DATE
        );
        Test.stopTest();

        System.assertEquals(TEST_FOLDER_NAME, reportDefinition.FOLDER_NAME);
        System.assertEquals(TEST_REPORT_NAME, reportDefinition.REPORT_NAME);
        System.assertEquals(TEST_START_DATE, reportDefinition.START_DATE);
        System.assertEquals(TEST_END_DATE, reportDefinition.END_DATE);
    }

    /**
     * Create an invalid report definition and test that you receive an appropriate error.
     **/
    @isTest
    public static void invalidDefinitionTest() {
        String TEST_FOLDER_NAME = 'Folder Name';
        String TEST_REPORT_NAME = 'Report Name';
        Datetime TEST_START_DATE = System.today();
        Datetime TEST_END_DATE = System.today().addDays(-7);

        Test.startTest();

        MissedCallReportDefinition reportDefinition = new MissedCallReportDefinition(
                TEST_FOLDER_NAME, TEST_REPORT_NAME, TEST_START_DATE, TEST_END_DATE
        );

        Boolean areDatesValid = reportDefinition.isValid();

        // Set folder name to null and run isValid()
        reportDefinition.FOLDER_NAME = null;

        Boolean isFolderNameValid = reportDefinition.isValid();

        Test.stopTest();

        System.assertEquals(False, areDatesValid);
        System.assertEquals(False, isFolderNameValid);
    }

}