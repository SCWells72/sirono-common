#! /bin/bash
# This script requires that both Force.com CLI and SFDX cli are installed on the running system. Additionally, the running user needs to change their
# directory to sirono-salesforce/data/ for the following commands to run successfully. As soon as I can figure out how to do that reliably, I'll probably
# force a change directory command somewhere in here.

# BEGIN FUNCTIONS

loadData() {
    if [ $# -ne 3 ]; then
        echo "Usage: loadData <csvFilename> <sobjectType> <externalIdField>"
        exit 1
    fi

    CSV_FILENAME=$1
    SOBJECT_TYPE=$2
    EXTERNAL_ID_FIELD=$3

    CSV_FILE=./res/temp/load/${CSV_FILENAME}
    if [ -s ${CSV_FILE} ]; then
        sfdx force:data:bulk:upsert -u sirono-salesforce -f ${CSV_FILE} -s ${SOBJECT_TYPE} -i ${EXTERNAL_ID_FIELD} -w 5
        if [ $? -ne 0 ]; then
            echo "Failed to load ${SOBJECT_TYPE} from ${CSV_FILENAME}."
            exit 1
        fi
    else
        echo "Skipping empty file ${CSV_FILENAME}."
    fi
}

createData() {
    if [ $# -ne 1 ]; then
        echo "Usage: createData <apexFileName>"
        exit 1
    fi

    APEX_FILENAME=$1

    APEX_FILE=./res/apex/load/${APEX_FILENAME}
    if [ -s ${APEX_FILE} ]; then
        sfdx force:apex:execute -u sirono-salesforce -f ${APEX_FILE}
        if [ $? -ne 0 ]; then
            echo "Failed to execute ${APEX_FILENAME}."
            exit 1
        fi
    else
        echo "Nothing found in the apex file."
    fi
}
# END FUNCTIONS

# First, need to download the record types from the target org and dump into ./accessoryFiles/Contact_RecordTypes.csv. Without it, user will not be able
# to load contacts.
echo "First, please run the following commands in a new tab to download Contact record types."
sleep 1s
echo "force login"
echo "force bulk query RecordType \"select name, id from recordtype where sobjecttype = 'Contact'\""
sleep 2s
read -p "After running the above commands, press the enter key to continue."
echo "\n"
echo "You should receive two commands in response: one for checking the status, one for retrieving the results."
echo "Once downloaded, dump the file into data/res/accessoryFiles/Contact_RecordTypes.csv"
echo "Run the following retrieve command and replace the Salesforce Id tags with the Ids returned by running the query:"
sleep 5s
echo "force bulk query retrieve [Salesforce Id] [Salesforce Id] > ./res/accessoryFiles/Contact_RecordTypes.csv"
sleep 2s
read -p "Once completed, press the enter key to continue."


# Store Contact record type Ids into variables to switch out with record type names.
GUARANTOR_ID=$(cat ./res/accessoryFiles/Contact_RecordTypes.csv | sed 's/\"//g' | awk -F "," '{if($1 ~ /^Guarantor/) print $2};')
PATIENT_ID=$(cat ./res/accessoryFiles/Contact_RecordTypes.csv | sed 's/\"//g' | awk -F "," '{if($1 == "Patient") print $2};')
EXTERNAL_GUARANTOR_ID=$(cat ./res/accessoryFiles/Contact_RecordTypes.csv | sed 's/\"//g' | awk -F "," '{if($1 == "External Guarantor") print $2};')

# Make a directory to put temporary, manipulated files for loading thus leaving the base files alone.
rm -rf ./res/temp ./res/apex/load/
mkdir ./res/temp/
mkdir ./res/temp/load/
mkdir ./res/apex/load/

# Replace the Guarantor record type name with the associated Id value; overwrite the original .csv file.
echo "Replacing record type field header and values with record type Id ... "
cat ./res/Contact_Guarantor.csv | awk -F ',' -v GUARANTOR_ID=$GUARANTOR_ID '{OFS=","; if(NR==1) $6="RecordTypeId"; else $6=GUARANTOR_ID; print $0};' > ./res/temp/Contact_Guarantor.csv.new
cat ./res/Contact_Patient.csv | awk -F ',' -v PATIENT_ID=$PATIENT_ID '{OFS=","; if(NR==1) $6="RecordTypeId"; else $6=PATIENT_ID; print $0};' > ./res/temp/Contact_Patient.csv.new
cat ./res/Contact_ExternalGuarantor.csv | awk -F ',' -v EXTERNAL_GUARANTOR_ID=$EXTERNAL_GUARANTOR_ID '{OFS=","; if(NR==1) $6="RecordTypeId"; else $6=EXTERNAL_GUARANTOR_ID; print $0};' > ./res/temp/Contact_ExternalGuarantor.csv.new

# TODO: We can get the namespace from ../build/build.properties as the value for sf.sprs.development.namespace
# Get the namespace from the user's target org (user input).
echo "Please enter your target org's namespace. If no namespace, just hit enter."
read NAMESPACE

# For each template file, replace the header row with the chosen namespace and put into the temporary load directory.
for file in `ls ./res | grep .csv`;
do
    if [ "${#NAMESPACE}" -gt 1 ]; then
        # First, put the namespaced headers into a file, then append the file's guts to the results
        head -1 ./res/$file | sed -e "s/sPRS__/${NAMESPACE}__/g" > ./res/temp/load/$file
        tail -n +2 ./res/$file >> ./res/temp/load/$file
    else
        echo "Please provide a namespace. You should have one."
        exit 1
    fi
done

# Now, loop through the template apex files and update the namespace on them, as well.
for file in `ls ./res/apex/template | grep .apex`;
do
    if [ "${#NAMESPACE}" -gt 1 ]; then
        cat ./res/apex/template/$file | sed -e "s/sPRS__/${NAMESPACE}__/g" > ./res/apex/load/$file
    else
        echo "Please provide a namespace. You should have one."
        exit 1
    fi
done

# For each Contact temp file, replace the header row with the chosen namespace and put into the temporary load directory.
for file in `ls ./res/temp | grep .csv  | grep -v .new`;
do
    if [ "${#NAMESPACE}" -gt 1 ]; then
        # First, put the namespaced headers into a file, then append the file's guts to the results
        cat ./res/accessoryFiles/templateNamespaceFileHeaders.txt | awk -F '\t' -v FILENAME=$file '{OFS=","; if($1 == FILENAME) print $2};' | sed s/xxXXxx__/"${NAMESPACE}__"/g > ./res/temp/load/$file
        cat ./res/$file | tail -n +2 >> ./res/temp/load/$file
    else
        cat ./res/accessoryFiles/templateNamespaceFileHeaders.txt | awk -F '\t' -v FILENAME=$file '{OFS=","; if($1 == FILENAME) print $2};' | sed s/xxXXxx__//g > ./res/temp/load/$file
        cat ./res/$file | tail -n +2 >> ./res/temp/load/$file
    fi
done

OBJ_PREFIX=""
if [ "${#NAMESPACE}" -gt 1 ]; then
    OBJ_PREFIX="${NAMESPACE}"__
fi

# Start loading some sweet, sweet files.
# But first, you need to login using sfdx.
echo "Please log into the target org using sfdx ... (this is annoying, I know)."
sleep 1s
sfdx force:auth:web:login -a sirono-salesforce

# NOW, start loadin' some files.
if [ $? -eq 0 ]; then
    echo "***** First, we load the Location object *****"
    loadData Location.csv "${OBJ_PREFIX}Location__c" "${OBJ_PREFIX}Sirono_Id__c"
    echo "***** Now loading the Payor object *****"
    loadData Payor.csv "${OBJ_PREFIX}Payor__c" "${OBJ_PREFIX}Unique_Id__c"
    echo "***** Now loading the Provider object *****"
    loadData Provider.csv "${OBJ_PREFIX}Provider__c" "${OBJ_PREFIX}Sirono_Id__c"
    echo "***** Now loading Service Rollups *****"
    loadData Service_Rollup.csv "${OBJ_PREFIX}Service_Rollup__c" "${OBJ_PREFIX}Sirono_Id__c"
    echo "***** Now loading The Account *****"
    loadData Account.csv "Account" "${OBJ_PREFIX}External_Account_Name__c"
    echo "***** Enough of the easy stuff, now we're going to load some Contacts. *****"
    echo "***** First, load some Guarantors *****"
    loadData Contact_Guarantor.csv "Contact" "${OBJ_PREFIX}Guarantor_Id__c"
    echo "***** Loading External Guarantors *****"
    loadData Contact_ExternalGuarantor.csv "Contact" "${OBJ_PREFIX}External_Guarantor_Id__c"
    echo "***** Loading Patients *****"
    loadData Contact_Patient.csv "Contact" "${OBJ_PREFIX}Patient_Id__c"
    echo "***** FINALLY ... done with loading Contacts *****"
    echo "***** Loading Payment Methods *****"
    loadData Payment_Method.csv "${OBJ_PREFIX}Payment_Method__c" "${OBJ_PREFIX}Sirono_Id__c"
    echo "***** Loading Invoices *****"
    loadData Invoice.csv "${OBJ_PREFIX}Invoice__c" "${OBJ_PREFIX}Sirono_Id__c"
    echo "***** Loading Payment Plans *****"
    loadData Payment_Plan.csv "${OBJ_PREFIX}Payment_Plan__c" "${OBJ_PREFIX}Sirono_Id__c"
    echo "***** Loading Statements *****"
    loadData Statement.csv "${OBJ_PREFIX}Statement__c" "${OBJ_PREFIX}Sirono_Id__c"
    echo "***** You think this is a lot to load? Think about typing all this crap out! *****"
    echo "***** Loading Charge Groups *****"
    loadData Charge_Group.csv "${OBJ_PREFIX}Charge_Group__c" "${OBJ_PREFIX}Sirono_Id__c"
    echo "***** Loading Coverages *****"
    loadData Coverage.csv "${OBJ_PREFIX}Coverage__c" "${OBJ_PREFIX}Sirono_Id__c"
    echo "***** Loading Guarantor Payments *****"
    loadData Payment_Guarantor.csv "${OBJ_PREFIX}Payment__c" "${OBJ_PREFIX}Sirono_Id__c"
    echo "***** Loading Services *****"
    loadData Service.csv "${OBJ_PREFIX}Service2__c" "${OBJ_PREFIX}Aggregate_Id__c"
    echo "***** Loading Adjustments *****"
    loadData Adjustment.csv "${OBJ_PREFIX}Adjustment__c" "${OBJ_PREFIX}Aggregate_Id__c"
    echo "***** Loading Payor Payments *****"
    loadData Payment_Payor.csv "${OBJ_PREFIX}Payment__c" "${OBJ_PREFIX}Id__c"
    echo "***** Loading Service Transactions *****"
    loadData Transaction_Service.csv "${OBJ_PREFIX}Transaction__c" "${OBJ_PREFIX}Sirono_Id__c"
    echo "***** Loading Adjustment Transactions *****"
    loadData Transaction_Adjustment.csv "${OBJ_PREFIX}Transaction__c" "${OBJ_PREFIX}Sirono_Id__c"
    echo "***** Loading Payment Transactions *****"
    loadData Transaction_Payment.csv "${OBJ_PREFIX}Transaction__c" "${OBJ_PREFIX}Sirono_Id__c"
    echo "***** Almost there ... *****"
    echo "***** Loading Charge Group Coverage Junctions *****"
    loadData Charge_Group_Coverage_Junction.csv "${OBJ_PREFIX}Charge_Group_Coverage_Junction__c" "${OBJ_PREFIX}Sirono_Id__c"
    echo "***** Loading Patient Coverage Junctions *****"
    loadData Patient_Coverage_Junction.csv "${OBJ_PREFIX}Patient_Coverage_Junction__c" "${OBJ_PREFIX}Sirono_Id__c"
    echo "***** Loading Guarantor Notes *****"
    loadData Contact_Notes.csv "Contact" "${OBJ_PREFIX}Guarantor_Id__c"
    echo "***** Creating Encounters *****"
    createData "EncounterCreator.apex"
    echo "***** Creating Attachments ****"
    createData "AttachmentAttacher.apex"
    echo "***** ... and now we're done! *****"
else
    echo "Logging in didn't quite work correctly."
    exit 1
fi
