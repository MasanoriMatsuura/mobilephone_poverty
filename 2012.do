/*create dataset for regression*/
/*Author: Masanori Matsuura*/
clear all
set more off
*set the pathes
global climate = "C:\Users\user\Documents\Masterthesis\climatebang"
global BIHS18Community = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2018\dataverse_files\BIHSRound3\Community"
global BIHS18Female = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2018\dataverse_files\BIHSRound3\Female"
global BIHS18Male = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2018\dataverse_files\BIHSRound3\Male"
global BIHS15 = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2015"
global BIHS12 = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2012"
cd "CC:\Users\user\Documents\research\saiful\dynamics\BIHS\Do"

*BIHS2012 data cleaning 
**keep geographical code
use $BIHS12\001_mod_a_male, clear
keep a01 div dcode District_Name uzcode uncode vcode_n
rename (div vcode_n)(dvcode Village)
save 2012, replace

** keep age gender education occupation of HH
use $BIHS12\003_mod_b1_male.dta, clear
bysort a01: egen hh_size=count(a01)
label var hh_size "Household size"
keep if b1_03==1 
keep a01 mid b1_01 b1_02 b1_04 b1_08 b1_10 hh_size
rename (b1_01 b1_02 b1_04 b1_08 b1_10 )(gender_hh age_hh marital_hh edu_hh ocu_hh )
recode edu_hh(99=0 "Non-schooling") (22=5)(33=9)(66=0 "Non-schooling")(67=0 "Non-schooling")(74=16)(76=.)(99=0 "Non-schooling"), gen(schll_hh) // convert  education into schoolling year 
label var age_hh "Age of HH"
label var schll_hh "Schooling year of HH"
recode gender_hh (1=1 "Man")(2=0 "Woman"), gen(Male)
label var Male "Male(=1)"
save sciec12.dta, replace


**keep agronomic variables
use $BIHS12\010_mod_g_male, clear
collapse (sum) farmsize=g02 ,by(a01)
label var farmsize "Farm Size(decimal)"
gen ln_farm=log(farmsize)
label var ln_farm "Farm size(log)"
save agrnmic12.dta, replace

/*Irrigation*/
use $BIHS12\012_mod_h2_male.dta, clear
recode h2_02 (1=0 "No") (nonm=1 "Yes"), gen(irri)
label var irri "Irrigation(=1)"
collapse (sum) i1=irri, by(a01)
recode i1 (0=0 "No")(nonm=1 "Yes"), gen(irrigation)
label var irrigation "Irrigation(=1)"
keep a01 irrigation
save irri12.dta, replace

**non-earned income
use $BIHS12\044_mod_v4_male, clear
drop sample_type
bysort a01: gen nnearn=v4_01+v4_02+v4_03+v4_04+v4_05+v4_06+v4_07+v4_08+v4_09+v4_10+v4_11+v4_12+v4_13
label var nnearn "Non-earned income"
keep a01 nnearn
save nnrn12.dta, replace //non-earned  income

**remittance
use $BIHS12\042_mod_v2_male, clear
keep a01 v2_06
bysort a01: egen remi=sum(v2_06)
duplicates drop a01, force
label var remi "remittance"
save rem12.dta, replace

**social safety net program
use $BIHS12\040_mod_u_male.dta, replace
bysort a01: gen trsfr=sum(u02)
label var trsfr "Social safety net program transfer"
keep a01 trsfr
duplicates drop a01, force
save ssnp12.dta, replace

**crop type, farm income and diversification
use $BIHS12\011_mod_h1_male.dta , clear // crop type
keep a01 crop_a crop_b h1_02 h1_03
rename (h1_02 h1_03)(crp_typ plntd)
bysort a01 crop_a: egen typ_plntd=sum(plntd)
duplicates drop a01 crop_a, force
bysort a01: egen crpdivnm=count(crop_a) //crop diversification (Number of crop species including vegetables and fruits produced by the household in the last year (number))
label var crpdivnm "Crop diversity"
keep a01 crpdivnm
duplicates drop a01, force
save crp12.dta, replace

use $BIHS12\011_mod_h1_male, clear //crop diversification 
keep a01 crop_a crop_b h1_03
rename  h1_03 plntd
collapse (sum) typ_plntd=plntd, by(a01 crop_a)
/*bysort a01 crop_a: egen typ_plntd=sum(plntd) //area of each crop */
label var typ_plntd "Area of each crop"
bysort a01: egen ttl_frm=sum(typ_plntd)  //total planted area
label var ttl_frm "total farm area"

