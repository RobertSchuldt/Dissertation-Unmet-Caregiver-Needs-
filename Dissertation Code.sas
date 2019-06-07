libname mbsf "************";
libname dis "*************";
/** Compiling the dataset for the CMS caregiver dissertation project**/
/** Robert Schuldt**/

data mbsf;
	set mbsf.mbsf_abcd_summary;

		if state_cnty_fips_cd_01 = state_cnty_fips_cd_01 then fips_check = 1;
			else fips_cnty = 0;
	run;

proc freq data = mbsf;
title 'Check on discrepencies in the Jan to Dec Fips code';
title2 'By patient';
table fips_check;
run;

data mbsf_fips;
	set mbsf;
	if STATE_CODE in ('54', '55','56', '57','58','59','60','61','62','63','97','98','99') then delete;

	/*** There is no change amongst the Fips County Code from Jan to December for all patients, so we can just use this. Do not need
	to merge in the SSA to FIPS crosswalk, because we already have it***/
	fips = substr(STATE_CNTY_FIPS_CD_01, 1, 2);
	if fips = 99 then delete;
	fips_state = fipstate(fips);
	fips_cnty = state_cnty_fips_cd_01;
	** Age market **;
	
	if AGE_AT_END_REF_YR >= 65 then age_mark = 1;
		else age_mark = 0;
	 
	**Generating female variable**;
	female = 0;
	if SEX_IDENT_CD = '2' then female = 1;
	if SEX_IDENT_CD = '0' then female = .;
	
	white = 0;
	if rti_race_cd = '1' then white = 1;
	if rti_race_cd = '0' then white = .;

	black = 0;
	if rti_race_cd = '2' then black = 1;
	if rti_race_cd = '0' then black = .;

	hispanic = 0;
	if rti_race_cd = '5' then hispanic = 1;
	if rti_race_cd = '0' then hispanic = .;

	other_race = 0;
	if rti_race_cd = '3' then other_race = 1;
	if rti_race_cd = '4' then other_race = 1;
	if rti_race_cd = '6' then other_race = 1;
	if rti_race_cd = '0' then other_race = .;

	if DUAL_ELGBL_MONS = 12 then dual = 1;
		else dual = 0;
	if 1 <= DUAL_ELGBL_MONS <12 then part_dual = 1;
		else part_dual = 0;

	if BENE_HMO_CVRAGE_TOT_MONS = 0 then ffs= 1;
		else ffs = 0;

		run;
proc freq;
table MDCR_ENTLMT_BUYIN_IND_01;
run;
data part_ab;
	set mbsf_fips;
	array ab(12) MDCR_ENTLMT_BUYIN_IND_01 -- MDCR_ENTLMT_BUYIN_IND_12;
	array partab(12) ab_month1 - ab_month12;
		do index = 1 to 12;
			if ab(index) = "3" | ab(index) = "C" then partab(index) = 1;
				else partab(index) = 0;
		end;
	total_ab = sum(of ab_month1 - ab_month12);
		run;

proc freq;
table total_ab;
run;

data mbsf.mbsf_crit;
	set part_ab;
	where age_mark = 1 and ffs ne 0;
	part_ab_full = 1;
	keep bene_id state_code county_cd zip_cd fips_cnty DUAL_ELGBL_MONS  BENE_HMO_CVRAGE_TOT_MONS age_mark age_at_end_ref_yr bene_death_dt SEX_IDENT_CD female rti_race_cd white 
	black hispanic other_race dual part_dual ffs ab_month1 - ab_month12 MDCR_ENTLMT_BUYIN_IND_01 MDCR_ENTLMT_BUYIN_IND_12 fips fips_state;
		run;
proc contents data = dis.oasis_vars position ;
run;

	

