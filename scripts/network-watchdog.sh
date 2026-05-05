#!/usr/bin/env bash
# Network Watchdog — auto-recovers WiFi + verifies VPN when network drops
# Runs via launchd every 30s and on network state changes

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/network-watchdog.conf"

# --- Logging ---

log() {
    local level="$1"; shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" >> "$LOG_FILE"
}

rotate_log() {
    if [[ -f "$LOG_FILE" ]] && (( $(stat -f%z "$LOG_FILE" 2>/dev/null || echo 0) > MAX_LOG_SIZE )); then
        mv "$LOG_FILE" "${LOG_FILE}.1"
        log "INFO" "Log rotated"
    fi
}

# --- WiFi Functions ---

get_wifi_power() {
    networksetup -getairportpower "$WIFI_INTERFACE" 2>/dev/null | grep -qi "on" && echo "on" || echo "off"
}

get_wifi_ssid() {
    local output
    output=$(networksetup -getairportnetwork "$WIFI_INTERFACE" 2>/dev/null)
    if echo "$output" | grep -q "You are not associated"; then
        echo ""
    else
        echo "$output" | sed 's/.*: //'
    fi
}

is_internet_reachable() {
    curl --connect-timeout 3 -sf "http://captive.apple.com/hotspot-detect.html" >/dev/null 2>&1
}

get_wifi_password() {
    local ssid="$1"
    # Try user account first, then SAP account
    security find-generic-password -a "$USER" -s "WIFI_${ssid}" -w 2>/dev/null \
        || security find-generic-password -a "I583713" -s "WIFI_${ssid}" -w 2>/dev/null
}

# --- VPN Functions ---

is_gp_connected() {
    ifconfig 2>/dev/null | grep -q "utun"
}

wait_for_gp() {
    if [[ "$GP_AUTO_RECONNECTS" != "true" ]]; then
        return 0
    fi

    log "INFO" "Waiting up to ${GP_WAIT_AFTER_WIFI}s for GlobalProtect..."
    local elapsed=0
    while (( elapsed < GP_WAIT_AFTER_WIFI )); do
        if is_gp_connected; then
            log "INFO" "GlobalProtect tunnel restored"
            return 0
        fi
        sleep 3
        (( elapsed += 3 ))
    done

    log "WARN" "GlobalProtect not reconnected after ${GP_WAIT_AFTER_WIFI}s (may take longer)"
    return 1
}

# --- Backoff ---

check_backoff() {
    if [[ -f "$BACKOFF_FILE" ]]; then
        local age=$(( $(date +%s) - $(stat -f%m "$BACKOFF_FILE") ))
        if (( age < BACKOFF_DURATION )); then
            log "INFO" "In backoff period (${age}s/${BACKOFF_DURATION}s). Skipping."
            exit 0
        else
            rm -f "$BACKOFF_FILE"
        fi
    fi
}

set_backoff() {
    touch "$BACKOFF_FILE"
}

clear_backoff() {
    rm -f "$BACKOFF_FILE"
}

# --- Reconnection ---

reconnect_wifi() {
    for ssid in "${PREFERRED_SSIDS[@]}"; do
        local password
        password=$(get_wifi_password "$ssid")
        if [[ -z "$password" ]]; then
            log "DEBUG" "No password stored for $ssid, skipping"
            continue
        fi

        log "INFO" "Attempting to join: $ssid"
        networksetup -setairportnetwork "$WIFI_INTERFACE" "$ssid" "$password" 2>/dev/null
        sleep 4

        if [[ -n "$(get_wifi_ssid)" ]]; then
            log "INFO" "Joined WiFi: $ssid"
            return 0
        fi
    done

    # All SSIDs failed — power cycle
    log "WARN" "All SSIDs failed. Power-cycling WiFi..."
    networksetup -setairportpower "$WIFI_INTERFACE" off
    sleep 3
    networksetup -setairportpower "$WIFI_INTERFACE" on
    sleep 5

    # Retry once after power cycle
    for ssid in "${PREFERRED_SSIDS[@]}"; do
        local password
        password=$(get_wifi_password "$ssid")
        [[ -z "$password" ]] && continue

        networksetup -setairportnetwork "$WIFI_INTERFACE" "$ssid" "$password" 2>/dev/null
        sleep 4
        if [[ -n "$(get_wifi_ssid)" ]]; then
            log "INFO" "Joined WiFi after power cycle: $ssid"
            return 0
        fi
    done

    return 1
}

# --- Notifications ---

notify() {
    local event="$1"
    local ssid="$2"
    local gp_status="$3"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "${event}|${timestamp}|SSID=${ssid}|GP=${gp_status}" > "$STATUS_FILE"

    if [[ "$USE_MACOS_NOTIFICATION" == "true" ]]; then
        local msg
        if [[ "$event" == "RECOVERED" ]]; then
            msg="WiFi reconnected to ${ssid}. VPN: ${gp_status}"
        else
            msg="Network recovery failed after ${MAX_RECONNECT_ATTEMPTS} attempts"
        fi
        osascript -e "display notification \"$msg\" with title \"Network Watchdog\"" 2>/dev/null
    fi
}

# --- Main ---

main() {
    rotate_log

    # Check if WiFi is connected and internet works
    local ssid
    ssid=$(get_wifi_ssid)

    if [[ -n "$ssid" ]]; then
        if is_internet_reachable; then
            clear_backoff
            exit 0
        fi
        # WiFi associated but no internet — wait briefly
        sleep 5
        if is_internet_reachable; then
            clear_backoff
            exit 0
        fi
        log "WARN" "WiFi connected ($ssid) but no internet"
    fi

    # Network is down
    log "ALERT" "Network down. WiFi SSID: '${ssid:-none}'"
    check_backoff

    # Ensure WiFi radio is on
    if [[ "$(get_wifi_power)" == "off" ]]; then
        log "INFO" "WiFi power OFF. Turning on..."
        networksetup -setairportpower "$WIFI_INTERFACE" on
        sleep 5
    fi

    # Attempt recovery
    local attempt=0
    while (( attempt < MAX_RECONNECT_ATTEMPTS )); do
        (( attempt++ ))
        log "INFO" "Recovery attempt $attempt/$MAX_RECONNECT_ATTEMPTS"

        if reconnect_wifi; then
            # WiFi is back — check internet
            sleep 2
            if is_internet_reachable; then
                clear_backoff
                local new_ssid
                new_ssid=$(get_wifi_ssid)

                # Wait for GlobalProtect
                local gp="skipped"
                if [[ "$GP_AUTO_RECONNECTS" == "true" ]]; then
                    if wait_for_gp; then
                        gp="connected"
                    else
                        gp="pending"
                    fi
                fi

                log "INFO" "RECOVERED: WiFi=$new_ssid GP=$gp"
                notify "RECOVERED" "$new_ssid" "$gp"
                exit 0
            fi
        fi
        sleep 3
    done

    # All attempts exhausted
    log "ERROR" "Recovery FAILED after $MAX_RECONNECT_ATTEMPTS attempts. Backing off ${BACKOFF_DURATION}s."
    set_backoff
    notify "FAILED" "none" "unknown"
}

main "$@"
