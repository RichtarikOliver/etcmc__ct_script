
ETCMC Installation Script
==========================

This script automates the installation of ETCMC software on your system, sets up a service for automatic startup after the LXC container boots, and creates all necessary files required for its operation.

### Features:
---------
- Downloads and installs the ETCMC software.
- Sets up a `systemd` service to ensure ETCMC starts automatically after the system boots.
- Creates and configures essential files such as `start.sh`, `stop.sh`, and `update.sh`.
- Ensures seamless operation of the ETCMC node.

### Prerequisites:
--------------
Make sure your system meets the following requirements:
1. Operating System: Linux-based system with `wget`, `bash`, and `python3` installed.
2. Root permissions to execute installation commands.

### Usage Instructions:
-------------------
1. Clone this repository or copy the script URL.
2. Run the following command to download and execute the script:

```sh
wget -O - https://raw.githubusercontent.com/RichtarikOliver/etcmc__ct_script/refs/heads/main/etcmc_ct_script.sh | sh
```

3. The script will:
   - Download the ETCMC software.
   - Configure required files.
   - Set up a `systemd` service for automatic startup.
   - Restart the system to apply changes.

4. **Access the GUI:**
   - After the script finishes, it will display the IP address of the device.
   - You can access the ETCMC GUI by navigating to the following URL in your browser:
   ```
   http://<IP_ADDRESS>:5000
   ```
   - Replace `<IP_ADDRESS>` with the IP address provided by the script.

---

### Disable Login Page on Web GUI  
-------------------------  
To disable the login page on the ETCMC Web GUI, simply run the following command:  

```sh
wget -O - https://raw.githubusercontent.com/RichtarikOliver/etcmc__ct_script/refs/heads/main/login.sh | sh
```

### Cloning Etcmc Node
-----
To fix the clone enode, simply run the following command:
```sh
wget -O - https://raw.githubusercontent.com/RichtarikOliver/etcmc__ct_script/refs/heads/main/clonefix.sh | sh
```
---

ETCMC Nodecheck Telegram Bot Setup
====================================

This part of the script helps you set up the **ETCMC Nodecheck Telegram bot**, which allows you to monitor your node status and manage its operation via Telegram.

### Steps to Set Up:
--------------------
1. Run the following command to download and execute the Nodecheck setup script:

```sh
wget -O - https://raw.githubusercontent.com/RichtarikOliver/etcmc__ct_script/refs/heads/main/nodecheckscript.sh | sh
```

2. The script will:
   - Download necessary files for the **ETCMC Nodecheck** bot.
   - Create the setup script `nodechecksetup.sh`.

3. **Setting Up the Node:**
   - Once the script has completed, you’ll need to go to folder /etcmc/Etcmcnodecheck and you’ll need to run the following command to set up your node with your specific Telegram bot ID:
   
   ```sh
   ./nodechecksetup.sh <Your_Telegram_Bot_ID>
   ```

   - Replace `<Your_Telegram_Bot_ID>` with the ID you received from the Telegram bot.

4. After the setup script completes, the node will be ready and the **ETCMC Nodecheck Telegram bot** will be active.


-----
### Support:
--------
If you encounter any issues or have questions, please open an issue in this repository.

### Disclaimer:
-----------
Use this script at your own risk. Make sure to review the script content before execution.
