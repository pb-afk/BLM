***************************************
** 1. CLEANING OF WATER QUALITY DATA **
***************************************

clear
set more off
cd "$dir1/1. Water quality data/NOV 2019/ALL/"

// Import Files w/ Water Quality Measurements & the Monitoring Stations Detailed File
local state ""alaska" "arizona" "arkansas" "california" "colorado" "connecticut" "delaware" "florida" "florida - Copy" "georgia" "hawaii" "idaho" "illinois" "indiana" "iowa" "kansas" "kentucky" "lousiana" "maine" "maryland" "massachusetts" "michigan"  "minnesota" "minnesota - Copy"  "missisipi" "missouri" "montana" "nebraska" "nevada" "new hampshire" "new jersey" "new york" "new mexico" "north carolina" "north dakota" "ohio" "oklahoma" "oregon" "pennsylvania" "rhode island" "south carolina" "tennesse" "texas" "utah" "vermont" "virginia" "washington" "west virginia" "wisconsin" "wyoming""
use "alabama/result_def_alabama_NOV_2019", clear
foreach z of local state {
append using "`z'/result_def_`z'_NOV_2019", force
} 
//

// Drop Non-Relevant Variables
drop AR AM M K H V AL X AN AS R AF AK WellDepthMeasureMeasureValue WellDepthMeasureMeasureUnitCode WellHoleDepthMeasureMeasureValu ///
ConstructionDateText VerticalCoordinateReferenceSyste VerticalCollectionMethodName VerticalAccuracyMeasureMeasureU VerticalAccuracyMeasureMeasureV ///
VerticalMeasureMeasureUnitCode VerticalMeasureMeasureValue HorizontalCoordinateReferenceSys HorizontalCollectionMethodName ResultCommentText PrecisionValue ///
OrganizationFormalName ActivityIdentifier ActivityEndDate ActivityEndTimeTime ActivityEndTimeTimeZoneCode ActivityDepthHeightMeasureMeasu N ///
ActivityDepthAltitudeReferencePo ActivityTopDepthHeightMeasureMe Q ActivityBottomDepthHeightMeasure S ProjectIdentifier ActivityConductingOrganizationTe ///
ActivityCommentText SampleAquifer HydrologicCondition FormationTypeText PreparationStartDate ResultLaboratoryCommentText AnalysisStartDate LaboratoryName ///
MethodDescriptionText SampleTissueAnatomyName ResultDepthHeightMeasureMeasure AV ResultDepthAltitudeReferencePoin

// DetectionQuantitationLimitMeasur is Labelled in Different Ways in Different Files
replace DetectionQuantitationLimitMeasur = BI if DetectionQuantitationLimitMeasur=="" & BI!=""
replace DetectionQuantitationLimitMeasur = AY if DetectionQuantitationLimitMeasur=="" & AY!=""
replace DetectionQuantitationLimitMeasur = AT if DetectionQuantitationLimitMeasur=="" & AT!=""
replace DetectionQuantitationLimitMeasur = AQ if DetectionQuantitationLimitMeasur=="" & AQ!=""
drop BI AY AT AQ 

// SAVE 1st temporary file
save "temp_base.dta", replace
use "temp_base.dta", clear

// Cleaning MonitoringLocationTypeName
g first_4 =substr(MonitoringLocationTypeName,1,6)

replace MonitoringLocationTypeName = "Surface Water - O" if MonitoringLocationTypeName=="Ocean"
replace MonitoringLocationTypeName = "Surface Water - O" if MonitoringLocationTypeName=="Ocean: Coastal"

replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Canal Drainage"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Canal Irrigation"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Canal Transport"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="River/Stream"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="River/Stream Ephemeral"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="River/Stream Intermittent"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="River/Stream Perennial"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="River/stream Effluent-Dominated"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Riverine Impoundment"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Stream"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Stream: Canal"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Stream: Ditch"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Stream: Tidal stream"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Channelized Stream"
replace MonitoringLocationTypeName = "Surface Water - R" if MonitoringLocationTypeName=="Estuary" 

replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Estuarine-Emergent"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Estuarine-Scrub-Shrub"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Lacustrine-Emergent"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Palustrine-Emergent"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Palustrine-Forested"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Palustrine-Moss-Lichen"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Palustrine-Shrub-Scrub"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Riverine-Emergent"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Undifferentiated"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Constructed Wetland"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Lacustrine-Emergent"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Palustrine Pond"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Palustrine-Emergent"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Riverine-Emergent"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Wetland Undifferentiated"
replace MonitoringLocationTypeName = "Surface Water - W" if MonitoringLocationTypeName=="Seep"