/*** Now we bring in the OASIS data set which will be merged with the MBSF summary file**/
data oasis_vars;
	set mbsf.combined_oasis;
	where M0100_ASSMT_REASON = "01";
	keep BENE_DEATH_DT bene_id count M2102_CARE_TYPE_SRC_ADL M2102_CARE_TYPE_SRC_IADL M2102_CARE_TYPE_SRC_MDCTN M2102_CARE_TYPE_SRC_PRCDR M2102_CARE_ASTNC_EQUIP_CD M2102_CARE_TYPE_SRC_SPRVSN M2102_CARE_TYPE_SRC_ADVCY
    ASMT_ID ASMT_EFF_DATE M0016_BRANCH_ID M0100_ASSMT_REASON M0090_ASMT_CPLT_DT M0014_BRANCH_STATE M0010_MEDICARE_ID M0030_SOC_DT M0032_ROC_DT M0090_ASMT_CPLT_DT 
	M0150_CPY_MCAIDFFS M0150_CPY_MCAIDHMO M0150_CPY_MCAREFFS M0150_CPY_MCAREHMO M0150_CPY_NONE M0150_CPY_OTH_GOVT M0150_CPY_OTHER M0150_CPY_PRIV_HMO M0150_CPY_PRIV_INS M0150_CPY_SELFPAY M0150_CPY_TITLEPGM
	M0150_CPY_UK M0150_CPY_WRKCOMP M0110_EPSD_TIMING_CD M1000_DC_IPPS_14_DA M1000_DC_IRF_14_DA M1000_DC_LTC_14_DA M1000_DC_LTCH_14_DA M1000_DC_OTH_14_DA M1000_DC_PSYCH_14_DA M1000_DC_SNF_14_DA M1000_DC_NON_14_DA
	M1020_PRI_DGN_ICD M1020_PRI_DGN_SEV M1022_OTH_DGN1_ICD M1022_OTH_DGN1_SEV M1022_OTH_DGN2_ICD M1022_OTH_DGN2_SEV M1022_OTH_DGN3_ICD M1022_OTH_DGN3_SEV M1022_OTH_DGN4_ICD M1022_OTH_DGN4_SEV M1022_OTH_DGN5_ICD M1022_OTH_DGN5_SEV
	M1030_THH_ENT_NUTR M1030_THH_IV_INFUS M1030_THH_NONE_ABV M1030_THH_PAR_NUTR M1034_PTNT_OVRAL_STUS M1036_RSK_Alcohol M1036_RSK_drugs M1036_RSK_none M1036_RSK_obesity M1036_RSK_smoking M1036_RSK_uk M1100_PTNT_LVG_STUTN
	M1242_PAIN_FREQ_ACTVTY_MVMT M1306_UNHLD_stg2_prsr_ulcr m1340_srgcl_wnd_prsnt m1350_lesion_open_wnd m1400_when_dyspnic m1410_resptx_airpr m1410_resptx_none m1410_resptx_oxygn m1410_resptx_vent M1600_uti 
	m1615_incntnt_timing m1620_bwl_incont m1700_cog_function m1730_stdz_dprsn_scrng m1730_phq2_dprsn m1730_phq2_lack_intrst m1740_bd_delusions m1740_bd_imp_dcsn m1740_bd_mem_dfict m1740_bd_none m1740_bd_physical m1740_bd_soc_inapp
	m1740_bd_verbal m1800_cu_grooming m1810_cu_dress_upr m1820_cu_dress_low m1830_crnt_bathg m1840_cur_toiltg m1845_cur_toiltg_hygn m1850_cur_trnsfrng m1860_crnt_ambltn m1870_cu_feeding m1910_mlt_fctr_fall_risk_asmt;

	count = 1;

	run;
proc sql;
create table oasis_count as
select *, 
sum(count) as total_hhc_episodes
from oasis_vars
group by bene_id;
quit;

data dis.oasis_vars;
	set oasis_count;
where M0100_ASSMT_REASON = "01";
	run;

	proc freq;
	table total_hhc_episodes;
	run;

/**Merge beneficiary from together keeping only those that are in the OASIS file. **/

proc sort data = dis.oasis_vars;
by bene_id;
run;

proc sort data = mbsf.mbsf_crit;
by bene_id;
run;

data mbsf_oasis;
	merge mbsf.mbsf_crit ( in = a) dis.oasis_vars (in = b);
	by bene_id;
	if a;
	if b;
	run;

/***
	NOTE: There were 2687102 observations read from the data set WORK.MBSF_CRIT.
	NOTE: There were  3372447 observations read from the data set WORK.OASIS.
	 The data set WORK.MBSF_OASIS has 2933963 observations and 136 variables.

***/
proc sort data = mbsf_oasis;
by bene_id ASMT_EFF_DATE;
run;

