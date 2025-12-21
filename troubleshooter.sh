#!/bin/bash

# TrueNAS SMB Mount Troubleshooter
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

MOUNT_UNIT="mnt-truenas\\x2dtailnet-brents\\x2ddata.mount"
AUTOMOUNT_UNIT="mnt-truenas\\x2dtailnet-brents\\x2ddata.automount"
MOUNT_POINT="/mnt/truenas-tailnet/brents-data"
SMB_SERVER="truenas-scale"
SMB_SHARE="brents-data"
CREDS_FILE="/etc/smb-creds"

echo -e "${BLUE}=== TrueNAS SMB Mount Troubleshooter ===${NC}\n"

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

# 1. Check if units are installed
echo -e "${BLUE}[1] Checking systemd unit files...${NC}"
if [ -f "/etc/systemd/system/$MOUNT_UNIT" ]; then
    print_status 0 "Mount unit file exists"
else
    print_status 1 "Mount unit file NOT found in /etc/systemd/system/"
fi

if [ -f "/etc/systemd/system/$AUTOMOUNT_UNIT" ]; then
    print_status 0 "Automount unit file exists"
else
    print_status 1 "Automount unit file NOT found (this is OK if mounting at boot)"
fi

# 2. Check which units are enabled
echo -e "\n${BLUE}[2] Checking enabled units...${NC}"
MOUNT_ENABLED=$(systemctl is-enabled "$MOUNT_UNIT" 2>/dev/null)
AUTOMOUNT_ENABLED=$(systemctl is-enabled "$AUTOMOUNT_UNIT" 2>/dev/null)

echo "Mount unit: $MOUNT_ENABLED"
echo "Automount unit: $AUTOMOUNT_ENABLED"

# 3. Check unit status
echo -e "\n${BLUE}[3] Checking unit status...${NC}"
echo "--- Mount status ---"
systemctl status "$MOUNT_UNIT" --no-pager | head -n 5

echo -e "\n--- Automount status ---"
systemctl status "$AUTOMOUNT_UNIT" --no-pager 2>&1 | head -n 5

# 4. Check Tailscale
echo -e "\n${BLUE}[4] Checking Tailscale...${NC}"
if systemctl is-active --quiet tailscaled.service; then
    print_status 0 "Tailscaled is running"
    
    # Check if tailscale is actually connected
    if command -v tailscale &> /dev/null; then
        if tailscale status &> /dev/null; then
            print_status 0 "Tailscale is connected"
        else
            print_status 1 "Tailscale is not connected"
        fi
    fi
else
    print_status 1 "Tailscaled is NOT running"
fi

# 5. Check mount point directory
echo -e "\n${BLUE}[5] Checking mount point directory...${NC}"
if [ -d "$MOUNT_POINT" ]; then
    print_status 0 "Mount point directory exists: $MOUNT_POINT"
    ls -ld "$MOUNT_POINT"
else
    print_status 1 "Mount point directory does NOT exist: $MOUNT_POINT"
    echo -e "${YELLOW}   Run: sudo mkdir -p $MOUNT_POINT${NC}"
fi

# 6. Check credentials file
echo -e "\n${BLUE}[6] Checking credentials file...${NC}"
if [ -f "$CREDS_FILE" ]; then
    print_status 0 "Credentials file exists: $CREDS_FILE"
    PERMS=$(stat -c %a "$CREDS_FILE" 2>/dev/null)
    if [ "$PERMS" = "600" ] || [ "$PERMS" = "400" ]; then
        print_status 0 "Permissions are secure: $PERMS"
    else
        print_status 1 "Permissions may be too open: $PERMS (should be 600 or 400)"
        echo -e "${YELLOW}   Run: sudo chmod 600 $CREDS_FILE${NC}"
    fi
else
    print_status 1 "Credentials file NOT found: $CREDS_FILE"
fi

# 7. Check network connectivity to TrueNAS
echo -e "\n${BLUE}[7] Checking network connectivity...${NC}"
if ping -c 1 -W 2 "$SMB_SERVER" &> /dev/null; then
    print_status 0 "Can ping $SMB_SERVER"
    ping -c 1 "$SMB_SERVER" | grep "time="
else
    print_status 1 "Cannot ping $SMB_SERVER"
    echo -e "${YELLOW}   Check Tailscale connection and DNS${NC}"
fi

# 8. Check if already mounted
echo -e "\n${BLUE}[8] Checking current mount status...${NC}"
if mount | grep -q "$MOUNT_POINT"; then
    print_status 0 "Share is currently mounted"
    mount | grep "$MOUNT_POINT"
else
    print_status 1 "Share is NOT currently mounted"
fi

# 9. Check recent logs
echo -e "\n${BLUE}[9] Recent systemd journal entries...${NC}"
echo "--- Mount unit logs (last 10 lines) ---"
journalctl -u "$MOUNT_UNIT" -n 10 --no-pager 2>&1 | tail -n 10

echo -e "\n--- Automount unit logs (last 10 lines) ---"
journalctl -u "$AUTOMOUNT_UNIT" -n 10 --no-pager 2>&1 | tail -n 10

# 10. Suggested actions
echo -e "\n${BLUE}=== Suggested Actions ===${NC}"
echo ""
echo "Common fixes:"
echo "1. Ensure mount point exists:"
echo -e "   ${YELLOW}sudo mkdir -p $MOUNT_POINT${NC}"
echo ""
echo "2. Reload systemd daemon:"
echo -e "   ${YELLOW}sudo systemctl daemon-reload${NC}"
echo ""
echo "3. Restart the mount/automount:"
echo -e "   ${YELLOW}sudo systemctl restart $AUTOMOUNT_UNIT${NC}"
echo -e "   ${YELLOW}# OR${NC}"
echo -e "   ${YELLOW}sudo systemctl restart $MOUNT_UNIT${NC}"
echo ""
echo "4. Try manual mount to test credentials:"
echo -e "   ${YELLOW}sudo mount -t cifs //$SMB_SERVER/$SMB_SHARE $MOUNT_POINT -o credentials=$CREDS_FILE,vers=3.0,uid=1000,gid=1000${NC}"
echo ""
echo "5. Check full journal for more details:"
echo -e "   ${YELLOW}journalctl -u $MOUNT_UNIT -b${NC}"
echo -e "   ${YELLOW}journalctl -u $AUTOMOUNT_UNIT -b${NC}"
echo ""