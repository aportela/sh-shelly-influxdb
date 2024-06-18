# sh-shelly-influxdb

Do you need a simple way to send data from Shelly smart plugs to an InfluxDB database without complicating things with dependencies? This is your script.

It only requires having the command-line tools curl and jq installed.

You need to have access credentials (password) configured for your Shelly device and have the RPC API enabled. The script assumes that all devices share the same credentials (password).

## INSTALL

Copy **shelly-infuxdb.sh** to **/usr/local/bin**

Add exec permissions to **shelly-influxdb.sh**

> sudo chmod +x /usr/local/bin/shelly-influxdb.sh

Copy **shelly-influxdb.conf** to **/usr/local/etc** and customize/edit your settings

## USAGE

### Manual launch:

> sh /usr/local/bin/shelly-influxdb.sh /usr/local/etc/shelly-influxdb.conf

### systemd

Create service definition:

> cat > /etc/systemd/system/shelly-influxdb.service

```
[Unit]
Description=Run shelly influxdb script every 10 seconds

[Service]
Type=simple
ExecStart=/bin/sh -c 'while true; do /usr/local/bin/shelly-influxdb.sh /usr/local/etc/shelly-influxdb.conf; sleep 10; done'

[Install]
WantedBy=multi-user.target
```

NOTE: avoid log flooding (every 10 seconds) on /etc/systemd/system/shelly-influxdb.service redirecting stdout & stderr to null

```
[Unit]
Description=Run shelly influxdb script every 10 seconds

[Service]
Type=simple
ExecStart=/bin/sh -c 'while true; do /usr/local/bin/shelly-influxdb.sh /usr/local/etc/shelly-influxdb.conf; sleep 10; done'
StandardOutput=null
StandardError=null

[Install]
WantedBy=multi-user.target
```

Reload services

> sudo systemctl daemon-reload
>
> sudo systemctl restart shelly-influxdb.service

Verify service status

> sudo systemctl status shelly-influxdb.service

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

## TODO

create debian package
