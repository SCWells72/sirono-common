#! /bin/bash
# This script requires that both Force.com CLI and SFDX cli are installed on the running system. Additionally, the running user needs to change their
# directory to sirono-salesforce/data/ for the following commands to run successfully. As soon as I can figure out how to do that reliably, I'll probably
# force a change directory command somewhere in here.

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
rm -rf ./res/temp
mkdir ./res/temp/
mkdir ./res/temp/load/

# Fix each Contact extract to remove line breaks within address fields; store in a .bak file.
if [ $? -eq 0 ]; then
    echo "Removing unnecessary line breaks in address fields."
    awk -F"\"" '!$NF{print;next}{printf("%s ", $0)}' ./res/Contact_Guarantor.csv > ./res/temp/Contact_Guarantor.csv.new
    awk -F"\"" '!$NF{print;next}{printf("%s ", $0)}' ./res/Contact_Patient.csv > ./res/temp/Contact_Patient.csv.new
    awk -F"\"" '!$NF{print;next}{printf("%s ", $0)}' ./res/Contact_ExternalGuarantor.csv > ./res/temp/Contact_ExternalGuarantor.csv.new
else
    echo "Something bad happened when trying to set the record type Ids."
    exit 1
fi

# Replace the Guarantor record type name with the associated Id value; overwrite the original .csv file.
echo "Replacing record type field header and values with record type Id ... "
cat ./res/temp/Contact_Guarantor.csv.new | awk -F ',' -v GUARANTOR_ID=$GUARANTOR_ID '{OFS=","; if(NR==1) $6="RecordTypeId"; else $6=GUARANTOR_ID; print $0};' > ./res/temp/Contact_Guarantor.csv
cat ./res/temp/Contact_Patient.csv.new | awk -F ',' -v PATIENT_ID=$PATIENT_ID '{OFS=","; if(NR==1) $6="RecordTypeId"; else $6=PATIENT_ID; print $0};' > ./res/temp/Contact_Patient.csv
cat ./res/temp/Contact_ExternalGuarantor.csv.new | awk -F ',' -v EXTERNAL_GUARANTOR_ID=$EXTERNAL_GUARANTOR_ID '{OFS=","; if(NR==1) $6="RecordTypeId"; else $6=EXTERNAL_GUARANTOR_ID; print $0};' > ./res/temp/Contact_ExternalGuarantor.csv

# Get the namespace from the user's target org (user input).
echo "Please enter your target org's namespace. If no namespace, just hit the enter key."
read NAMESPACE

# For each template file, replace the header row with the chosen namespace and put into the temporary load directory.
for file in `ls ./res | grep .csv`;
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

# Start loading some sweet, sweet files.
# But first, you need to login using sfdx.
echo "Please log into the target org using sfdx ... (this is annoying, I know)."
sleep 1s
sfdx force:auth:web:login -a sirono-salesforce

# NOW, start loadin' some files.
if [ $? -eq 0 ]; then
    echo "***** First, we load the Location object *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Location.csv -s Location__c -i Sirono_Id__c -w 5
    echo "***** Now loading the Payor object *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Payor.csv -s Payor__c -i Unique_Id__c -w 5
    echo "***** Now loading the Provider object *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Provider.csv -s Provider__c -i Sirono_Id__c -w 5
    echo "***** Now loading Service Rollups *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Service_Rollup.csv -s Service_Rollup__c -i Sirono_Id__c -w 5
    echo "***** Now loading The Account *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Account.csv -s Account -i External_Account_Name__c -w 5
    echo "***** Enough of the easy stuff, now we're going to load some Contacts. *****"
    echo "***** First, load some Guarantors *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Contact_Guarantor.csv -s Contact -i Guarantor_Id__c -w 5
    echo "***** Loading External Guarantors *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Contact_ExternalGuarantor.csv -s Contact -i External_Guarantor_Id__c -w 5
    echo "***** Loading Patients *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Contact_Patient.csv -s Contact -i Patient_Id__c -w 5
    echo "***** FINALLY ... done with loading Contacts *****"
    echo "***** Loading Payment Methods *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Payment_Method.csv -s Payment_Method__c -i Sirono_Id__c -w 5
    echo "***** Loading Invoices *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Invoice.csv -s Invoice__c -i Sirono_Id__c -w 5
    echo "***** Loading Payment Plans *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Payment_Plan.csv -s Payment_Plan__c -i Sirono_Id__c -w 5
    echo "***** Loading Statements *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Statement.csv -s Statement__c -i Sirono_Id__c -w 5
    echo "***** You think this is a lot to load? Think about typing all this crap out! *****"
    echo "***** Loading Charge Groups *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Charge_Group.csv -s Charge_Group__c -i Sirono_Id__c -w 5
    echo "***** Loading Coverages *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Coverage.csv -s Coverage__c -i Sirono_Id__c -w 5
    echo "***** Loading Guarantor Payments *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Payment_Guarantor.csv -s Payment__c -i Sirono_Id__c -w 5
    echo "***** Loading Services *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Service.csv -s Service2__c -i Aggregate_Id__c -w 5
    echo "***** Loading Adjustments *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Adjustment.csv -s Adjustment__c -i Aggregate_Id__c -w 5
    echo "***** Loading Payor Payments *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Payment_Payor.csv -s Payment__c -i Id__c -w 5
    echo "***** Loading Service Transactions *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Transaction_Service.csv -s Transaction__c -i Sirono_Id__c -w 5
    echo "***** Loading Adjustment Transactions *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Transaction_Adjustment.csv -s Transaction__c -i Sirono_Id__c -w 5
    echo "***** Loading Payment Transactions *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Transaction_Payment.csv -s Transaction__c -i Sirono_Id__c -w 5
    echo "***** Almost there ... *****"
    echo "***** Loading Charge Group Junctions *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Charge_Group_Coverage_Junction.csv -s Charge_Group_Coverage_Junction__c -i Sirono_Id__c -w 5
    echo "***** Loading Patient Coverage Junctions *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Patient_Coverage_Junction.csv -s Patient_Coverage_Junction__c -i Sirono_Id__c -w 5
    echo "***** Loading Guarantor Notes *****"
    sfdx force:data:bulk:upsert -u sirono-salesforce -f ./res/temp/load/Contact_Notes.csv -s Contact -i Guarantor_Id__c -w 5
    echo "***** ... and now we're done! *****"
else
    echo "Logging in didn't quite work correctly."
    exit 1
fi