proc sort data = mbsf_oasis nodupkey;
by bene_id;
run;

proc sql;
create table fips_pats as 
select *,
sum(count) as pat_per_fip
from  mbsf_oasis
group by fips_cnty;
quit;

proc sort data = fips_pats out = represent nodupkey;
by fips_cnty;
run;

proc freq data = represent;
table count;
where pat_per_fip >=20;
run;

data dis.mbsf_oasis;
	set fips_pats;
	run;

/*** Now to start working on the identfying variables for unmet caregiver needs**/
data measures;
	set dis.mbsf_oasis;
		/** Array do loop to work through the variables all at once. Increase efficiency **/
		array unor(7) M2102_CARE_TYPE_SRC_ADL M2102_CARE_TYPE_SRC_IADL M2102_CARE_TYPE_SRC_MDCTN M2102_CARE_TYPE_SRC_PRCDR M2102_CARE_ASTNC_EQUIP_CD M2102_CARE_TYPE_SRC_SPRVSN M2102_CARE_TYPE_SRC_ADVCY;
	array un(7) un_adl un_iadl un_mdctn un_equip un_prcdr un_sprvsn un_advcy;
		do index = 1 to 7;
			if unor(index) = "02" | unor(index) = "03" | unor(index) = "04" | unor(index) = "05" then un(index) = 1;
				else un(index) = 0;
			if unor(index) = "." then un(index) = .;
		end;
			run;
/*** check to make sure the array system worked correctly**/
title 'Check Management Variables for Any Values';
proc freq data = measures ;
table un_adl un_iadl un_mdctn un_equip un_prcdr un_sprvsn un_advcy;
run;
/* Insure I have only start of care assessments*/
proc freq;
title 'Check the M0100 variable values';
table M0100_ASSMT_REASON;
run;
/* Identify where patient is sourced from whether they are post-acute or a community based patient*/
data p5;
	set measures;
		if M1000_DC_IPPS_14_DA = "1" then post_acute_pat = 1; 
			else post_acute_pat = 0;
		if M1000_DC_NON_14_DA = "1" then community_pat = 1;
			else community_pat = 0;
		
		psc_other = 0;
		if M1000_DC_IRF_14_DA = "1" then psc_other = 1;
        if M1000_DC_LTC_14_DA = "1" then psc_other = 1;
		if M1000_DC_LTCH_14_DA = "1" then psc_other = 1;
		if M1000_DC_OTH_14_DA = "1" then psc_other = 1;
		if M1000_DC_PSYCH_14_DA = "1" then psc_other = 1; 
		if M1000_DC_SNF_14_DA = "1" then psc_other = 1;
			run;
		
proc freq;
title 'Check newly minted variables';
table psc_other psc_hosp community;
run;

proc freq; 
title "Check what kind of data in Severity Diag";
table M1022_OTH_DGN1_SEV M1100_PTNT_LVG_STUTN;
run;

