/*create dataset for regression*/
/*Author: Masanori Matsuura*/
clear all
set more off
*set the pathes
global climate = "C:\Users\user\Documents\Masterthesis\BIHS\Do"
global BIHS18Community = "C:\Users\user\Documents\research\saiful\mobile_phone\BIHS\BIHS2018\BIHSRound3\Community"
global BIHS18Female = "C:\Users\user\Documents\research\saiful\mobile_phone\BIHS\BIHS2018\BIHSRound3\Female"
global BIHS18Male = "C:\Users\user\Documents\research\saiful\mobile_phone\BIHS\BIHS2018\BIHSRound3\Male"
global BIHS15 = "C:\Users\user\Documents\research\saiful\mobile_phone\BIHS\BIHS2015"
global BIHS12 = "C:\Users\user\Documents\research\saiful\mobile_phone\BIHS\BIHS2012"
cd "C:\Users\user\Documents\research\saiful\mobile_phone\BIHS\Do"

*BIHS2012 data cleaning 
**keep geographical code
use $BIHS12\001_mod_a_male, clear
keep a01 div dcode District_Name uzcode uncode vcode_n
rename (div vcode_n)(dvcode Village)
save 2012, replace

**mobile phone ownership
use $BIHS12\006_mod_d1_male, clear //household ownership
keep if d1_02==24
recode d1_03 (1=1 "yes")(nonm=0 "no"), gen(mobile)
rename d1_04 mobile_q
label var mobile_q "Mobile phone ownership (quantity)"
keep a01 mobile mobile_q
save mobile12, replace

** migrant status
use $BIHS12\041_mod_v1_male, clear //if any members are migrants
recode v1_01 (1=1 "Yes")(2=0 "No"), gen(migrant)
keep a01 migrant
label var migrant "Member migration (1/0)"
duplicates drop a01, force
save migrant12, replace

**poverty indicators
use $BIHS12\hhexpenditure_R1, clear // poverty status and depth (gap)
merge 1:1 a01 using $BIHS12\mpi_R1, nogen //multidimentional poverty index
keep a01 pcexp_da p190hcgcpi p190hcfcpi p320hcgcpi p320hcfcpi pov190gapgcpi deppov190gcpi pov190gapfcpi deppov190fcpi pov320gapgcpi pov320gapfcpi deppov320fcpi deppov320gcpi hc_mpi mpiscore
save poverty12.dta, replace

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

**Asset index
use $BIHS12\006_mod_d1_male.dta, clear  
tabulate d1_02, gen(a)
pca a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 a17 a18 a19 a20 a21 a22 a23 a24 a25 a26 a27 a28 a29 a30 a31 a32 a33 a34 a35 a36 a37 a38 a39 a40 a41 a42 a43 a44 a45
predict assetindex
sort a01
by a01: egen asset=sum(d1_03*assetindex)
keep a01 asset
duplicates drop a01, force
save asset12.dta, replace

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
gen es_sh=(typ_plntd/ttl_frm)
gen lnc=log(es_sh)
bysort a01: egen _shnc=sum(lnc*es_sh)
gen shnc=-1*_shnc
keep a01 crp_div shnc
label var shnc "Crop diversification index (shannon)"
keep a01 crp_div shnc
duplicates drop a01, force
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
use $BIHS12\037_mod_s_male, clear
keep a01 s_01 s_06
keep if s_01==6
drop s_01
rename s_06 bazaar
label var bazaar "Periodic bazaar access (minute)"
merge 1:1 a01 using facility12, nogen
save facility12, replace
use $BIHS12\037_mod_s_male, clear
keep a01 s_01 s_06
keep if s_01==5
drop s_01
rename s_06 shop
label var shop "Local shop access (minute)"
merge 1:1 a01 using facility12, nogen
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

**keep Non-farm self employment
use $BIHS12\005_mod_c_male.dta, clear
keep a01 c05 c09 c14
keep if c09 == 3 //keep self employed
drop if c09==1 // drop farm wage
bysort a01: egen offsel=sum(c14)
gen offself=12*offsel
keep a01 offself
label var offself "Non-farm self employment"
duplicates drop a01, force
save nnfrminc12.dta, replace

**Non-farm employment 
use $BIHS12\005_mod_c_male.dta, clear
keep a01 c05 c09 c14
keep if c09 != 3 //keep salary and wage
drop if c05== 1 //drop farm wage
gen yc14=12*c14
bysort a01: egen offrminc=sum(yc14)
label var offrminc "Non-farm wage and salary"
keep a01 offrminc
duplicates drop a01, force
save offfrm12.dta, replace

**farm wage
use $BIHS12\005_mod_c_male.dta, clear
keep if c05== 1
keep a01 c14
replace c14=0 if c14==.
bysort a01: egen frmwag=sum(c14)
gen frmwage=frmwag*12
keep a01 frmwage
label var frmwage "Farm wage"
duplicates drop a01, force
save frmwage12.dta, replace

*Non-agricultural enterprise
use $BIHS12\030_mod_n_male.dta, clear
bysort a01: egen nnagent=sum(n05)
label var nnagent "non-agricultural enterprise"
keep a01 nnagent
duplicates drop a01, force
save nnagent12.dta, replace

/*food consumption*/
use $BIHS12/031_mod_o1_female, clear