replace MonitoringLocationTypeName = "Surface Water - L" if MonitoringLocationTypeName=="Great Lake"
replace MonitoringLocationTypeName = "Surface Water - L" if MonitoringLocationTypeName=="Lake"
replace MonitoringLocationTypeName = "Surface Water - L" if MonitoringLocationTypeName=="Lake, Reservoir, Impoundment"
replace MonitoringLocationTypeName = "Surface Water - L" if MonitoringLocationTypeName=="Reservoir"
replace MonitoringLocationTypeName = "Surface Water - L" if MonitoringLocationTypeName=="Pond-Stormwater"
replace MonitoringLocationTypeName = "Surface Water - L" if MonitoringLocationTypeName=="Pond-Stock"

replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well: Collector or Ranney type well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well: Hyporheic-zone well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well: Test hole not completed as a well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Aggregate groundwater use"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well: Collector or Ranney type well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well: Hyporheic-zone well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well: Interconnected wells"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well: Multiple wells"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Well: Test hole not completed as a well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Subsurface: Cave"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Subsurface: Groundwater drain"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Subsurface: Tunnel, shaft, or mine"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Subsurface: Unsaturated zone"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Industrial"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Municipal Sewage (POTW)"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Other"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Privately Owned Non-industrial"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Public Water Supply (PWS)"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Cistern"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Combined sewer"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Diversion"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Outfall"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Septic system"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Waste injection well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Wastewater land application"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Wastewater sewer"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Water-distribution system"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Water-use establishment"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Cave"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Other-Ground Water"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Borehole"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Pipe, Unspecified Source"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Spring"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Other-Ground Water"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Pipe, Unspecified Source"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Subsurface: Cave"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Subsurface: Groundwater drain"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Subsurface: Tunnel, shaft, or mine"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Subsurface"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Aggregate groundwater use"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="CERCLA Superfund Site"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Industrial"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Municipal Sewage (POTW)"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Other"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Privately Owned Non-industrial"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility Public Water Supply (PWS)"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Cistern"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Combined sewer"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Diversion"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Outfall"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Pavement"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Storm sewer"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Waste injection well"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Wastewater land application"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Wastewater sewer"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Water-distribution system"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Facility: Water-use establishment"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Mine/Mine Discharge"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Mine/Mine Discharge Tailings Pile"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Mine/Mine Discharge Tailings Pile"
replace MonitoringLocationTypeName = "Groundwater" if MonitoringLocationTypeName=="Mine/Mine Discharge Waste Rock Pile"
replace MonitoringLocationTypeName = "Groundwater" if first_4=="Facili"
replace MonitoringLocationTypeName = "Groundwater" if first_4=="Mine/M"

replace MonitoringLocationTypeName = "Surface Water" if MonitoringLocationTypeName=="Atmosphere"
replace MonitoringLocationTypeName = "Surface Water" if MonitoringLocationTypeName=="BEACH Program Site-Estuary"
replace MonitoringLocationTypeName = "Surface Water" if MonitoringLocationTypeName=="BEACH Program Site-Lake"
replace MonitoringLocationTypeName = "Surface Water" if MonitoringLocationTypeName=="BEACH Program Site-Ocean"
replace MonitoringLocationTypeName = "Surface Water" if MonitoringLocationTypeName=="BEACH Program Site-River/Stream"
replace MonitoringLocationTypeName = "Surface Water" if MonitoringLocationTypeName=="Aggregate surface-water-use"
replace MonitoringLocationTypeName = "Surface Water" if MonitoringLocationTypeName=="Other-Surface Water"

replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Land"
replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Land Flood Plain"
replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Land Runoff"
replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Land: Excavation"
replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Land: Outcrop"
replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Land: Shore"
replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Land: Sinkhole"
replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Land: Soil hole"
replace MonitoringLocationTypeName = "LAND" if MonitoringLocationTypeName=="Landfill"

// Drop Water Body Sources that Cannot be Assigned to any of the Category
drop if MonitoringLocationTypeName=="Combined Sewer"
drop if MonitoringLocationTypeName=="Gallery"
drop if MonitoringLocationTypeName=="Leachate-Lysimeter"
drop if MonitoringLocationTypeName=="Spigot / Faucet"
drop if MonitoringLocationTypeName=="Waste Pit"
drop if MonitoringLocationTypeName=="Waste Sewer"
drop if MonitoringLocationTypeName=="Pond-Anchialine"
drop if MonitoringLocationTypeName=="Pond-Wastewater" 
drop if MonitoringLocationTypeName=="Storm Sewer" 
drop if MonitoringLocationTypeName=="Floodwater Urban" 
drop if MonitoringLocationTypeName=="Floodwater non-Urban"

replace MonitoringLocationTypeName = "Surface Water" if MonitoringLocationTypeName=="" // The replacement is correct. Additional information confirms it is surface-water. Only relevant for state == 16 [Idaho].

// Cleaning Date and Monitoring Station ID
capture drop year month day
tostring date, generate(date_string) force usedisplayformat
g year = substr(date_string, 6, 4)
g month = substr(date_string, 3, 3)
g day = substr(date_string, 1, 2)

g monitoring = MonitoringLocationIdentifier 

