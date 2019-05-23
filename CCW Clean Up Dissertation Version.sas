libname mbsf "***";
libname dis "****";
/** Starting the process of compiling the dataset for the CMS caregiver project**/
/** January 1 2018 Robert Schuldt**/

data mbsf;
	set mbsf.mbsf_abcd_summary;
		if state_cnty_fips_cd_01 = state_cnty_fips_cd_01 then fips_check = 1;
			else fips_check = 0;
	run;

proc freq data = mbsf;
title 'Check on discrepencies in the Jan to Dec Fips code';
title2 'By patient';
table fips_check;
run;

data mbsf_fips;
	set mbsf;

	/*** There is no change amongst the Fips County Code from Jan to December for all patients, so we can just use this. Do not need
	to merge in the SSA to FIPS crosswalk, because we already have it***/
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
	black hispanic other_race dual part_dual ffs ab_month1 - ab_month12 MDCR_ENTLMT_BUYIN_IND_01 MDCR_ENTLMT_BUYIN_IND_12;
		run;


	

/*** Now we bring in the OASIS data set which will be merged with the MBSF summary file**/
data mbsf.oasis_vars;
	set mbsf.combined_oasis;
	where M0100_ASSMT_REASON = "01";
	keep BENE_ID ASMT_ID ASMT_EFF_DATE M0016_BRANCH_ID M0100_ASSMT_REASON M0090_ASMT_CPLT_DT M0014_BRANCH_STATE M0010_MEDICARE_ID M0030_SOC_DT M0032_ROC_DT M0090_ASMT_CPLT_DT 
	M0150_CPY_MCAIDFFS M0150_CPY_MCAIDHMO M0150_CPY_MCAREFFS M0150_CPY_MCAREHMO M0150_CPY_NONE M0150_CPY_OTH_GOVT M0150_CPY_OTHER M0150_CPY_PRIV_HMO M0150_CPY_PRIV_INS M0150_CPY_SELFPAY M0150_CPY_TITLEPGM
	M0150_CPY_UK M0150_CPY_WRKCOMP M0110_EPSD_TIMING_CD M1000_DC_IPPS_14_DA M1000_DC_IRF_14_DA M1000_DC_LTC_14_DA M1000_DC_LTCH_14_DA M1000_DC_OTH_14_DA M1000_DC_PSYCH_14_DA M1000_DC_SNF_14_DA M1000_DC_NON_14_DA
	M1020_PRI_DGN_ICD M1020_PRI_DGN_SEV M1022_OTH_DGN1_ICD M1022_OTH_DGN1_SEV M1022_OTH_DGN2_ICD M1022_OTH_DGN2_SEV M1022_OTH_DGN3_ICD M1022_OTH_DGN3_SEV M1022_OTH_DGN4_ICD M1022_OTH_DGN4_SEV M1022_OTH_DGN5_ICD M1022_OTH_DGN5_SEV
	M1030_THH_ENT_NUTR M1030_THH_IV_INFUS M1030_THH_NONE_ABV M1030_THH_PAR_NUTR M1034_PTNT_OVRAL_STUS M1036_RSK_Alcohol M1036_RSK_drugs M1036_RSK_none M1036_RSK_obesity M1036_RSK_smoking M1036_RSK_uk M1100_PTNT_LVG_STUTN
	M1242_PAIN_FREQ_ACTVTY_MVMT M1306_UNHLD_stg2_prsr_ulcr m1340_srgcl_wnd_prsnt m1350_lesion_open_wnd m1400_when_dyspnic m1410_resptx_airpr m1410_resptx_none m1410_resptx_oxygn m1410_resptx_vent M1600_uti 
	m1615_incntnt_timing m1620_bwl_incont m1700_cog_function m1730_stdz_dprsn_scrng m1730_phq2_dprsn m1730_phq2_lack_intrst m1740_bd_delusions m1740_bd_imp_dcsn m1740_bd_mem_dfict m1740_bd_none m1740_bd_physical m1740_bd_soc_inapp
	m1740_bd_verbal m1800_cu_grooming m1810_cu_dress_upr m1820_cu_dress_low m1830_crnt_bathg m1840_cur_toiltg m1845_cur_toiltg_hygn m1850_cur_trnsfrng m1860_crnt_ambltn m1870_cu_feeding m1910_mlt_fctr_fall_risk_asmt 
	M2100_CARE_TYPE_SRC_EQUIP M2102_CARE_TYPE_SRC_ADL M2102_CARE_TYPE_SRC_ADVCY M2102_CARE_TYPE_SRC_SPRVSN M2100_CARE_TYPE_SRC_EQUIP m2102_care_type_src_prcdr m2102_care_type_src_mdctn m2110_adl_iadl_astnc_freq M2300_EMER_USE_AFTR_LAST_ASMT
	m2200_thrpy_need_na_num m2200_thrpy_need_num m2410_inpat_fac m2420_dschrg_disp M2100_CARE_TYPE_SRC_IADL;

	/** I believe that Branch_identifier and M0016_BRANCH_ID are same variable **/ 
	run;