gen es=(typ_plntd/ttl_frm)^2
label var es "enterprise share (planted area)"
bysort a01: egen es_crp=sum(es) 
label var es_crp "Herfindahl-Hirschman index (crop)"
drop if crop_a==.
gen crp_div=1-es_crp
label var crp_div "Crop Diversification Index"
keep a01 crp_div
duplicates drop a01, force
hist crp_div
save crp_div12.dta, replace

use $BIHS12\028_mod_m1_male, clear //crop income
keep a01 m1_02 m1_10 m1_18 m1_20
collapse (sum) crp_vl=m1_10 (mean) dstnc_sll_=m1_18 trnsctn=m1_20,by(a01)
label var crp_vl "farm income"
label var dstnc_sll_ "distance to selling place" 
label var trnsctn "transaction time"
save crpincm12.dta, replace

/*use $BIHS15\039_r2_mod_m1_male, clear //crop income diversification 
keep a01 m1_10
bysort a01: egen ttl_frminc=sum(m1_10) 
label var ttl_frminc "total farm income"
gen es=(m1_10/ttl_frminc)^2
label var es "enterprise share (farm income)"
bysort a01: egen es1=sum(es)
drop if m1_10==.
hist es1 */

**market access 
use $BIHS12\028_mod_m1_male.dta, clear //Marketing of Paddy, Rice, Banana, Mango, and Potato
keep a01 m1_16 m1_18
recode m1_16 (2/5=1 "yes")(nonm=0 "no"), gen(market)
bysort a01: egen market_participation=sum(market) 
recode market_participation (1/max=1 "Yes")(nonm=0 "No"), gen(marketp1)
duplicates drop a01, force 
keep a01 marketp1
save marketstaple12.dta, replace
use $BIHS12\029_mod_m2_male.dta, clear //Marketing of Livestock, Jute, Wheat, Pulses, Fish, Fruits, Vegetable
keep a01 m2_16 m2_18
recode m2_16 (2/5=1 "yes")(nonm=0 "no"), gen(market)
bysort a01: egen market_participation=sum(market) 
recode market_participation (1/max=1 "Yes")(nonm=0 "No"), gen(marketp2)
duplicates drop a01, force 
keep a01 marketp2
merge 1:1 a01 using marketstaple15, nogen
gen mrkt=marketp1+marketp2
recode mrkt (1/max=1 "yes")(nonm=0 "no"), gen(marketp)
keep a01 marketp
save mrkt12, replace

*access to facility
use $BIHS12\037_mod_s_male, clear
keep a01 s_01 s_06
keep if s_01==3 
drop s_01
rename s_06 road
label var road "Road access (minute)"
tempfile cal
save `cal'
use $BIHS12\037_mod_s_male, clear
keep a01 s_01 s_06
keep if s_01==6 
drop s_01
rename s_06 market
label var market "Market access (minute)"
merge 1:1 a01 using `cal', nogen
save facility12, replace
use $BIHS12\037_mod_s_male, clear
keep a01 s_01 s_06
keep if s_01==7 
drop s_01
rename s_06 town
label var town "Distance to near town (minute)"
tempfile town
save `town'
use $BIHS12\037_mod_s_male, clear
keep a01 s_01 s_06
keep if s_01==9 
drop s_01
rename s_06 agri
label var agri "Agricultural office (minute)"
merge 1:1 a01 using facility12, nogen
merge 1:1 a01 using `town', nogen
save facility12, replace


**Agricultural extension
use $BIHS12\021_mod_j1_male, clear 
keep a01 j1_01 j1_04
recode j1_01 (1=1 "yes")(nonm=0 "no"), gen(agent)
recode j1_04 (1=1 "yes")(nonm=0 "no"), gen(phone)
gen aes=agent+phone
recode aes (1/max=1 "yes")(nonm=0 "no"), gen(extension)
label var extension "Access to agricultural extension service (=1 if yes)"
keep a01 extension
save extension12, replace

**keep livestock variables
use $BIHS12\023_mod_k1_male.dta, clear //animal
bysort a01: gen livstck=sum(k1_04)
recode livstck (1/max=1 "yes")(0=0 "no"),gen(lvstck)
label var lvstck "Livestock ownership(=1)"
keep a01 livestock k1_18 lvstck
save lvstck12.dta, replace
keep a01 lvstck
duplicates drop a01, force
save lvstckown12.dta, replace //ownership