// Creating a geo ID with some adjustments from manual data scanning and checks
tostring LatitudeMeasure, gen(lat_s) force
tostring LongitudeMeasure, gen(long_s) force
replace lat_s = "47.51411105" if monitoring =="BUNKER_WQX-SF-252A" 
replace long_s = "-116.0226639" if monitoring =="BUNKER_WQX-SF-252A"
replace lat_s = "39.07986361" if monitoring =="NARS_WQX-NLA06608-0596" 
replace long_s = "-106.3650807" if monitoring =="NARS_WQX-NLA06608-0596"

g ID_geo = lat_s + long_s

g state_county_ID = StateCode + CountyCode

// SAVE 2st temporary file
save temp_w, replace
use temp_w, clear

// Generate a Flag Marking Observations with ResultDetectionConditionText!=""
g ResultDetectionConditionText_D = 1 if ResultDetectionConditionText!=""
replace ResultDetectionConditionText_D = 0 if ResultDetectionConditionText_D ==.

tab ResultDetectionConditionText if Ch =="Barium" | ///
									Ch =="Bromide" | ///
									Ch =="Chloride" | ///
									Ch =="Strontium"

// Cleaning ResultDetectionConditionText [variable used to create the three alternative measurement versions]
g ResultDetectionConditionText_ = ResultDetectionConditionText

// To "NA"
replace ResultDetectionConditionText_ = "NA" if ResultDetectionConditionText=="**"
replace ResultDetectionConditionText_ = "NA" if ResultDetectionConditionText=="*OS"
replace ResultDetectionConditionText_ = "NA" if ResultDetectionConditionText=="300(A)"
replace ResultDetectionConditionText_ = "NA" if ResultDetectionConditionText=="300(A)0"

