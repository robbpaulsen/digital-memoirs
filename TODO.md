# TODO - Digital Memoirs

## Priority Issues

### 1. Fix Raspberry Pi Access Point Connection Stability

**Status:** DONE

---

### 2. Fix Duplicate Browser Tab Opening on Startup

**Status:** Done
**Description:** When the Flask application starts, it automatically opens the default browser to the `/qr` endpoint. However, it consistently opens **two tabs** instead of one.

**Current Behavior:**

- Expected: Opens 1 tab to `/qr` endpoint
- Actual: Opens 2 tabs to `/qr` endpoint

**Location:** `app.py` - likely in the `open_browser()` function or threading logic

**Investigation Needed:**

- Check if `webbrowser.open()` is being called multiple times
- Verify threading implementation for browser auto-launch
- Review any duplicate signal handlers or initialization code

---

### 3. Change Static IP to New Subnet (10.0.17.0/24)

**Status:** Done
**Description:** Migrate the Raspberry Pi access point from the current subnet `192.168.10.0/24` to a new subnet `10.0.17.0/24`.

**Configuration Details:**

- **Access Point IP (Gateway):** `10.0.17.1`
- **Subnet Mask:** `255.255.255.0` (CIDR: `/24`)
- **DHCP Range:** `10.0.17.2 - 10.0.17.254` (suggested)
- **Reserved:** `10.0.17.1` (must not be assigned to clients to avoid conflicts)

**Files to Update:**

- Hotspot configuration scripts (dnsmasq.conf, hostapd settings)
- Flask app QR code generation logic (if hardcoded IP)
- Documentation and README references

**Rationale:**

- Avoid conflicts with common router subnets (192.168.x.x)
- Use less common subnet range for dedicated event network

---

## Notes

- All tasks should be tested on Raspberry Pi hardware before being marked complete
- Document any configuration changes in CLAUDE.md
- Update README.md with new network configuration details when task #3 is complete
- Consider creating a troubleshooting guide based on findings from task #1