/* Diagnosis Severity variable*/
data p5_2;
	set p5;
		if M1020_PRI_DGN_SEV = "02" then p_sever_mid = 1;
			else p_sever_mid = 0;
		if M1020_PRI_DGN_SEV = "03" or M1020_PRI_DGN_SEV = "04" then p_sever_high = 1;
			else p_sever_high = 0;
	
	 	nd_sever_high = 0;
	 		if M1022_OTH_DGN1_SEV = "03" then nd_sever_high = 1;
			if M1022_OTH_DGN2_SEV = "03" then nd_sever_high = 1;
			if M1022_OTH_DGN3_SEV = "03" then nd_sever_high = 1;
			if M1022_OTH_DGN4_SEV = "03" then nd_sever_high = 1;
			if M1022_OTH_DGN5_SEV = "03" then nd_sever_high = 1;
	 		
			if M1022_OTH_DGN1_SEV = "04" then nd_sever_high = 1;
			if M1022_OTH_DGN2_SEV = "04" then nd_sever_high = 1;
			if M1022_OTH_DGN3_SEV = "04" then nd_sever_high = 1;
			if M1022_OTH_DGN4_SEV = "04" then nd_sever_high = 1;
			if M1022_OTH_DGN5_SEV = "04" then nd_sever_high = 1;

		nutrition = 0;
		if M1030_THH_ENT_NUTR = "1" then nutrition = 1;
		if M1030_THH_IV_INFUS  = "1" then nutrition = 1;
		if M1030_THH_NONE_ABV  = "1" then nutrition = 1;
		if M1030_THH_PAR_NUTR  = "1" then nutrition = 1;

		stable = 0;
		if M1034_PTNT_OVRAL_STUS = '00' then stable = 1;
		if M1034_PTNT_OVRAL_STUS = '01' then stable = 1;
		if M1034_PTNT_OVRAL_STUS = '.' then stable = .;

		 
		risk = 0;
		if M1036_RSK_Alcohol = '1' then risk = 1;
		if M1036_RSK_drugs = '1' then risk = 1; 
		if M1036_RSK_obesity =  '1' then risk = 1;
		if M1036_RSK_smoking = '1' then risk = 1;
		if M1036_RSK_uk = '1' then risk = .;
		
		lives_with = 0;
		if M1100_PTNT_LVG_STUTN = "06" or "07" or "08" or "09" or "10" then lives_with = 1; 

		alone_ass = 0;
		if M1100_PTNT_LVG_STUTN = "01" then alone_ass = 1;
		if M1100_PTNT_LVG_STUTN = "02" then alone_ass = 1;
		if M1100_PTNT_LVG_STUTN = "03" then alone_ass = 1;
		if M1100_PTNT_LVG_STUTN = "04" then alone_ass = 1;

		pain1 = 0;
		if M1242_PAIN_FREQ_ACTVTY_MVMT = '02' then pain1 = 1;
		if M1242_PAIN_FREQ_ACTVTY_MVMT = '03' then pain1 = 1;

		pain2 = 0;
		if M1242_PAIN_FREQ_ACTVTY_MVMT = '04' then pain2 = 1;

			run;
/** moving on to variables on page 6 of the paper */
data p6;
	set p5_2;


		if M1306_UNHLD_stg2_prsr_ulcr = "1" then ulcer2_up = 1;
			else ulcer2_up = 0;

		surg_wd_lesion = 0;
		if m1340_srgcl_wnd_prsnt = "01" or m1340_srgcl_wnd_prsnt = "02" then surg_wd_lesion = 1;
		if m1350_lesion_open_wnd = "01" then surg_wd_lesion = 1;

		dyspenic = 0;
		if m1400_when_dyspnic = "02" or m1400_when_dyspnic = "03" or m1400_when_dyspnic = "04" then dyspenic = 1;
		
		respritory = 0;
		if m1410_resptx_airpr = "1" then respritory = 1;
 		if m1410_resptx_oxygn  = "1" then respritory = 1;
		if m1410_resptx_vent = "1" then respritory = 1;

		uti = 0;
		if  M1600_uti = "01" then uti = 1;
		if   M1600_uti   = "." or  M1600_uti  = "UK" then uti = .;
		
	
		if m1615_incntnt_timing = "02" or m1615_incntnt_timing = "03" or m1615_incntnt_timing = "04" then u_incntn = 1;
			else u_incntn = 0;
		if m1620_bwl_incont = "02" or m1620_bwl_incont = "03" or m1620_bwl_incont ="04" or m1620_bwl_incont = "05" then bwl_incntn = 1;
			else bwl_incntn = 0;

		if m1700_cog_function = "01" or m1700_cog_function = "02" then cog_fun_mild = 1;
			else cog_fun_mild = 0;

		if m1700_cog_function = "03" or m1700_cog_function = "04" then cog_fun_high = 1;
			else cog_fun_high = 0;

		if  m1730_phq2_dprsn = "01" THEN depression_mid = 1;
			else depression_mid = 0;
		if  m1730_phq2_dprsn = "NA" THEN depression_mid = .;

		if  m1730_phq2_dprsn = "02" or  m1730_phq2_dprsn = "03" THEN depression_high = 1;
			else depression_high = 0;
		if  m1730_phq2_dprsn = "NA" THEN depression_high = .;
		
		d_impaired = 0; 
		if m1740_bd_delusions = "1" then bd_impaired = 1;
		if m1740_bd_imp_dcsn  = "1" then bd_impaired = 1;
		if m1740_bd_mem_dfict   = "1" then bd_impaired = 1;
		if m1740_bd_physical  = "1" then bd_impaired = 1;
		if m1740_bd_soc_inapp = "1" then bd_impaired = 1;
		if m1740_bd_delusions = "1" then bd_impaired = 1;
		if m1740_bd_verbal = "1" then bd_impaired = 1;

		run;