// To "Detection Limit"
replace ResultDetectionConditionText_ = "0.286" if ResultDetectionConditionText=="*0.286"
replace ResultDetectionConditionText_ = "0.287" if ResultDetectionConditionText=="*0.287"
replace ResultDetectionConditionText_ = "0.340" if ResultDetectionConditionText=="*0.340"
replace ResultDetectionConditionText_ = "0.351" if ResultDetectionConditionText=="*0.351"
replace ResultDetectionConditionText_ = "103" if ResultDetectionConditionText=="*103."
replace ResultDetectionConditionText_ = "11.5" if ResultDetectionConditionText=="*11.5"
replace ResultDetectionConditionText_ = "116" if ResultDetectionConditionText=="*116."
replace ResultDetectionConditionText_ = "12" if ResultDetectionConditionText=="*12.0"
replace ResultDetectionConditionText_ = "131" if ResultDetectionConditionText=="*131."
replace ResultDetectionConditionText_ = "132" if ResultDetectionConditionText=="*132."
replace ResultDetectionConditionText_ = "133" if ResultDetectionConditionText=="*133."
replace ResultDetectionConditionText_ = "134" if ResultDetectionConditionText=="*134."
replace ResultDetectionConditionText_ = "136" if ResultDetectionConditionText=="*136."
replace ResultDetectionConditionText_ = "138" if ResultDetectionConditionText=="*138."
replace ResultDetectionConditionText_ = "141" if ResultDetectionConditionText=="*141."
replace ResultDetectionConditionText_ = "1430" if ResultDetectionConditionText=="*1430."
replace ResultDetectionConditionText_ = "16.2" if ResultDetectionConditionText=="*16.2"
replace ResultDetectionConditionText_ = "170" if ResultDetectionConditionText=="*170."
replace ResultDetectionConditionText_ = "1750" if ResultDetectionConditionText=="*1750."
replace ResultDetectionConditionText_ = "182" if ResultDetectionConditionText=="*182"
replace ResultDetectionConditionText_ = "188" if ResultDetectionConditionText=="*188."
replace ResultDetectionConditionText_ = "198" if ResultDetectionConditionText=="*198."
replace ResultDetectionConditionText_ = "20.1" if ResultDetectionConditionText=="*20.1"
replace ResultDetectionConditionText_ = "21.5" if ResultDetectionConditionText=="*21.5"
replace ResultDetectionConditionText_ = "229" if ResultDetectionConditionText=="*229."
replace ResultDetectionConditionText_ = "232" if ResultDetectionConditionText=="*232."
replace ResultDetectionConditionText_ = "245" if ResultDetectionConditionText=="*245"
replace ResultDetectionConditionText_ = "262" if ResultDetectionConditionText=="*262."
replace ResultDetectionConditionText_ = "272" if ResultDetectionConditionText=="*272."
replace ResultDetectionConditionText_ = "275" if ResultDetectionConditionText=="*275."
replace ResultDetectionConditionText_ = "3.5" if ResultDetectionConditionText=="*3.5"
replace ResultDetectionConditionText_ = "3.6" if ResultDetectionConditionText=="*3.6"
replace ResultDetectionConditionText_ = "3.8" if ResultDetectionConditionText=="*3.8"
replace ResultDetectionConditionText_ = "30.6" if ResultDetectionConditionText=="*30.6"
replace ResultDetectionConditionText_ = "31.6" if ResultDetectionConditionText=="*31.6"
replace ResultDetectionConditionText_ = "335" if ResultDetectionConditionText=="*335."
replace ResultDetectionConditionText_ = "34.2" if ResultDetectionConditionText=="*34.2"
replace ResultDetectionConditionText_ = "35.5" if ResultDetectionConditionText=="*35.5"
replace ResultDetectionConditionText_ = "352" if ResultDetectionConditionText=="*352"
replace ResultDetectionConditionText_ = "4.6" if ResultDetectionConditionText=="*4.6"
replace ResultDetectionConditionText_ = "4.7" if ResultDetectionConditionText=="*4.7"
replace ResultDetectionConditionText_ = "40.0" if ResultDetectionConditionText=="*40.0"
replace ResultDetectionConditionText_ = "424" if ResultDetectionConditionText=="*424."
replace ResultDetectionConditionText_ = "426" if ResultDetectionConditionText=="*426."
replace ResultDetectionConditionText_ = "44.8" if ResultDetectionConditionText=="*44.8"
replace ResultDetectionConditionText_ = "5.1" if ResultDetectionConditionText=="*5.1"
replace ResultDetectionConditionText_ = "5.4" if ResultDetectionConditionText=="*5.4"
replace ResultDetectionConditionText_ = "5.5" if ResultDetectionConditionText=="*5.5"
replace ResultDetectionConditionText_ = "5.6" if ResultDetectionConditionText=="*5.6"
replace ResultDetectionConditionText_ = "546" if ResultDetectionConditionText=="*546."
replace ResultDetectionConditionText_ = "6060" if ResultDetectionConditionText=="*6060."
replace ResultDetectionConditionText_ = "62.4" if ResultDetectionConditionText=="*62.4"
replace ResultDetectionConditionText_ = "6660" if ResultDetectionConditionText=="*6660."
replace ResultDetectionConditionText_ = "68.9" if ResultDetectionConditionText=="*68.9"
replace ResultDetectionConditionText_ = "76.4" if ResultDetectionConditionText=="*76.4"
replace ResultDetectionConditionText_ = "799" if ResultDetectionConditionText=="*799."
replace ResultDetectionConditionText_ = "82.7" if ResultDetectionConditionText=="*82.7"
replace ResultDetectionConditionText_ = "839" if ResultDetectionConditionText=="*839."
replace ResultDetectionConditionText_ = "84.9" if ResultDetectionConditionText=="*84.9"
replace ResultDetectionConditionText_ = "90.7" if ResultDetectionConditionText=="*90.7"
replace ResultDetectionConditionText_ = "95.9" if ResultDetectionConditionText=="*95.9"
replace ResultDetectionConditionText_ = "0.4" if ResultDetectionConditionText=="< 0.4"
replace ResultDetectionConditionText_ = "50" if ResultDetectionConditionText=="< 50"
replace ResultDetectionConditionText_ = "0.01" if ResultDetectionConditionText=="<.01"
replace ResultDetectionConditionText_ = "0.02" if ResultDetectionConditionText=="<0.02"
replace ResultDetectionConditionText_ = "1" if ResultDetectionConditionText=="<1.0"
replace ResultDetectionConditionText_ = "10" if ResultDetectionConditionText=="<10"
replace ResultDetectionConditionText_ = "2" if ResultDetectionConditionText=="<2.00"
replace ResultDetectionConditionText_ = "20" if ResultDetectionConditionText=="<20.0"
replace ResultDetectionConditionText_ = "1000" if ResultDetectionConditionText=="1,000"
replace ResultDetectionConditionText_ = "1138" if ResultDetectionConditionText=="1,138"
replace ResultDetectionConditionText_ = "1225" if ResultDetectionConditionText=="1,225"
replace ResultDetectionConditionText_ = "1313" if ResultDetectionConditionText=="1,313"
replace ResultDetectionConditionText_ = "1525" if ResultDetectionConditionText=="1,525"
replace ResultDetectionConditionText_ = "1593" if ResultDetectionConditionText=="1,593"
replace ResultDetectionConditionText_ = "1638" if ResultDetectionConditionText=="1,638"
replace ResultDetectionConditionText_ = "2225" if ResultDetectionConditionText=="2,225"
replace ResultDetectionConditionText_ = "3000" if ResultDetectionConditionText=="3,000"
replace ResultDetectionConditionText_ = "3325" if ResultDetectionConditionText=="3,325"
replace ResultDetectionConditionText_ = "115" if ResultDetectionConditionText=="~115"
replace ResultDetectionConditionText_ = "125" if ResultDetectionConditionText=="~125"
replace ResultDetectionConditionText_ = "0.1" if ResultDetectionConditionText=="<0.01"
replace ResultDetectionConditionText_ = "1650" if ResultDetectionConditionText=="1,650"
replace ResultDetectionConditionText_ ="10"   if ResultDetectionConditionText== "1.0E+001"
replace ResultDetectionConditionText_ ="11"   if ResultDetectionConditionText== "1.1E+001"
replace ResultDetectionConditionText_ ="1100" if ResultDetectionConditionText== "1.1E+003"
replace ResultDetectionConditionText_ ="12"   if ResultDetectionConditionText== "1.2E+001"
replace ResultDetectionConditionText_ ="120"  if ResultDetectionConditionText== "1.2E+002"
replace ResultDetectionConditionText_ ="13"   if ResultDetectionConditionText== "1.3E+001"
replace ResultDetectionConditionText_ ="14"   if ResultDetectionConditionText== "1.4E+001"
replace ResultDetectionConditionText_ ="1400" if ResultDetectionConditionText== "1.4E+003"
replace ResultDetectionConditionText_ ="15"   if ResultDetectionConditionText== "1.5E+001"
replace ResultDetectionConditionText_ ="16"   if ResultDetectionConditionText=="1.6E+001"
replace ResultDetectionConditionText_ ="1600" if ResultDetectionConditionText=="1.6E+003"
replace ResultDetectionConditionText_ ="17"   if ResultDetectionConditionText=="1.7E+001"
replace ResultDetectionConditionText_ ="18"   if ResultDetectionConditionText=="1.8E+001"
replace ResultDetectionConditionText_ ="19"   if ResultDetectionConditionText=="1.9E+001"
replace ResultDetectionConditionText_ ="20"   if ResultDetectionConditionText=="2.0E+001"
replace ResultDetectionConditionText_ ="21"   if ResultDetectionConditionText=="2.1E+001"
replace ResultDetectionConditionText_ ="22"   if ResultDetectionConditionText=="2.2E+001"
replace ResultDetectionConditionText_ ="23"   if ResultDetectionConditionText=="2.3E+001"
replace ResultDetectionConditionText_ ="24"   if ResultDetectionConditionText== "2.4E+001"
replace ResultDetectionConditionText_ ="25"   if ResultDetectionConditionText== "2.5E+001"
replace ResultDetectionConditionText_ ="26"   if ResultDetectionConditionText== "2.6E+001"
replace ResultDetectionConditionText_ ="27"   if ResultDetectionConditionText== "2.7E+001"
replace ResultDetectionConditionText_ ="28"   if ResultDetectionConditionText== "2.8E+001"
replace ResultDetectionConditionText_ ="29"   if ResultDetectionConditionText== "2.9E+001"
replace ResultDetectionConditionText_ ="30"   if ResultDetectionConditionText== "3.0E+001"
replace ResultDetectionConditionText_ ="31"   if ResultDetectionConditionText== "3.1E+001"
replace ResultDetectionConditionText_ ="3100" if ResultDetectionConditionText== "3.1E+003"
replace ResultDetectionConditionText_ ="32"   if ResultDetectionConditionText=="3.2E+001"
replace ResultDetectionConditionText_ ="33"   if ResultDetectionConditionText=="3.3E+001"
replace ResultDetectionConditionText_ ="34"   if ResultDetectionConditionText=="3.4E+001"
replace ResultDetectionConditionText_ ="35"   if ResultDetectionConditionText=="3.5E+001"
replace ResultDetectionConditionText_ ="36"   if ResultDetectionConditionText=="3.6E+001"
replace ResultDetectionConditionText_ ="38"   if ResultDetectionConditionText=="3.8E+001"
replace ResultDetectionConditionText_ ="39"   if ResultDetectionConditionText=="3.9E+001"
replace ResultDetectionConditionText_ ="4.1"  if ResultDetectionConditionText=="4.0999999999999996E+000"
replace ResultDetectionConditionText_ ="40"   if ResultDetectionConditionText=="4.0E+001"
replace ResultDetectionConditionText_ ="41"   if ResultDetectionConditionText=="4.1E+001"
replace ResultDetectionConditionText_ ="42"   if ResultDetectionConditionText=="4.2E+001"
replace ResultDetectionConditionText_ ="43"   if ResultDetectionConditionText=="4.3E+001"
replace ResultDetectionConditionText_ ="45"   if ResultDetectionConditionText=="4.5E+001"
replace ResultDetectionConditionText_ ="47"   if ResultDetectionConditionText=="4.7E+001"
replace ResultDetectionConditionText_ ="48"   if ResultDetectionConditionText=="4.8E+001"
replace ResultDetectionConditionText_ ="49"   if ResultDetectionConditionText=="4.9E+001"
replace ResultDetectionConditionText_ ="5"    if ResultDetectionConditionText=="5.0E+000"
replace ResultDetectionConditionText_ ="50"   if ResultDetectionConditionText=="5.0E+001"
replace ResultDetectionConditionText_ ="52"   if ResultDetectionConditionText=="5.2E+001"
replace ResultDetectionConditionText_ ="53"   if ResultDetectionConditionText=="5.3E+001"
replace ResultDetectionConditionText_ ="54"   if ResultDetectionConditionText=="5.4E+001"
replace ResultDetectionConditionText_ ="58"   if ResultDetectionConditionText=="5.8E+001"
replace ResultDetectionConditionText_ ="60"   if ResultDetectionConditionText=="6.0E+001"
replace ResultDetectionConditionText_ ="600"  if ResultDetectionConditionText=="6.0E+002"
replace ResultDetectionConditionText_ ="62"   if ResultDetectionConditionText=="6.2E+001"
replace ResultDetectionConditionText_ ="63"   if ResultDetectionConditionText=="6.3E+001"
replace ResultDetectionConditionText_ ="6.4"  if ResultDetectionConditionText=="6.4000000000000004E+000"
replace ResultDetectionConditionText_ ="6.6"  if ResultDetectionConditionText=="6.5999999999999996E+000"
replace ResultDetectionConditionText_ ="7"    if ResultDetectionConditionText=="6.9000000000000004E+000"
replace ResultDetectionConditionText_ ="71"   if ResultDetectionConditionText=="7.1E+001"
replace ResultDetectionConditionText_ ="73"   if ResultDetectionConditionText=="7.3E+001"
replace ResultDetectionConditionText_ ="79"   if ResultDetectionConditionText=="7.9E+001"
replace ResultDetectionConditionText_ ="8.2"  if ResultDetectionConditionText=="8.1999999999999993E+000"
replace ResultDetectionConditionText_ ="8.5"  if ResultDetectionConditionText=="8.5E+000"
replace ResultDetectionConditionText_ ="9.7"  if ResultDetectionConditionText=="9.6999999999999993E+000"
replace ResultDetectionConditionText_ ="98"   if ResultDetectionConditionText=="9.8E+001"

