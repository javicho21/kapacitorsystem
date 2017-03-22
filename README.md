# Tick Scripts for Kapacitor

This project presents a couple of tick scripts to be used in kapacitor.

## How to use

To change the thresholds we must change the values in deploy_tasks.sh and execute the bash script where kapacitor is running.

```
MEASUREMENTA_HIGH_WARN=170
MEASUREMENTA_HIGH_CRIT=200
MEASUREMENTA_LOW_WARN=20
MEASUREMENTA_LOW_CRIT=5

Pressure_HIGH_WARN=80
Pressure_HIGH_CRIT=95
Pressure_LOW_WARN=20
Pressure_LOW_CRIT=5

....

```

To install the tick tasks run the deploy_tasks.sh
```
bash deploy_tasks.sh
```


## Aditional remarks

The alerts are being stored again on influxDB on database alerts with ["MEASUREMENT"]