/*Livestock product*/
use $BIHS12\024_mod_k2_male.dta , clear //milk and egg but no data
keep a01 k2_12 bprod
rename bprod livestock
save lvstckpr12.dta, replace

/*create livestock income*/
use lvstck12, clear //create livestock income
rename k1_18 k2_12 //rename livestock income
keep a01 k2_12 livestock
append using lvstckpr12.dta //append using lvstckpr_12.dta
save eli12, replace //save a file for farm diversification index

bysort a01: egen ttllvstck=sum(k2_12) // livestock product income
label var ttllvstck "Livestock income"
drop k2_12
duplicates drop a01, force
save lvinc12.dta, replace
use lvstckown12.dta, clear //merge currently ownership and livestock income
merge 1:1 a01 using lvinc12, nogen
save lvstckinc12.dta, replace

**livestock diversificatioin
use $BIHS12\023_mod_k1_male.dta, clear 
drop if k1_04==0
bysort a01: egen livdiv=count(livestock)
keep a01 livdiv
duplicates drop a01, force
save livdiv12.dta, replace

/*fishery income*/
use $BIHS12\027_mod_l2_male.dta, clear
bysort a01:egen fshinc=sum(l2_12)
bysort a01:egen fshdiv=count(l2_01)
keep a01 fshdiv fshinc
label var fshdiv "fish diversification"
label var fshinc "fishery income"
duplicates drop a01, force
save fsh12.dta, replace

**keep non-farm wage
use $BIHS12\005_mod_c_male.dta, clear
keep a01 c14
replace c14=0 if c14==.
bysort a01: egen nnfrminc=sum(c14)
keep a01 nnfrminc
label var nnfrminc "non-farm wage"
duplicates drop a01, force
save nnfrminc12.dta, replace

**keep farm wage
use $BIHS12\005_mod_c_male.dta, clear
keep if c05== 1 
keep a01 c14
replace c14=0 if c14==.
bysort a01: egen frmwage=sum(c14) 
keep a01 frmwage
label var frmwage "farm wage"
duplicates drop a01, force
save frmwage12.dta, replace

/*Non-agricultural enterprise*/
use $BIHS12\030_mod_n_male.dta, clear
bysort a01: egen nnagent=sum(n05)
label var nnagent "non-agricultural enterprise"
keep a01 nnagent
duplicates drop a01, force
save nnagent12.dta, replace

**off-farm income
use $BIHS12\005_mod_c_male.dta, clear
keep a01 c14
gen yc14=12*c14
bysort a01: egen offrminc=sum(yc14)
label var offrminc "Off-farm income "
keep a01 offrminc
duplicates drop a01, force
save offfrm12.dta, replace

