#!/bin/bash

Altitude_HIGH_WARN=80
Altitude_HIGH_CRIT=95
Altitude_LOW_WARN=20
Altitude_LOW_CRIT=5

Humidity_HIGH_WARN=80
Humidity_HIGH_CRIT=95
Humidity_LOW_WARN=20
Humidity_LOW_CRIT=5

Luminosity_HIGH_WARN=80
Luminosity_HIGH_CRIT=95
Luminosity_LOW_WARN=20
Luminosity_LOW_CRIT=5

Pressure_HIGH_WARN=80
Pressure_HIGH_CRIT=95
Pressure_LOW_WARN=20
Pressure_LOW_CRIT=5

Status_HIGH_WARN=80
Status_HIGH_CRIT=95
Status_LOW_WARN=20
Status_LOW_CRIT=5

TemperatureMPL3115_HIGH_WARN=80
TemperatureMPL3115_HIGH_CRIT=95
TemperatureMPL3115_LOW_WARN=20
TemperatureMPL3115_LOW_CRIT=5

TemperatureHDC1080_HIGH_WARN=80
TemperatureHDC1080_HIGH_CRIT=95
TemperatureHDC1080_LOW_WARN=20
TemperatureHDC1080_LOW_CRIT=5

UVA_HIGH_WARN=80
UVA_HIGH_CRIT=95
UVA_LOW_WARN=20
UVA_LOW_CRIT=5

UVB_HIGH_WARN=80
UVB_HIGH_CRIT=95
UVB_LOW_WARN=20
UVB_LOW_CRIT=5

UVcomp1_HIGH_WARN=80
UVcomp1_HIGH_CRIT=95
UVcomp1_LOW_WARN=20
UVcomp1_LOW_CRIT=5

UVcomp2_HIGH_WARN=80
UVcomp2_HIGH_CRIT=95
UVcomp2_LOW_WARN=20
UVcomp2_LOW_CRIT=5

Voltage_HIGH_WARN=80
Voltage_HIGH_CRIT=95
Voltage_LOW_WARN=20
Voltage_LOW_CRIT=5


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
