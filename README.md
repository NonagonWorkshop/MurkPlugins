# Murk Mod Plugins & Mush Installer

Welcome, we are the team behind **Murk Mod Plugins** and the modified version of **Mush**.  
This installer sets up the MurkMod plugin environment and installs our enhanced Mush system.

> [!WARNING]
> **This will replace your current Mush installation** with the Nonagon-modified version.  
> Back up any important data before continuing.

---

## Fixes

### Fix for "Can't Install Mushm" (Read-Only File System)

If you're seeing a "Read-Only" (RO) file system error when trying to install **Mushm** or any other package on Chrome OS, follow the steps below to fix it.

#### Step 1: Remount Root as Read-Write

1. Open **V2 Shell**.
2. Log in as root.
3. Run the following command to remount the root file system with read-write access:

   ```bash
   sudo mount -o remount,rw /
   ```
3.1 If no reply, reboot and proceed to installation
3.2 If it replies with RO(Read Only) file system Procead to step 4

4. Run the following command to fix the RO error:

```bash
# replace /dev/sd5 with the directory from step 3
sudo e2fsck -f /dev/sd5
```

5. Reboot


---

## Installation

Run the following command as **root** to install the modified Mush

```bash
bash <(curl -fsSL https://bit.ly/Mushm2)