// To "Non-Detected"
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="Not Detected"
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="ND"
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="*NOT DETECTED  "
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="*Non-detect"
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="*Non-detect    "
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="*Not Detected"
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="*Not Detected  "
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="*Not detected  "
replace ResultDetectionConditionText_ = "Not Detected" if ResultDetectionConditionText=="non detect"

// To "Present Above Quantification Limit"
replace ResultDetectionConditionText_ = "Present Above Quantification Limit" if ResultDetectionConditionText=="Present Above Quantification Limit"

// To "Present Below Quantification Limit"
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="Present Below Quantification Limit"
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="*Present"
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="*Present <QL"
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="*Present <QL   "
replace ResultDetectionConditionText_ = "Present Below Quantification Limit" if ResultDetectionConditionText=="BDL"

// To "Not Reported"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="Not Reported"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="NO DATA FOUND IN BENCH BOOK"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="NO RESULTS FOUND IN BENCH BOOK"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="NOT FOUND IN BENCH BOOK"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="NO"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="NR"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="*SP"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="NRP"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="RESULTS NOT FOUND IN BENCH BOOK"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="SEE COMMENT"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="VALUE NOT RECORDED"
replace ResultDetectionConditionText_ = "Not Reported" if ResultDetectionConditionText=="Detected Not Quantified"
g check_NR = substr(ResultDetectionConditionText_, 1, 7)
br ResultDetectionConditionText_ if check_NR=="NO DATA"
br ResultDetectionConditionText_ if check_NR=="NO RESU"
replace ResultDetectionConditionText_ = "Not Reported" if check_NR=="NO DATA" 
replace ResultDetectionConditionText_ = "Not Reported" if check_NR=="NO RESU"
drop check_NR