recode o1_01 (1/16 277/290 297 901 296 302 =1 "Cereals")(61 62 621 622 295 301 3231=2 "White tubers and roots")(41/60 63/82 86/115 904 905 291 292 298 441=3 "Vegetables")(141/170 317 319 907=4 "Fruits")(121/129 906 322 =5 "Meat")(130/135 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 902 299=8 "Legumes, nuts and seeds")(132/135 1321/1323 2941/2943 294=9 "Milk and milk products")(31/36 903 312 =10 "Oils and fats")(266/271 293 303/311=11 "Sweets")(246/251 253/264 272/276 318 323 910 300 314/321 2521 2522 252 313= 12 "Spices, condiments and beverages"), gen(hdds_i)

duplicates drop a01 hdds_i, force
bysort a01: egen hdds=count(a01)
drop hdds_i
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
merge 1:1 a01 using nnfrminc12.dta, nogen
drop dstnc_sll_ trnsctn lvstck fshdiv v2_06
replace crp_vl=0 if crp_vl==.
replace offrminc=0 if offrminc==.
replace nnearn=0 if nnearn==.
replace fshinc=0 if fshinc==.
replace ttllvstck=0 if ttllvstck==.
replace remi=0 if remi==.
replace nnagent=0 if nnagent==.
replace frmwage=0 if frmwage==.
replace offself=0 if offself==.
gen ttinc= crp_vl+nnearn+trsfr+ttllvstck+offrminc+fshinc+nnagent+remi+frmwage+offself //total income
gen aginc=ttllvstck+crp_vl+fshinc
gen nonself=offself //off-farm self
gen nonwage=offrminc //off-farm wage
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
keep a01 aginc frmwage nonself nonwage nonearn inc_div shni ttinc // ttinc crp_vl nnearn trsfr ttllvstck offrminc fshinc nnagent
save incdiv12.dta, replace

**climate variables 
use $climate\climate, clear
/*rename (district dcode) (dcode District_Name) //renaming*/
keep dcode District hs1 hr1 ha1 hw1 sds1 sdr1 sda1 sdw1 s1 r1 w1 a1 hst1 hrt1 hat1 hwt1 sdst1 sdrt1 sdat1 sdwt1 ts1 tr1 ta1 tw1 
rename (hs1 hr1 ha1 hw1 sds1 sdr1 sda1 sdw1 s1 r1 w1 a1 hst1 hrt1 hat1 hwt1 sdst1 sdrt1 sdat1 sdwt1 ts1 tr1 ta1 tw1)(hs hr ha hw sds sdr sda sdw s r w a hst hrt hat hwt sdst sdrt sdat sdwt ts tr ta tw)

gen srshock=log(s)-log(hs)
gen rrshock=log(r)-log(hr)
gen arshock=log(a)-log(ha)
gen wrshock=log(w)-log(hw)
gen ln_sds=log(sds)
gen ln_sdr=log(sdr)
gen ln_sda=log(sda)
gen ln_sdw=log(sdw)
gen stshock=log(ts)-log(hst)
gen rtshock=log(tr)-log(hrt)
gen atshock=log(ta)-log(hat)
gen wtshock=log(tw)-log(hwt)
gen ln_sdst=log(sdst)
gen ln_sdrt=log(sdrt)
gen ln_sdat=log(sdat)
gen ln_sdwt=log(sdwt)
label var s "Summer rainfall(mm)" 
label var r "Rainy season rainfall(mm)"
label var a "Autumn rainfall(mm)"
label var w "Winter rainfall(mm)"
label var hs "20-year summer rainfall"
label var hr "20-year rainy season rainfall"
label var ha "20-year autumn rainfall"
label var hw "20-year winter rainfall"
label var ts "Summer average temperature(\textdegree{}C)"
label var tr "Rainy season average temperature(\textdegree{}C)"
label var ta "Autumn season average temperature(\textdegree{}C)"
label var tw "Winter average temperature(\textdegree{}C)"
label var hst "20-year summer average temperature(\textdegree{}C)"
label var hrt "20-year rainy season average temperature(\textdegree{}C)"
label var hat "20-year autumn average temperature(\textdegree{}C)"
label var hwt "20-year winter average temperature(\textdegree{}C)"
label var ln_sds "20-year summer rainfall SD(log)"
label var ln_sdr  "20-year rainy season rainfall SD(log)"
label var ln_sda  "20-year autumn rainfall SD(log)"
label var ln_sdw  "20-year winter rainfall SD(log)"
label var ln_sdst "20-year summer temperature SD(log)"
label var ln_sdrt "20-year rainy season temperature SD(log)"
label var ln_sdat "20-year autumn temperature SD(log)"
label var ln_sdwt "20-year winter temperature SD(log)"
label var srshock "Rainfall shock in summer"
label var rrshock "Rainfall shock in rainy season"
label var arshock "Rainfall shock in autumn"
label var wrshock "Rainfall shock in winter"
label var stshock "Temperature shock in summer"
label var rtshock "Temperature shock in rainy season"
label var atshock "Temperature shock in autumn"
label var wtshock "Temperature shock in winter"
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
merge 1:1 a01 using mobile12, nogen
merge 1:1 a01 using poverty12, nogen
merge 1:1 a01 using migrant12, nogen
merge 1:1 a01 using asset12, nogen
label var farmsize "Farm Size(decimal)"
label var ln_farm "Farm size(log)"
//gen lnoff=log(offrmagr)
gen year=2012
replace crpdivnm=0 if crpdivnm==.
save 2012.dta, replace
