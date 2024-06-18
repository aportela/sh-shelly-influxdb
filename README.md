# sh-shelly-influxdb

Do you need a simple way to send data from Shelly smart plugs to an InfluxDB database without complicating things with dependencies? This is your script.

It only requires having the command-line tools curl and jq installed.

You need to have access credentials (password) configured for your Shelly device and have the RPC API enabled. The script assumes that all devices share the same credentials (password).

## TODO

create debian package & use systemd to avoid repetitive looping every 10 seconds in the script

## Grafana

Here are some example (NOTE: change 111111111111 to your real MAC address) queries to visualize data in Grafana with line charts:

### Current power (watts)

```SQL
SELECT mean("power") FROM "autogen"."smarthome" WHERE ("brand"::tag = 'Shelly' AND "type"::tag = 'plug' AND "mac"::tag = '111111111111') AND $timeFilter GROUP BY time($__interval) fill(none)
```

### Energy (kW/hour)

```SQL
SELECT "energy" FROM "autogen"."smarthome" WHERE ("type"::tag = 'plug' AND "brand"::tag = 'Shelly' AND "mac"::tag = '111111111111') AND $timeFilter
```

### Voltage

```SQL
SELECT mean("voltage") FROM "autogen"."smarthome" WHERE ("type"::tag = 'plug' AND "brand"::tag = 'Shelly' AND "mac"::tag = '111111111111') AND $timeFilter GROUP BY time($__interval) fill(none)
```

### Temperature

```SQL
SELECT mean("temperature") FROM "autogen"."smarthome" WHERE ("type"::tag = 'plug' AND "brand"::tag = 'Shelly' AND "mac"::tag = '111111111111') AND $timeFilter GROUP BY time($__interval) fill(none)
```