tab ResultDetectionConditionText_ if Ch =="Barium" | ///
									 Ch =="Bromide" | ///
									 Ch =="Chloride" | ///
									 Ch =="Strontium"

// Generate ResultDetectionConditionValue, i.e., variable that takes the value of the detection limit if available 
g ResultDetectionConditionValue = ResultDetectionConditionText_ if ResultDetectionConditionText_!="NA" & ///
ResultDetectionConditionText_!="Not Detected" & ///
ResultDetectionConditionText_!="Not Reported" & ///
ResultDetectionConditionText_!="Present Above Quantification Limit"  & ///
ResultDetectionConditionText_!="Present Below Quantification Limit"  & ///
ResultDetectionConditionText_!="Systematic Contamination" & ///
(Ch =="Barium" | Ch =="Bromide" | Ch =="Chloride" | Ch =="Strontium")
destring ResultDetectionConditionValue, replace
replace ResultDetectionConditionValue = ResultDetectionConditionValue / 2 // we take 1/2 of the detection limit

// Generate the Three Alternative Measurement Versions

	** Option 1
	g ResultMeasureValue_clean1 = ResultMeasureValue // original measurement variable
	* to missing
	replace ResultMeasureValue_clean1 =. if ResultDetectionConditionText_!=""

	** Option 2
	g ResultMeasureValue_clean2 = ResultMeasureValue // original measurement variable
	* to the limit
	replace ResultMeasureValue_clean2 = ResultDetectionConditionValue if ResultDetectionConditionText_!="NA" & ///
	ResultDetectionConditionText_!="Not Detected" & ///
	ResultDetectionConditionText_!="Not Reported" & ///
	ResultDetectionConditionText_!="Present Above Quantification Limit" & ///
	ResultDetectionConditionText_!="Present Below Quantification Limit" & ///
	ResultDetectionConditionText_!="Systematic Contamination" & ///
	ResultDetectionConditionText_!=""
	* to zero
	replace ResultMeasureValue_clean2 = 0 if ResultDetectionConditionText_=="Not Detected"
	* to missing
	replace ResultMeasureValue_clean2 = . if ResultDetectionConditionText_!="" & ///
	(ResultDetectionConditionText_=="NA" | ///
	ResultDetectionConditionText_=="Not Reported"  & ///
	ResultDetectionConditionText_=="Present Above Quantification Limit"  | ///
	ResultDetectionConditionText_=="Present Below Quantification Limit"  | ///
	ResultDetectionConditionText_=="Systematic Contamination")

	** Option 3
	g ResultMeasureValue_clean3 = ResultMeasureValue // original measurement variable
	* to the limit
	replace ResultMeasureValue_clean3 = ResultDetectionConditionValue if ResultDetectionConditionText_!="NA" & ///
	ResultDetectionConditionText_!="Not Detected" & ///
	ResultDetectionConditionText_!="Not Reported" & ///
	ResultDetectionConditionText_!="Present Above Quantification Limit" & ///
	ResultDetectionConditionText_!="Present Below Quantification Limit" & ///
	ResultDetectionConditionText_!="Systematic Contamination" & ///
	ResultDetectionConditionText_!=""
	* to zero
	replace ResultMeasureValue_clean3 = 0 if ResultDetectionConditionText_=="Not Detected"
	replace ResultMeasureValue_clean3 = 0 if ResultDetectionConditionText_=="Present Below Quantification Limit"
	* to missing
	replace ResultMeasureValue_clean3 = . if ResultDetectionConditionText_!="" & ///
	(ResultDetectionConditionText_=="NA" | ///
	ResultDetectionConditionText_=="Not Reported" | ///
	ResultDetectionConditionText_=="Present Above Quantification Limit" | ///
	ResultDetectionConditionText_=="Systematic Contamination")
	