/*food consumption*/
use $BIHS12/049_mod_x1_female.dta, clear
recode x1_07_01 (1/16 277/297 303/305 323 901 2771/2779 2781/2789 2791/2799 2801/2809 2811/2819 2841/2843 2851/2859 2861/2863 2871/2879 2891/2896 2901/2909 2951/2952 2961 2971 2981/2899 3031 3032=1 "Cereals")(41/61 302 621 622 3231 =2 "White roots and tubers")( 63/82 86/115 298 300 441 904 905 2921/2923 2881/2889 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 299 317/320 2911/2919 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3129 =10 "Oils and fats")(303/11 321=11 "Sweets")(246/251 253/264 266/276 300 301 314/316 318 319 910 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(fx1_07_01) // categorize ingredients
keep a01 fx1_07_01 
duplicates drop a01 fx1_07_01, force
rename fx1_07_01 item
save fd12.dta, replace

use $BIHS12/049_mod_x1_female.dta, clear
recode x1_07_02 (1/16 277/297 303/305 323 901 2771/2779 2781/2789 2791/2799 2801/2809 2811/2819 2841/2843 2851/2859 2861/2863 2871/2879 2891/2896 2901/2909 2951/2952 2961 2971 2981/2899 3031 3032=1 "Cereals")(41/61 302 621 622 3231 =2 "White roots and tubers")( 63/82 86/115 298 300 441 904 905 2921/2923 2881/2889 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 299 317/320 2911/2919 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3129 =10 "Oils and fats")(303/11 321=11 "Sweets")(246/251 253/264 266/276 300 301 314/316 318 319 910 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(fx1_07_02) // categorize ingredients
keep a01 fx1_07_02 
duplicates drop a01 fx1_07_02, force
rename fx1_07_02 item
tempfile hdds212
save hdd212, replace

use $BIHS12/049_mod_x1_female.dta, clear
recode x1_07_03 (1/16 277/297 303/305 323 901 2771/2779 2781/2789 2791/2799 2801/2809 2811/2819 2841/2843 2851/2859 2861/2863 2871/2879 2891/2896 2901/2909 2951/2952 2961 2971 2981/2899 3031 3032=1 "Cereals")(41/61 302 621 622 3231 =2 "White roots and tubers")( 63/82 86/115 298 300 441 904 905 2921/2923 2881/2889 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 299 317/320 2911/2919 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3129 =10 "Oils and fats")(303/11 321=11 "Sweets")(246/251 253/264 266/276 300 301 314/316 318 319 910 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(fx1_07_03) // categorize ingredients
keep a01 fx1_07_03 
duplicates drop a01 fx1_07_03, force
rename fx1_07_03 item
tempfile hdds312
save hdd312, replace

use $BIHS12/049_mod_x1_female.dta, clear
recode x1_07_04 (1/16 277/297 303/305 323 901 2771/2779 2781/2789 2791/2799 2801/2809 2811/2819 2841/2843 2851/2859 2861/2863 2871/2879 2891/2896 2901/2909 2951/2952 2961 2971 2981/2899 3031 3032=1 "Cereals")(41/61 302 621 622 3231 =2 "White roots and tubers")( 63/82 86/115 298 300 441 904 905 2921/2923 2881/2889 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 299 317/320 2911/2919 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3129 =10 "Oils and fats")(303/11 321=11 "Sweets")(246/251 253/264 266/276 300 301 314/316 318 319 910 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(fx1_07_04) // categorize ingredients
keep a01 fx1_07_04 
duplicates drop a01 fx1_07_04, force
rename fx1_07_04 item
tempfile hdds412
save hdd412, replace

use $BIHS12/049_mod_x1_female.dta, clear
recode x1_07_05(1/16 277/297 303/305 323 901 2771/2779 2781/2789 2791/2799 2801/2809 2811/2819 2841/2843 2851/2859 2861/2863 2871/2879 2891/2896 2901/2909 2951/2952 2961 2971 2981/2899 3031 3032=1 "Cereals")(41/61 302 621 622 3231 =2 "White roots and tubers")( 63/82 86/115 298 300 441 904 905 2921/2923 2881/2889 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 299 317/320 2911/2919 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3129 =10 "Oils and fats")(303/11 321=11 "Sweets")(246/251 253/264 266/276 300 301 314/316 318 319 910 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(fx1_07_05) // categorize ingredients
keep a01 fx1_07_05 
duplicates drop a01 fx1_07_05, force
rename fx1_07_05 item
tempfile hdds212
save hdd512, replace

use $BIHS12/049_mod_x1_female.dta, clear
recode x1_07_06 (1/16 277/297 303/305 323 901 2771/2779 2781/2789 2791/2799 2801/2809 2811/2819 2841/2843 2851/2859 2861/2863 2871/2879 2891/2896 2901/2909 2951/2952 2961 2971 2981/2899 3031 3032=1 "Cereals")(41/61 302 621 622 3231 =2 "White roots and tubers")( 63/82 86/115 298 300 441 904 905 2921/2923 2881/2889 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 299 317/320 2911/2919 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3129 =10 "Oils and fats")(303/11 321=11 "Sweets")(246/251 253/264 266/276 300 301 314/316 318 319 910 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(fx1_07_06) // categorize ingredients
keep a01 fx1_07_06
duplicates drop a01 fx1_07_06, force
rename fx1_07_06 item
tempfile hdds612
save hdd612, replace

use $BIHS12/049_mod_x1_female.dta, clear
recode x1_07_07 (1/16 277/297 303/305 323 901 2771/2779 2781/2789 2791/2799 2801/2809 2811/2819 2841/2843 2851/2859 2861/2863 2871/2879 2891/2896 2901/2909 2951/2952 2961 2971 2981/2899 3031 3032=1 "Cereals")(41/61 302 621 622 3231 =2 "White roots and tubers")( 63/82 86/115 298 300 441 904 905 2921/2923 2881/2889 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 299 317/320 2911/2919 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3129 =10 "Oils and fats")(303/11 321=11 "Sweets")(246/251 253/264 266/276 300 301 314/316 318 319 910 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(fx1_07_07) // categorize ingredients
keep a01 fx1_07_07
duplicates drop a01 fx1_07_07, force
rename fx1_07_07 item
tempfile hdds712
save hdd712, replace

use $BIHS12/049_mod_x1_female.dta, clear
recode x1_07_08 (1/16 277/297 303/305 323 901 2771/2779 2781/2789 2791/2799 2801/2809 2811/2819 2841/2843 2851/2859 2861/2863 2871/2879 2891/2896 2901/2909 2951/2952 2961 2971 2981/2899 3031 3032=1 "Cereals")(41/61 302 621 622 3231 =2 "White roots and tubers")( 63/82 86/115 298 300 441 904 905 2921/2923 2881/2889 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 299 317/320 2911/2919 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3129 =10 "Oils and fats")(303/11 321=11 "Sweets")(246/251 253/264 266/276 300 301 314/316 318 319 910 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(fx1_07_08) // categorize ingredients
keep a01 fx1_07_08
duplicates drop a01 fx1_07_08, force
rename fx1_07_08 item
tempfile hdds812
save hdd812, replace

use $BIHS12/049_mod_x1_female.dta, clear
recode x1_07_09 (1/16 277/297 303/305 323 901 2771/2779 2781/2789 2791/2799 2801/2809 2811/2819 2841/2843 2851/2859 2861/2863 2871/2879 2891/2896 2901/2909 2951/2952 2961 2971 2981/2899 3031 3032=1 "Cereals")(41/61 302 621 622 3231 =2 "White roots and tubers")( 63/82 86/115 298 300 441 904 905 2921/2923 2881/2889 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 299 317/320 2911/2919 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3129 =10 "Oils and fats")(303/11 321=11 "Sweets")(246/251 253/264 266/276 300 301 314/316 318 319 910 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(fx1_07_09) // categorize ingredients
keep a01 fx1_07_09 
duplicates drop a01 fx1_07_09, force
rename fx1_07_09 item
tempfile hdds912
save hdd912, replace

use $BIHS12/049_mod_x1_female.dta, clear
recode x1_07_10(1/16 277/297 303/305 323 901 2771/2779 2781/2789 2791/2799 2801/2809 2811/2819 2841/2843 2851/2859 2861/2863 2871/2879 2891/2896 2901/2909 2951/2952 2961 2971 2981/2899 3031 3032=1 "Cereals")(41/61 302 621 622 3231 =2 "White roots and tubers")( 63/82 86/115 298 300 441 904 905 2921/2923 2881/2889 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 299 317/320 2911/2919 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3129 =10 "Oils and fats")(303/11 321=11 "Sweets")(246/251 253/264 266/276 300 301 314/316 318 319 910 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(fx1_07_10) // categorize ingredients
keep a01 fx1_07_10
duplicates drop a01 fx1_07_10, force
rename fx1_07_10 item
tempfile hdds1012
save hdd1012, replace

use $BIHS12/049_mod_x1_female.dta, clear
recode x1_07_11 (1/16 277/297 303/305 323 901 2771/2779 2781/2789 2791/2799 2801/2809 2811/2819 2841/2843 2851/2859 2861/2863 2871/2879 2891/2896 2901/2909 2951/2952 2961 2971 2981/2899 3031 3032=1 "Cereals")(41/61 302 621 622 3231 =2 "White roots and tubers")( 63/82 86/115 298 300 441 904 905 2921/2923 2881/2889 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 299 317/320 2911/2919 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3129 =10 "Oils and fats")(303/11 321=11 "Sweets")(246/251 253/264 266/276 300 301 314/316 318 319 910 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(fx1_07_11) // categorize ingredients
keep a01 fx1_07_11
duplicates drop a01 fx1_07_11, force
rename fx1_07_11 item
tempfile hdds1112
save hdd1112, replace

use $BIHS12/049_mod_x1_female.dta, clear
recode x1_07_12 (1/16 277/297 303/305 323 901 2771/2779 2781/2789 2791/2799 2801/2809 2811/2819 2841/2843 2851/2859 2861/2863 2871/2879 2891/2896 2901/2909 2951/2952 2961 2971 2981/2899 3031 3032=1 "Cereals")(41/61 302 621 622 3231 =2 "White roots and tubers")( 63/82 86/115 298 300 441 904 905 2921/2923 2881/2889 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 299 317/320 2911/2919 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3129 =10 "Oils and fats")(303/11 321=11 "Sweets")(246/251 253/264 266/276 300 301 314/316 318 319 910 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(fx1_07_12) // categorize ingredients
keep a01 fx1_07_12
duplicates drop a01 fx1_07_12, force
rename fx1_07_12 item
tempfile hdds1212
save hdd1212, replace

use $BIHS12/049_mod_x1_female.dta, clear
recode x1_07_13 (1/16 277/297 303/305 323 901 2771/2779 2781/2789 2791/2799 2801/2809 2811/2819 2841/2843 2851/2859 2861/2863 2871/2879 2891/2896 2901/2909 2951/2952 2961 2971 2981/2899 3031 3032=1 "Cereals")(41/61 302 621 622 3231 =2 "White roots and tubers")( 63/82 86/115 298 300 441 904 905 2921/2923 2881/2889 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 299 317/320 2911/2919 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3129 =10 "Oils and fats")(303/11 321=11 "Sweets")(246/251 253/264 266/276 300 301 314/316 318 319 910 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(fx1_07_13) // categorize ingredients
keep a01 fx1_07_13
duplicates drop a01 fx1_07_13, force
rename fx1_07_13 item
tempfile hdds1312
save hdd1312, replace

use $BIHS12/049_mod_x1_female.dta, clear
recode x1_07_14(1/16 277/297 303/305 323 901 2771/2779 2781/2789 2791/2799 2801/2809 2811/2819 2841/2843 2851/2859 2861/2863 2871/2879 2891/2896 2901/2909 2951/2952 2961 2971 2981/2899 3031 3032=1 "Cereals")(41/61 302 621 622 3231 =2 "White roots and tubers")( 63/82 86/115 298 300 441 904 905 2921/2923 2881/2889 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 299 317/320 2911/2919 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3129 =10 "Oils and fats")(303/11 321=11 "Sweets")(246/251 253/264 266/276 300 301 314/316 318 319 910 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(fx1_07_14) // categorize ingredients
keep a01 fx1_07_14
duplicates drop a01 fx1_07_14, force
rename fx1_07_14 item
tempfile hdds1412
save hdd1412, replace

use $BIHS12/049_mod_x1_female.dta, clear
recode x1_07_15 (1/16 277/297 303/305 323 901 2771/2779 2781/2789 2791/2799 2801/2809 2811/2819 2841/2843 2851/2859 2861/2863 2871/2879 2891/2896 2901/2909 2951/2952 2961 2971 2981/2899 3031 3032=1 "Cereals")(41/61 302 621 622 3231 =2 "White roots and tubers")( 63/82 86/115 298 300 441 904 905 2921/2923 2881/2889 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 299 317/320 2911/2919 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3129 =10 "Oils and fats")(303/11 321=11 "Sweets")(246/251 253/264 266/276 300 301 314/316 318 319 910 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(fx1_07_15) // categorize ingredients
keep a01 fx1_07_15
duplicates drop a01 fx1_07_15, force
rename fx1_07_15 item
tempfile hdds1512
save hdd1512, replace

use fd12.dta, clear
append using hdd212
append using hdd312
append using hdd412
append using hdd512
append using hdd612
append using hdd712
append using hdd812
append using hdd912
append using hdd1012
append using hdd1112
append using hdd1212
append using hdd1312
append using hdd1412
append using hdd1512
duplicates drop a01 item, force
bysort a01: egen hdds=count(a01)
drop item
label var hdds "Household Dietary Diversity"
duplicates drop a01, force
save fd12.dta, replace

**Consumption expenditure
use BIHS_hh_variables_r123, clear
keep if round==1
keep a01 pc_expm_d pc_foodxm_d pc_nonfxm_d
save expend12.dta, replace

**Idiosyncratic shocks
use $BIHS12\038_mod_t1_male.dta, clear
recode t1_02 (9 10= 1 "Yes") (nonm=0 "No"), gen(c)
recode t1_02 (11 12 13=1 "Yes")(nonm=0 "No"), gen(l)
bysort a01: egen idi_crp=sum(c) 
bysort a01: egen idi_lvstck=sum(l)
keep a01 idi_crp idi_lvstck
recode idi_crp (1/max=1 "Yes") (0=0 "No"), gen(idcrp)
label var idcrp "Crop shock(=1 if yes)"
recode idi_lvstck (1/max=1 "Yes") (0=0 "No"), gen(idliv)
label var idliv "Livestock shock(=1 if yes)"
keep a01 idcrp idliv
duplicates drop a01, force
gen idi_crp_liv=idcrp*idliv
label var idi_crp_liv "Crop shock*Livestock shock "
save idisyn12.dta, replace

**farm diversification index
use $BIHS12\028_mod_m1_male, clear //crop income
keep a01 m1_02 m1_10 m1_18 m1_20
bysort a01 m1_02: egen eis=sum(m1_10)
keep a01 m1_02 eis
duplicates drop a01 m1_02, force
save eci12, replace
use $BIHS12\027_mod_l2_male.dta, clear // fishery income
keep a01 l2_12 l2_01
bysort a01 l2_01: egen eis=sum(l2_12)
keep a01 eis l2_01
duplicates drop a01 l2_01, force
tempfile efi12
save efi12, replace
use eli12, clear //livestock income
bysort a01 livestock: egen eis=sum(k2_12)
keep a01 eis livestock 
duplicates drop a01 livestock, force
append using efi12
append using eci12
bysort a01: egen frminc=sum(eis) //total farm income
gen seir=(eis/frminc)^2 //squared each farm income ratio 
bysort a01: egen frm_div1=sum(seir)
bysort a01: gen frm_div=1-frm_div1
gen p=eis/frminc 
gen lnp=log(p)
gen shnn1=p*lnp
bysort a01: egen shn1=sum(shnn1)
gen shnf=-1*(shn1)
duplicates drop a01, force
keep a01 frm_div shnf
save frm_div12, replace

**Farm diversification
use crp12.dta, clear
merge 1:1 a01 using livdiv12, nogen
merge 1:1 a01 using fsh12, nogen
replace livdiv=0 if livdiv==.
replace crpdivnm=0 if crpdivnm==.
replace fshdiv=0 if fshdiv==.
gen frmdiv=crpdivnm+livdiv+fshdiv
save frmdiv12.dta, replace

**Income diversification
use crpincm12.dta, clear
merge 1:1 a01 using nnrn12.dta, nogen
merge 1:1 a01 using ssnp12.dta, nogen
merge 1:1 a01 using lvstckinc12.dta, nogen
merge 1:1 a01 using offfrm12.dta, nogen
merge 1:1 a01 using fsh12.dta, nogen
merge 1:1 a01 using nnagent12.dta, nogen
merge 1:1 a01 using rem12.dta, nogen
merge 1:1 a01 using frmwage12.dta, nogen
drop dstnc_sll_ trnsctn lvstck fshdiv v2_06
replace crp_vl=0 if crp_vl==.
replace offrminc=0 if offrminc==.
replace nnearn=0 if nnearn==.
replace fshinc=0 if fshinc==.
replace ttllvstck=0 if ttllvstck==.
replace remi=0 if remi==.
replace nnagent=0 if nnagent==.
replace frmwage=0 if frmwage==.
gen ttinc= crp_vl+nnearn+trsfr+ttllvstck+offrminc+fshinc+nnagent+remi+frmwage //total income
gen aginc=ttllvstck+crp_vl+fshinc
gen nonself=nnagent //non-farm self
gen nonwage=offrminc //non-farm wage
gen nonearn=remi+trsfr+nnearn //non-earned 
gen i1=(aginc/ttinc)^2
gen i2=(frmwage/ttinc)^2
gen i3=(nonself/ttinc)^2
gen i4=(nonwage/ttinc)^2
gen i5=(nonearn/ttinc)^2
gen es=i1+i2+i3+i4+i5
gen inc_div=1-es
label var inc_div "Income diversification index" //simpson
gen p1=(aginc/ttinc)
gen p2=(frmwage/ttinc)
gen p3=(nonself/ttinc)
gen p4=(nonwage/ttinc)
gen p5=(nonearn/ttinc)
gen lnp1=log(p1)
gen lnp2=log(p2)
gen lnp3=log(p3)
gen lnp4=log(p4)
gen lnp5=log(p5)
gen shn1=p1*lnp1
gen shn2=p2*lnp2
gen shn3=p3*lnp3
gen shn4=p4*lnp4
gen shn5=p5*lnp5
egen shnni = rowtotal(shn1 shn2 shn3 shn4 shn5)
gen shni=-1*(shnni) //shannon
keep a01 inc_div shni //ttinc ttinc crp_vl nnearn trsfr ttllvstck offrminc fshinc nnagent
save incdiv12.dta, replace

**climate variables 
use climate, clear
rename (district dcode) (dcode District_Name) //renaming
drop rw3 rs3 rr3 ra3 rw2 rs2 rr2 ra2 tw3 ts3 tr3 ta3 tw2 ts2 tr2 ta2 rsd3 rsd2 tsd3 tsd2 //tmpsd1 tmpsd2 rinsd1 rinsd2 rwet1 rdry1 rwet2 rdry2 twet1 tdry1 twet2 tdry2 
/*rename (rw3 rs3 rr3 ra3 rinsd3 tw3 ts3 tr3 ta3 tmpsd3 rwet3 rdry3 twet3 tdry3)(rw rs rr ra rinsd tw ts tr ta tmpsd rwet rdry twet tdry)*/
rename (rw1 rs1 rr1 ra1 rsd1 tw1 ts1 tr1 ta1 tsd1 )(rw rs rr ra rsd tw ts tr ta tsd )
//gen rinsd_1000=rinsd/1000
gen ln_rw=log(rw)
gen ln_rs=log(rs)
gen ln_rr=log(rr)
gen ln_ra=log(ra)
//gen ln_rinsd=log(rinsd)
gen ln_rinsd=log(rsd)
gen ln_tw=log(tw)
gen ln_ts=log(ts)
gen ln_tr=log(tr)
gen ln_ta=log(ta)
//gen ln_tmpsd=log(tmpsd)
gen ln_tmpsd=log(tsd)

/*gen ln_rwet=log(rwet)
gen ln_rdry=log(rdry)
gen ln_tdry=log(tdry)
gen ln_twet=log(twet)*/
/*label var rinsd "Yearly st.dev rainfall"*/
/*label var tmpsd "Monthly st.dev temperature"*/
label var ln_tmpsd "Monthly st.dev temperature (log)"
/*label var rinsd_1000 "Yearly st.dev rainfall (1,000mm)"*/
label var ln_rinsd  "Yearly st.dev rainfall (log) "
label var ln_rw "Winter rainfall (log)"
label var ln_rs "Summer rainfall (log)"
label var ln_rr "Rainy season rainfall (log)"
label var ln_ra "Autumn rainfall (log)"
label var ln_tw "Winter mean temperature (log)"
label var ln_ts "Summer mean temperature (log)"
label var ln_tr "Rainy season mean temperature (log)"
label var ln_ta "Autumn mean temperature (log)"
/*label var ln_rwet "Wet season rainfall (log)"
label var ln_rdry "Dry season rainfall (log)"
label var ln_twet "Wet season temperature (log)"
label var ln_tdry "Dry season temperature (log)"*/
save climate12, replace

**merge all 2012 dataset
use 2012.dta,clear
merge m:1 dcode using climate12, nogen
merge 1:1 a01 using sciec12, nogen
merge 1:1 a01 using agrnmic12, nogen
merge 1:1 a01 using nnrn12, nogen
merge 1:1 a01 using crp_div12, nogen
merge 1:1 a01 using idisyn12.dta, nogen
merge 1:1 a01 using lvstckinc12.dta,nogen
merge 1:1 a01 using crpincm12,nogen
merge 1:1 a01 using offfrm12.dta,nogen
merge 1:1 a01 using ssnp12,nogen
merge 1:1 a01 using nnfrminc12,nogen
merge 1:1 a01 using crp12,nogen
merge 1:1 a01 using irri12, nogen
merge 1:1 a01 using incdiv12, nogen
merge 1:1 a01 using frmdiv12.dta, nogen
merge 1:1 a01 using fd12.dta, nogen
merge 1:1 a01 using expend12, nogen
merge 1:1 a01 using frm_div12, nogen
merge 1:1 a01 using mrkt12, nogen
merge 1:1 a01 using facility12, nogen
merge 1:1 a01 using extension12, nogen
label var farmsize "Farm Size(decimal)"
label var ln_farm "Farm size(log)"
//gen lnoff=log(offrmagr)
gen year=2012
replace crpdivnm=0 if crpdivnm==.
save 2012.dta, replace