/* Page 7 of the packet variables */
data p7;
	set p6;

	if m1800_cu_grooming = "01" or m1800_cu_grooming = "02" or m1800_cu_grooming = "03" then groom = 1;
		else groom = 0;

	if m1810_cu_dress_upr = "01" or m1810_cu_dress_upr = "02" or m1810_cu_dress_upr = "03" then dress_up = 1;
		else dress_up = 0;

	if m1820_cu_dress_low = "01" or m1820_cu_dress_low = "02" or m1820_cu_dress_low = "03" then dress_down = 1;
		else dress_down = 0;

	if m1830_crnt_bathg = "02" or m1830_crnt_bathg = "03" or m1830_crnt_bathg = "04" or m1830_crnt_bathg = "05" then bath = 1;
		else bath = 0;

	if m1840_cur_toiltg = "01" or m1840_cur_toiltg = "02" or m1840_cur_toiltg = "03" or m1840_cur_toiltg = "04" then toliet = 1;
		else toliet = 0;

	if m1845_cur_toiltg_hygn = "01" or m1845_cur_toiltg_hygn = "02"  or m1845_cur_toiltg_hygn = "03" then hygiene = 1;
		else hygiene = 0;
 
	if m1850_cur_trnsfrng = "02" or m1850_cur_trnsfrng = "03" or m1850_cur_trnsfrng= "04" or m1850_cur_trnsfrng = "05" then transfer = 1;
		else transfer = 0;

	if m1860_crnt_ambltn = "02" or m1860_crnt_ambltn = "03" or m1860_crnt_ambltn = "04" or m1860_crnt_ambltn = "05" or m1860_crnt_ambltn = "06" then ambu = 1;
		else ambu = 0;

	if m1870_cu_feeding = "01" or m1870_cu_feeding = "02" or m1870_cu_feeding = "03" or m1870_cu_feeding = "04" or m1870_cu_feeding = "05" then feeding = 1;
		else feeding = 0;

	if m1910_mlt_fctr_fall_risk_asmt = "02" then fall_risk = 1;
		else fall_risk = 0;

			run;
/* Completed building of the OASIS data set now I need to drop observations in december or from prior year*/
data dis.mbsf_oasis_comp;
	set p7;
	if M0030_SOC_DT lt '01JAN2015'd or M0030_SOC_DT gt '01DEC2015'd then delete;
	run;

/*Now it is time to bring in the MedPAR data set to get the information about */ 

/* Identifying where patients went.  */


%include '*********************';


data medpar (compress = yes);
	set mbsf.medpar_all_file;
		
run;

/*I want to get only those hospitalizations that were within the time frame that we need for this study.
As such I want to merge Bene ID and SOC date so I can clean up hospitalizations that do not matter from 
the medpar data set*/

data clean_medpar;
	set dis.mbsf_oasis_comp;
	keep bene_id M0030_SOC_DT;
run;
%sort(medpar, bene_id)
%sort(clean_medpar, bene_id)
data medpar_keep (compress = yes);
 merge clean_medpar (in = a) medpar (in = b);
 by bene_id;
 if a;
 if b;
 run;

data medpar_keep2;
	set medpar_keep;
		soc_plus = M0030_SOC_DT+60;
		if ADMSN_DT ne . and (ADMSN_DT lt M0030_SOC_DT or ADMSN_DT gt soc_plus) then delete;
	run;

%sort(medpar_keep2, bene_id)
%sort(dis.mbsf_oasis_comp, bene_id)
/*Only merge one way because some patients never acrued inpatient chargers*/
data medpar_oasis (compress = yes);
 merge dis.mbsf_oasis_comp (in = a) medpar_keep2 (in = b);
 by bene_id;
 if a;
 run;

