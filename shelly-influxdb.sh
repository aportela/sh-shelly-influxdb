#!/bin/sh

# 2024-06-18 tests made with
# Devices: Shelly PlusPlugS (firmware 1.3.2)
# influxdb 1.8.10

# curl required (for requests)
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl not found."
    exit 1
fi

# jq required (for json parsing)
if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq not found."
    exit 1
fi

show_help() {
    echo "Usage: $0 configuration_path"
    exit 1
}

if [ $# -ge 1 ]; then
    if [ -f "$1" ]; then
        CONFIGURATION_FILE="$1"
        . "$CONFIGURATION_FILE"
    else
        echo "Error: configuration file '$1' does not exist."
        exit 1
    fi
else
    show_help
fi

# for each device
for host in $DEVICE_HOSTS; do
    # generate shelly RPC API url
    SHELLY_HOST_RPC_URL="http://$host/rpc/Shelly.GetStatus"
    # curl response will be parsed with jq using this scheme (compatible with influxdb api payload)
    # NOTE that (shelly) timestamp is converted (* 1000000000) to nano seconds (for compatibility with influxdb)
    JQ_FORMAT=$(
        cat <<EOF
            "$INFLUXDB_PAYLOAD_TABLE,type=plug,brand=Shelly,mac=" + .sys.mac + " power=" + (.["switch:0"].apower|tostring) + ",voltage=" + (.["switch:0"].voltage|tostring) + ",energy=" + (.["switch:0"].aenergy.total|tostring) + ",temperature=" + (.["switch:0"].temperature.tC|tostring) + " " + (.sys.unixtime * 1000000000|tostring)
EOF
    )
    # get shelly RPC API (JSON) response and parse/generate influxdb api payload data
    INFLUXDB_API_PAYLOAD=$(curl -s --anyauth -u "admin:$SHELLY_PASSWORD" -X GET "$SHELLY_HOST_RPC_URL" | jq -r "$JQ_FORMAT")
    if [ $? -ne 0 ]; then
        # shelly RPC API error
        echo "Shelly RPC API ERRROR at: $SHELLY_HOST_RPC_URL"
        continue
    else
        # send to influxdb
        curl -s -u "$INFLUXDB_USERNAME:$INFLUXDB_PASSWORD" -X POST "$INFLUXDB_API_URL" --data-binary "$INFLUXDB_API_PAYLOAD"
        if [ $? -ne 0 ]; then
            # influxdb API error
            echo "InfluxDB API ERRROR at: $INFLUXDB_API_URL"
        fi
    fi
done