/**Merge beneficiary from together keeping only those that are in the OASIS file. **/

proc sort data = mbsf.oasis_vars;
by bene_id;
run;

proc sort data = mbsf.mbsf_crit;
by bene_id;
run;

data mbsf_oasis;
	merge mbsf.mbsf_crit ( in = a) mbsf.oasis_vars (in = b);
	by bene_id;
	if a;
	if b;
	run;

/***
	NOTE: There were 2687102 observations read from the data set WORK.MBSF_CRIT.
	NOTE: There were 10205375 observations read from the data set WORK.OASIS.
	NOTE: The data set WORK.MBSF_OASIS has 8619217 observations and 321 variables.
	NOTE: DATA statement used (Total process time):
      	real time           6:30.71
      	cpu time            23.27 seconds

***/

data mbsf.mbsf_oasis;
	set mbsf_oasis;
	run;

/*** Now to start working on the identfying variables for unmet caregiver needs**/




data p4_var;
	set mbsf.mbsf_oasis;
		/** Array do loop to work through the variables all at once. Increase efficiency **/
		array unor(7) m2102_care_type_src_iadl M2100_CARE_TYPE_SRC_EQUIP m2102_care_type_src_prcdr m2102_care_type_src_mdctn M2102_CARE_TYPE_SRC_ADL M2102_CARE_TYPE_SRC_ADVCY M2102_CARE_TYPE_SRC_SPRVSN;
	array un(7) un_iadl un_equip un_prcdr un_mdctn un_adl un_advcy un_sprvsn;
		do index = 1 to 7;
			if unor(index) = "02" | unor(index) = "03" | unor(index) = "04" | unor(index) = "05" then un(index) = 1;
				else un(index) = 0;
			if unor(index) = "." then un(index) = .;
		end;
			run;
/*** check to make sure the array system worked correctly**/
title 'Check Management Variables for Any Values';
proc freq;
table un_iadl un_equip un_prcdr un_mdctn un_adl un_advcy un_sprvsn;
run;

title 'Check Management Variables for Any Values';
proc freq;
table m2102_care_type_src_iadl M2100_CARE_TYPE_SRC_EQUIP m2102_care_type_src_prcdr m2102_care_type_src_mdctn m2102_care_type_src_adl;
run;

/**
There is no usable data in the variables listed aboce. Messaged Dr. Chen we will use M0100  to check for visit types

**/

data m0100;
	set mbsf.mbsf_oasis;
run;


proc freq;
title 'Check the M0100 variable values';
table M0100_ASSMT_REASON;
run;

data m0100_code;
	set m0100;
		m0100_check = 0;
		if M0100_ASSMT_REASON = "01" then m0100_check = 1;
		if M0100_ASSMT_REASON = "03" then m0100_checl = 1;
		if M0100_ASSMT_REASON = "04" then m0100_checl = 1;
		run;	
		
proc freq;
title 'Check to see if all m0100 were matched';
table m2100_care_type_src_iadl*m0100_checl;
run;

/* start of page five of the sheet provided. Medical Conditions A*/

data p5;
	set m0100_code;
		if M1000_DC_IPPS_14_DA = "1" then psc_hosp = 1; 
			else psc_hosp = 0;
		if M1000_DC_NON_14_DA = "1" then community = 1;
			else community = 0;
		
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
title "Checl what kind of data in Severity Diag";
table M1022_OTH_DGN1_SEV;
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

		alone_0 = 0;
		if M1100_PTNT_LVG_STUTN = "00" then alone_0 = 1;

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
/* Page 8 of the packet variables */


data p8;
	set p7;

		if M2300_EMER_USE_AFTR_LAST_ASMT = "01" then er = 1;
			else er = 0;
		if M2300_EMER_USE_AFTR_LAST_ASMT = "UK" then er =.;

		if m2410_inpat_fac = "01" then hosp = 1;
			else hosp = 0;
		if m2410_inpat_fac = "02" then rehab = 1;
			else rehab = 0;
		if m2410_inpat_fac = "03" then nh = 1;
			else nh = 0;
		if m2410_inpat_fac = "04" then inpt_hospice = 1;
			else inpt_hospice = 0;

		if m2410_inpat_fac = "NA" and m2420_dschrg_disp = "03" then home_hospice1 = 1;
			else home_hospice1 = 0;
		if m2420_dschrg_disp = "03" then home_hospice2 = 1;
			else home_hospice2 = 0;

			run;

data dis.mbsf_oasis_comp;
	set p8;
	run;

	proc freq;
	table m2102_care_type_src_iadl;
	run;