*************************************
*** Drop Bed Sediment & Suspended ***
*************************************
	
drop if ResultSampleFractionText =="Bed Sediment"
drop if ResultSampleFractionText =="Suspended"

drop if USGSPCode =="01008"
drop if USGSPCode =="01376"
drop if USGSPCode =="29820"
drop if USGSPCode =="34805"
drop if USGSPCode =="34965"
drop if USGSPCode =="35040"
drop if USGSPCode =="30305"
drop if USGSPCode =="62951"

************************************
*** Convert Measurements to mg/l ***
************************************

// manually checked
replace ResultMeasureMeasureUnitCode ="ug/l" if ActivityStartDate=="2013-11-13" & MonitoringLocationIdentifier=="21OHIO_WQX-301184" & CharacteristicName=="Barium"
replace ResultMeasureMeasureUnitCode ="ug/l" if ActivityStartDate=="2013-11-13" & MonitoringLocationIdentifier=="21OHIO_WQX-301183" & CharacteristicName=="Barium"
replace ResultMeasureMeasureUnitCode ="ug/l" if ActivityStartDate=="2013-11-13" & MonitoringLocationIdentifier=="21OHIO_WQX-301182" & CharacteristicName=="Barium"
replace ResultMeasureMeasureUnitCode ="ug/l" if ActivityStartDate=="2013-11-13" & MonitoringLocationIdentifier=="21OHIO_WQX-N03S51" & CharacteristicName=="Barium"

local Ys ""ResultMeasureValue" "ResultMeasureValue_clean1" "ResultMeasureValue_clean2" "ResultMeasureValue_clean3""
foreach y of local Ys {

replace `y' = `y'/1000   	 if ResultMeasureMeasureUnitCode == "ug/l"
replace `y' = `y'/1000   	 if ResultMeasureMeasureUnitCode == "ug/kg"
replace `y' = `y'/1000    	 if ResultMeasureMeasureUnitCode == "ppb"
replace `y' = `y'*35/1000    if ResultMeasureMeasureUnitCode == "ueq/L"
replace `y' = `y'        	 if ResultMeasureMeasureUnitCode == "ug/g"

// non-relevant ResultMeasureMeasureUnitCode given the considered chemicals
drop if ResultMeasureMeasureUnitCode=="#/100 gal"
drop if ResultMeasureMeasureUnitCode=="Mole/l"
drop if ResultMeasureMeasureUnitCode=="NTU"
drop if ResultMeasureMeasureUnitCode=="MPN"
drop if ResultMeasureMeasureUnitCode=="S/m"
drop if ResultMeasureMeasureUnitCode=="cm3/g @STP"
drop if ResultMeasureMeasureUnitCode=="deg C"
drop if ResultMeasureMeasureUnitCode=="kgal"
drop if ResultMeasureMeasureUnitCode=="mS/cm"
drop if ResultMeasureMeasureUnitCode=="mV"
drop if ResultMeasureMeasureUnitCode=="meq/L"
drop if ResultMeasureMeasureUnitCode=="mg/l CaCO3"
drop if ResultMeasureMeasureUnitCode=="nu"
drop if ResultMeasureMeasureUnitCode=="psi"
drop if ResultMeasureMeasureUnitCode=="uS/cm"
drop if ResultMeasureMeasureUnitCode=="umol"
drop if ResultMeasureMeasureUnitCode == "mg/kg"
}
//

