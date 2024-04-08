# Rec0n.sh

Rec0n.sh is a reconnaissance automation tool that simplifies the process of gathering information about a target domain. It utilizes various tools to harvest subdomains, probe for alive domains, check for potential subdomain takeovers, scan for open ports, and scrape wayback data.

## Dependencies

Before running Rec0n.sh, ensure you have the following dependencies installed:

- assetfinder
- amass
- httprobe
- subjack
- wayback
- EyeWitness

### Installing Dependencies

You can install the required dependencies by running the following commands:

 sudo apt-get update
sudo apt-get install assetfinder amass httprobe subjack
go get github.com/haccer/subjack
go get github.com/tomnomnom/waybackurls
git clone https://github.com/FortyNorthSecurity/EyeWitness.git ```

(If that does not work, please visit the GitHub repositories directly for installation as the installation process may have changed.)

assetfinder - https://github.com/tomnomnom/assetfinder
amass - https://github.com/owasp-amass/amass
httprobe - https://github.com/tomnomnom/httprobe
subjack - https://github.com/haccer/subjack
wayback - https://github.com/wabarc/wayback
eyewitness (Optional) - https://github.com/RedSiege/EyeWitness


## Usage

To use Rec0n.sh, follow the syntax below:



./rec0n.sh <target_domain>

For example:



./rec0n.sh example.com

Optional: Installing Missing Dependencies Automatically

When you run Rec0n.sh and it detects missing dependencies, it will prompt you to install them automatically:



The following dependencies are missing: subjack wayback EyeWitness
Do you want to install them now? (yes/no): yes

Optional: Capturing Screenshots Using EyeWitness

Rec0n.sh also gives you the option to capture screenshots using EyeWitness. You can choose to enable this feature during execution:



Do you want to capture screenshots using Eyewitness? (yes/no)

Expected Runtime

Please note that Rec0n.sh usually takes between 10-15 minutes to complete the entire reconnaissance process. However, the runtime may vary depending on your internet connection speed and other factors. Please be patient while the tool is running.


## Features

    Harvest subdomains with assetfinder
    Probe for alive domains using httprobe
    Check for potential subdomain takeovers with subjack
    Scan for open ports using nmap
    Scrape wayback data with waybackurls
    Compile possible parameters and file extensions from wayback data

Example:


./rec0n.sh example.com

This will create a directory named example.com containing the results of the reconnaissance process.
# Disclaimer

This tool is intended for educational purposes only. The author is not responsible for any misuse or damage caused by this tool.
