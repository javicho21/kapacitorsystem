#!/bin/bash

Altitude_HIGH_WARN=80
Altitude_HIGH_CRIT=95
Altitude_LOW_WARN=20
Altitude_LOW_CRIT=15

Acceleration_HIGH_WARN=80
Acceleration_HIGH_CRIT=95
Acceleration_LOW_WARN=20
Acceleration_LOW_CRIT=15

AirQuality_HIGH_WARN=80
AirQuality_HIGH_CRIT=95
AirQuality_LOW_WARN=20
AirQuality_LOW_CRIT=15

Battery_status_HIGH_WARN=80
Battery_status_HIGH_CRIT=95
Battery_status_LOW_WARN=20
Battery_status_LOW_CRIT=15

Battery_voltage_HIGH_WARN=80
Battery_voltage_HIGH_CRIT=95
Battery_voltage_LOW_WARN=20
Battery_voltage_LOW_CRIT=15

CO_level_HIGH_WARN=80
CO_level_HIGH_CRIT=95
CO_level_LOW_WARN=20
CO_level_LOW_CRIT=15

CarbonMonoxide_HIGH_WARN=80
CarbonMonoxide_HIGH_CRIT=95
CarbonMonoxide_LOW_WARN=20
CarbonMonoxide_LOW_CRIT=15

Humidity_HIGH_WARN=80
Humidity_HIGH_CRIT=95
Humidity_LOW_WARN=20
Humidity_LOW_CRIT=15

IndoorAirQuality_HIGH_WARN=80
IndoorAirQuality_HIGH_CRIT=95
IndoorAirQuality_LOW_WARN=20
IndoorAirQuality_LOW_CRIT=15

Methane_HIGH_WARN=80
Methane_HIGH_CRIT=95
Methane_LOW_WARN=20
Methane_LOW_CRIT=15

Pressure_HIGH_WARN=80
Pressure_HIGH_CRIT=95
Pressure_LOW_WARN=20
Pressure_LOW_CRIT=15

Status_HIGH_WARN=80
Status_HIGH_CRIT=95
Status_LOW_WARN=20
Status_LOW_CRIT=15

Temperature_HIGH_WARN=80
Temperature_HIGH_CRIT=95
Temperature_LOW_WARN=20
Temperature_LOW_CRIT=15

UV-A_HIGH_WARN=80
UV-A_HIGH_CRIT=95
UV-A_LOW_WARN=20
UV-A_LOW_CRIT=15

UV-B_HIGH_WARN=80
UV-B_HIGH_CRIT=95
UV-B_LOW_WARN=20
UV-B_LOW_CRIT=15

UVA_HIGH_WARN=80
UVA_HIGH_CRIT=95
UVA_LOW_WARN=20
UVA_LOW_CRIT=15

UVAcomp1_HIGH_WARN=80
UVAcomp1_HIGH_CRIT=95
UVAcomp1_LOW_WARN=20
UVAcomp1_LOW_CRIT=15

UVAcomp2_HIGH_WARN=80
UVAcomp2_HIGH_CRIT=95
UVAcomp2_LOW_WARN=20
UVAcomp2_LOW_CRIT=15

UVB_HIGH_WARN=80
UVB_HIGH_CRIT=95
UVB_LOW_WARN=20
UVB_LOW_CRIT=15

UVComp1_HIGH_WARN=80
UVComp1_HIGH_CRIT=95
UVComp1_LOW_WARN=20
UVComp1_LOW_CRIT=15

UVComp2_HIGH_WARN=80
UVComp2_HIGH_CRIT=95
UVComp2_LOW_WARN=20
UVComp2_LOW_CRIT=15

Voltage_HIGH_WARN=80
Voltage_HIGH_CRIT=95
Voltage_LOW_WARN=20
Voltage_LOW_CRIT=15

WaterPressure_HIGH_WARN=80
WaterPressure_HIGH_CRIT=95
WaterPressure_LOW_WARN=20
WaterPressure_LOW_CRIT=15

RESPONSE=$(curl -Gs "http://10.142.0.2:8086/query" --data-urlencode "db=sensormetrics" --data-urlencode "q=SHOW MEASUREMENTS" | jq --raw-output "if .results[].series == null then null else .results[].series[].values[][] end" | sed "s/\\$/_/g" )

if [[ ${RESPONSE} != "null" ]]; then

	MEASUREMENTS=( ${RESPONSE} )
	echo "Creating tasks for ${MEASUREMENTS}"
	for MEASUREMENT in "${MEASUREMENTS[@]}"
	do
		echo "Creating 2 tasks for ${MEASUREMENT}"

		
		## to remove strange characters
		CLEAN_MEASUREMENT=$(echo "$MEASUREMENT" | tr -d . | tr -d '(' | tr -d ')')

		HIGH_WARN_VAR="${CLEAN_MEASUREMENT}_HIGH_WARN"
		HIGH_CRIT_VAR="${CLEAN_MEASUREMENT}_HIGH_CRIT"
		LOW_WARN_VAR="${CLEAN_MEASUREMENT}_LOW_WARN"
		LOW_CRIT_VAR="${CLEAN_MEASUREMENT}_LOW_CRIT"

		## GENERATING HIGH THRESHOLDS
		cat ticks/high-threshold.template | sed -e "s/__MEASUREMENT__/${MEASUREMENT}/g" -e "s/__WARN_THRESHOLD__/${!HIGH_WARN_VAR}/g" -e "s/__CRIT_THRESHOLD__/${!HIGH_CRIT_VAR}/g" > ticks/${MEASUREMENT}_HIGH_TASK.tick
		kapacitor define "${CLEAN_MEASUREMENT}_HIGH_TASK" -dbrp sensormetrics.autogen -type batch -tick ticks/${MEASUREMENT}_HIGH_TASK.tick
		kapacitor enable "${CLEAN_MEASUREMENT}_HIGH_TASK"

		## GENERATING LOW THRESHOLDS
		cat ticks/low-threshold.template | sed -e "s/__MEASUREMENT__/${MEASUREMENT}/g" -e "s/__WARN_THRESHOLD__/${!LOW_WARN_VAR}/g" -e "s/__CRIT_THRESHOLD__/${!LOW_CRIT_VAR}/g" > ticks/${MEASUREMENT}_LOW_TASK.tick
		kapacitor define "${CLEAN_MEASUREMENT}_LOW_TASK" -dbrp sensormetrics.autogen -type batch -tick ticks/${MEASUREMENT}_LOW_TASK.tick
		kapacitor enable "${CLEAN_MEASUREMENT}_LOW_TASK"
	done
else
	echo "No MEASUREMENTS found"
fi