// Append shalenetwork data [already cleaned and w/ the same key variables]
append using "$dir1/1. Water quality data/Hydro.dta"

// Create Water Measurements at the CharacteristicName MonitoringLocationTypeName ID_geo year month day Level
rename ResultMeasureValue Value
rename ResultMeasureValue_clean1 Value_clean1 
rename ResultMeasureValue_clean2 Value_clean2 
rename ResultMeasureValue_clean3 Value_clean3 

local Ys ""Value" "Value_clean1" "Value_clean2" "Value_clean3""
foreach y of local Ys {
bysort CharacteristicName MonitoringLocationTypeName ID_geo year month day: egen median_geo_`y' = median(`y')
bysort CharacteristicName MonitoringLocationTypeName ID_geo year month day: egen mean_geo_`y' = mean(`y')
bysort CharacteristicName MonitoringLocationTypeName ID_geo year month day: egen max_geo_`y' = max(`y')
bysort CharacteristicName MonitoringLocationTypeName ID_geo year month day: egen min_geo_`y' = min(`y')
}
//

// SAVE 3rd emporary file
save temp_2_w, replace

// Collapse data at the CharacteristicName MonitoringLocationTypeName ID_geo year month day Level
use temp_2_w, clear
bysort CharacteristicName MonitoringLocationTypeName ID_geo year month day: gen ok_ID_geo = 1 if day==day[_n+1] // equivalent to collapse
keep if ok_ID_geo ==.

drop ok_ID_geo  date_string ActivityStartTimeTime ActivityStartTimeTimeZoneCode ///
 MeasureQualifierCode ResultStatusIdentifier ///
 DetectionQuantitationLimitTypeNa AquiferName AquiferTypeName ///
 USGSPCode  SubjectTaxonomicName ResultAnalyticalMethodMethodIde BA ResultAnalyticalMethodMethodNam ///
 StatisticalBaseCode ResultValueTypeName ResultWeightBasisText ResultTimeBasisText ResultTemperatureBasisText ResultParticleSizeBasisText ///
 ActivityMediaName AB SampleCollectionEquipmentName SampleCollectionMethodMethodNam

// drop non relevant Ions
keep if Ch =="Barium" | Ch =="Bromide" | Ch =="Chloride" | Ch =="Strontium"

g TYPE = "Groundwater" if MonitoringLocationTypeName=="Groundwater"
replace TYPE = "Surfacewater" if TYPE=="" 
destring year, replace
compress

save "$dir1/1. Water quality data/water_quality_data_daily_wqs_buffer_new_NOV_2019_id_geo.dta", replace

// Files w/ Monitoring Stations linked to HUC10s - #247,853 unique wq stations from "station_to_import_GIS"
clear
cd "$dir1/"
// QGIS ASSIGNEMENT
import delimited "huc10/huc10 wqs/huc10_wqs.csv" //  171,318
drop x y org tnmid metasource sourcedata sourceorig sourcefeat loaddate gnis states name hutype humod huceightdi
save "huc10/huc10 wqs/huc10_wqs_temp.dta", replace

// non-merging stations
clear
import delimited "1. Water quality data/station file/station_to_import_GIS.csv" //  247,853
rename monitoringlocationidentifier monitoring
drop org huce state county
isid monitoring
merge 1:1 monitoring using "huc10/huc10 wqs/huc10_wqs_temp.dta"
keep if _merge == 1 // keep non merging stations only
keep monitoring latitudemeasure longitudemeasure
compress
export delimited using "huc10/huc10 wqs/to add.csv", replace
// QGIS ASSIGNEMENT
import delimited "huc10/huc10 wqs/huc10_to add.csv", clear //  72,256
drop x y  tnmid metasource sourcedata sourceorig sourcefeat loaddate gnis states name hutype humod
save "huc10/huc10 wqs/huc10_to add.dta", replace

// append 
use "huc10/huc10 wqs/huc10_wqs_temp.dta", clear
append using "huc10/huc10 wqs/huc10_to add.dta"
append using "1. Water quality data/hydrodesktop/HD distance to append.dta"

drop shape_leng shape_area longitudem latitudeme statecode countycode

cap drop huc10_s
tostring huc10, gen(huc10_s)
g huc10_l = length(huc10_s) 
replace huc10_s = "0" + huc10_s if huc10_l ==9
drop huc10_l
compress

save "huc10/huc10 wqs/huc10_wqs_final.dta", replace
