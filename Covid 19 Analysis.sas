/* Step 1: Importing data from a CSV file into SAS */ proc import 
DATAFILE = "/home/u63566156/MY SAS FILES/SHAPEdata2022.csv" /* Replace your own CSV file path here to run the data*/ OUT = SHAPE2022 /* Output dataset name */ 
DBMS = csv /* Specifies the file type as CSV */ 
REPLACE; /* Replaces the dataset if it already exists */ GETNAMES = yes; /* Uses the first row of the CSV as variable names */ 
run; 
/* Step 2: Display the contents of the SHAPE2022 dataset */ proc contents data = SHAPE2022 varnum; /* Displays variable information in numerical order */ 
run; 
/* Step 3: Calculate descriptive statistics for specified variables */ 
proc means data = SHAPE2022 n nmiss; /* Analyzes SHAPE2022 for number of non-missing (n) and missing (nmiss) values */ var G1 A3 AdultImpact1 AdultImpact2 AdultImpact5 AdultImpact6 HI EthRace5_2022 FI immigrant G9; /* List of variables to analyze */ 
run; 
/* Step 4: Create a new dataset with only immigrants (1st and 2nd generation) */ 
data ImmigrantsOnly; 
set SHAPE2022; /* Set the input dataset */ 
where immigrant in (1,2); /* Filter for 1st and 2nd generation immigrants */ 
run; 
/* Step 5: Calculate descriptive statistics for the ImmigrantsOnly dataset */ 
proc means data = ImmigrantsOnly n nmiss; 
var G1 A3 AdultImpact1 AdultImpact2 AdultImpact5 AdultImpact6 HI EthRace5_2022 FI immigrant G9; /* Same list of variables */ run; 
/* Step 6: Create a dataset (TABLE1) excluding records with missing values for specific variables */ 
data TABLE1;
set ImmigrantsOnly; /* Set the input dataset */ 
if missing(G1) or missing(A3) or missing(AdultImpact1) or missing(AdultImpact2) or missing(AdultImpact5) or missing(HI) or missing(EthRace5_2022) or missing(FI) or missing(AdultImpact6) or missing(immigrant) or missing(G9) then delete; /* Delete records with any missing values in the specified variables */ 
run; 
/* Step 7: Define formats for categorical variables */ proc format; 
value G1sex 1= 'Male' 2= 'Female' 3= 'Non-binary' 4= 'Something else, please specify'; /* Format for gender */ value AdultImpact1f 1= 'Yes' 0='No'; /* Format for adult impact variables */ 
value AdultImpact2f 1= 'Yes' 0='No'; 
value AdultImpact5f 1= 'Yes' 0='No'; 
value AdultImpact6f 1= 'Yes' 0='No'; 
value FI 1='Yes' 0='No'; /* Format for food insecurity */ value EthRace5_2022f 
1 = 'Native' 
2 = 'Hispanic' 
3 = 'Asian' 
4 = 'Black' 
5 = 'White'; /* Format for race/ethnicity */ 
value immigrant 1='1st generation' 
2='2nd generation' 
3='Non immigrants'; /* Format for immigrant 
status */ 
value G9f 1='Yes' 2='No'; /* Format for US/Foreign Born */ PICTURE pctfmt (round) other = "009.9%"; /* Custom format for percentages */ 
/* Step 8: Assign descriptive labels to variables */ label G1="GENDER"; /* Gender label */ 
label AdultImpact1 ="COVID-19 Impact on Adult Physical Health"; /* Label for adult physical health impact */ label AdultImpact2 ="COVID-19 Impact on Adult Mental Health"; /* Label for adult mental health impact */ 
label AdultImpact6 ="Negative Impact on Employment and Income"; /* Employment/income impact */
label AdultImpact5 ="Negative Impact on Housing"; /* Housing impact */ 
label FI ="Food insecurity"; /* Food insecurity label */ label EthRace5_2022 ="Race/Ethnicity"; /* Race/ethnicity label */ 
label immigrant ="Immigrant Status"; /* Immigrant status label */ 
label G9 ="US/Foreign Born"; /* US/Foreign born label */ run; 
/* Step 9: Display the contents of TABLE1 dataset */ proc contents data=TABLE1; 
run; 
/* Step 10: Generate frequency tables for selected variables */ PROC FREQ DATA=TABLE1 order=formatted; /* Frequency analysis */ TABLE EthRace5_2022 G1 FI AdultImpact1 AdultImpact2 AdultImpact5 AdultImpact6 Immigrant; /* List of variables */ format G1 G1sex. AdultImpact1 AdultImpact1f. AdultImpact2 AdultImpact2f. AdultImpact5 AdultImpact5f. AdultImpact6 AdultImpact6f. FI FI. EthRace5_2022 EthRace5_2022f. immigrant immigrant.; /* Apply formats */ 
run; 
/* Step 11: Tabulate immigrants across social determinants of health */ 
proc tabulate data = TABLE1 order=formatted; 
CLASS EthRace5_2022 G1 FI AdultImpact1 AdultImpact2 AdultImpact5 AdultImpact6 /missing; /* Class variables */ CLASSLEV EthRace5_2022 G1 FI AdultImpact1 AdultImpact2 AdultImpact5 AdultImpact6/ style = [asis=on]; /* Class levels with custom style */ 
/* Create a table showing counts and percentages */ TABLE (EthRace5_2022 G1 FI AdultImpact1 AdultImpact2 AdultImpact5 AdultImpact6)*(n = "N" pctn= "%"), (ALL) /misstext="0"; 
format G1 G1sex. AdultImpact1 AdultImpact1f. AdultImpact2 AdultImpact2f. AdultImpact5 AdultImpact5f. AdultImpact6 AdultImpact6f. FI FI. EthRace5_2022 EthRace5_2022f. immigrant immigrant.; /* Apply formats */ 
label G1="GENDER"; /* Reapply labels */ 
label AdultImpact1 ="COVID-19 Impact on Adult Physical Health";
label AdultImpact2 ="COVID-19 Impact on Adult Mental Health"; label AdultImpact6 ="Negative Impact on Employment and Income"; 
label AdultImpact5 ="Negative Impact on Housing"; label FI ="Food insecurity"; 
label EthRace5_2022 ="Race/Ethnicity"; 
label immigrant ="Immigrant Status"; 
run; 
/* Step 12: Generate frequency distribution for EthRace5_2022 */ proc freq data=TABLE1; 
table EthRace5_2022; /* Frequency table for race/ethnicity */ run; 
/* Step 13: Generate frequency tables for various relationships */ 
proc freq data=TABLE1; 
tables EthRace5_2022*AdultImpact5 G1*AdultImpact5 / nocol out= GraphImmigrantRace; /* Chi-square table for housing impact by race and gender */ 
format AdultImpact5 AdultImpact5f. EthRace5_2022 
EthRace5_2022f. G1 G1Sex.; /* Apply formats */ 
label AdultImpact5="Negative Impact of COVID-19 on Housing"; /* Label for housing impact */ 
label EthRace5_2022 ="Race/Ethnicity"; /* Label for race/ethnicity */ 
label G1="Gender"; /* Label for gender */ 
run; 
proc freq data=TABLE1; 
tables G9*AdultImpact6 / nocol out= GraphImmigrantRace; /* Relationship between immigrant status and employment/income impact */ 
format AdultImpact6 AdultImpact6f. G9 G9f.; /* Apply formats */ 
label AdultImpact6="Negative Impact of COVID-19 on Employment/Income"; /* Label for employment/income impact */ label G9="US Born"; /* Label for US born */ 
run; 
proc freq data=TABLE1; 
tables FI*AdultImpact6 FI*AdultImpact5 / nocol out= GraphImmigrantRace; /* Relationships between food insecurity and impacts on employment/income and housing */
format AdultImpact6 AdultImpact6f. AdultImpact5 
AdultImpact6f. FI FI.; /* Apply formats */ 
label AdultImpact5="Negative Impact of COVID-19 on Housing"; /* Label for housing impact */ 
label FI ="Food insecurity"; /* Label for food insecurity */ label AdultImpact6= "Negative Impact of COVID-19 on Employment/Income"; /* Label for employment/income impact */ run; 
proc freq data=TABLE1; 
tables EthRace5_2022*AdultImpact1 / nocol out= 
GraphImmigrantRace; /* Relationship between race/ethnicity and physical health impact */ 
format AdultImpact1 AdultImpact1f. EthRace5_2022 EthRace5_2022f. G1 G1Sex.; /* Apply formats */ 
label AdultImpact1="Negative Impact of COVID-19 on Physical Health"; /* Label for physical health impact */ 
label EthRace5_2022 ="Race/Ethnicity"; /* Label for race/ethnicity */ 
run; 
proc freq data=TABLE1; 
tables EthRace5_2022*AdultImpact2 / nocol out= 
GraphImmigrantRace; /* Relationship between race/ethnicity and mental health impact */ 
format AdultImpact2 AdultImpact2f. EthRace5_2022 EthRace5_2022f. G1 G1Sex.; /* Apply formats */ 
label AdultImpact1="Negative Impact of COVID-19 on Mental Health"; /* Label for mental health impact */ 
label EthRace5_2022 ="Race/Ethnicity"; /* Label for race/ethnicity */ 
run; 
/* STEP14: REGRESSION ANALYSIS*/ 
/* Logistic regression to analyze the impact of race and gender on COVID-19 related hardships in food security, mental health, and housing */ 
/* AdultImpact5 represents the overall COVID-19 impact on food insecurity */ 
proc logistic descending data=TABLE1; 
model AdultImpact5 = EthRace5_2022 G1; /* EthRace5_2022 = Race/Ethnicity, G1 = Gender */ 
run;
/* Logistic regression focusing only on race as a predictor of food insecurity due to COVID-19 */ 
proc logistic descending data=TABLE1; 
model AdultImpact5 = EthRace5_2022; /* Examining racial/ethnic disparities in COVID-19 impact on food insecurity */ run; 
/* Logistic regression assessing race as a predictor of mental health challenges due to COVID-19 */ 
proc logistic descending data=TABLE1; 
model AdultImpact1 = EthRace5_2022; /* AdultImpact1 = COVID-19 impact on mental health */ 
run; 
/* Logistic regression assessing race as a predictor of housing stability challenges due to COVID-19 */ 
proc logistic descending data=TABLE1; 
model AdultImpact2 = EthRace5_2022; /* AdultImpact2 = COVID-19 impact on housing stability */ 
run; 
/* Logistic regression assessing race as a predictor of financial and employment hardships due to COVID-19 */ proc logistic descending data=TABLE1; 
model AdultImpact6 = EthRace5_2022; /* AdultImpact6 = COVID-19 impact on financial and employment stability */ 
run; 
/* Logistic regression assessing the combined effects of multiple COVID-19 impacts on food insecurity */ 
proc logistic descending data=TABLE1; 
model FI = AdultImpact5 AdultImpact6; /* FI = Food Insecurity; AdultImpact5 = COVID-19 impact on food/housing; AdultImpact6 = COVID-19 impact on financial/employment stability */ run;