data dis.full_set;
	set medpar_oasis;
			%let prev = TAPQ01 TAPQ02 TAPQ03 TAPQ05 TAPQ07 TAPQ08 TAPQ10 TAPQ11 TAPQ12 TAPQ14 TAPQ15 TAPQ16;
				array cond  &prev;
					do over cond;
						if cond = 1 then preventable_hosp = 1;
					end;
		
			/*Identify whether the stay is a short or long stay or snf*/
			
			if SS_LS_SNF_IND_CD = "S" then hosp_stay = 1;
				else hosp_stay = 0;
			if SS_LS_SNF_IND_CD = "N" then snf_stay = 1;
				else snf_stay = 0;

			if SS_LS_SNF_IND_CD = "L"  then long_stay =1;
				else long_stay = 0;

			if SS_LS_SNF_IND_CD = "S" or SS_LS_SNF_IND_CD = "N" or SS_LS_SNF_IND_CD = "L" then any_hosp_stay = 1;
				else any_stay = 0;

			if BENE_DEATH_DT ne . and (BENE_DEATH_DT gt M0030_SOC_DT or BENE_DEATH_DT lt soc_plus) then death = 1;
				else death = 0;
	run;
/*Check for duplicates of the beneficairies*/
	PROC FREQ;
 TABLES bene_id / noprint out=keylist;
RUN;
PROC PRINT;
 WHERE count ge 2;
RUN; 
/* The following code will eliminate multiple hospitalizations in the Episode time frame keeping only the first admittance*/

proc sort data = dis.full_set; 
by bene_id ADMSN_DT;
run;

proc sort data = dis.full_set nodupkey;
by bene_id;
run;

/* Can decide if we want to keep the above code or not*/

proc freq;
table hosp_stay snf_stay long_stay death;
run;

proc contents position;
run;

/*pull in the agency ID and the POS file to identify agency type*/
libname pos '****************';

data pos;
	set pos.pos_2015 ;
		where PRVDR_CTGRY_SBTYP_CD = "01";

		keep GNRL_CNTL_TYPE_CD FIPS_STATE_CD FIPS_CNTY_CD BED_CNT  CRTFCTN_DT prvdr_num M0010_MEDICARE_ID ;
		rename prvdr_num = M0010_MEDICARE_ID;
					run;

%sort(pos, M0010_MEDICARE_ID)
%sort(dis.full_set, M0010_MEDICARE_ID)

data agency_type;
	merge dis.full_set (in = a) pos (in = b);
	by M0010_MEDICARE_ID;
	if a;
	run;

data agency_check;
	set agency_type;
	 if M0010_MEDICARE_ID = "000000" then delete;

	if GNRL_CNTL_TYPE_CD = '01' or GNRL_CNTL_TYPE_CD = '02' or GNRL_CNTL_TYPE_CD = '03' then nfp = 2;
		else nfp = 0;
	if GNRL_CNTL_TYPE_CD = '04' then fp = 1;
		else fp = 0;
	if GNRL_CNTL_TYPE_CD = '05'  or GNRL_CNTL_TYPE_CD = '06' or GNRL_CNTL_TYPE_CD = '07' then gov = 3;
		else gov = 0;
	if GNRL_CNTL_TYPE_CD = '08' or GNRL_CNTL_TYPE_CD = '09' or GNRL_CNTL_TYPE_CD = '10' then other = 4;
		else other = 0;

	if GNRL_CNTL_TYPE_CD = ' ' then missing = 1;

	outcomes = 'None';
	if hosp_stay = 1 then outcomes = "Hospital";
	if snf_stay= 1 then outcomes = "SNF";
	if long_stay = 1 then outcomes = "Long Stay";
	if death = 1 then outcomes = "Death";
run;

proc freq;
table nfp fp gov other;
run;
/*I Have some medicare agencies that do not match up to the POS file. Do I want to eliminate these observations?*/
proc freq;
title ' check to see what types of patients have negative outcome';
table hosp_stay snf_stay long_stay death;
where community_pat = 1;
run;

proc freq;
title ' check to see what types of patients have negative outcome';
table hosp_stay snf_stay long_stay death;
where post_acute_pat = 1;
run;

title 'Patient Outcomes by Type of Patient';
proc tabulate data = agency_check;
class outcomes;
var  post_acute_pat community_pat psc_other;
table outcomes, (post_acute_pat community_pat psc_other)*(N PCTSUM);
run;
