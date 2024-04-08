#!/bin/bash

echo "     _______________________________"
echo "    /    DIYS3C                      \\"
echo "   |   ___________________________   |"
echo "   |  | REC0N                     |  |"
echo "   |  | 01010100 01101000 0110100 |  |"
echo "   |  | 01110011 0010000 0110000 |  |"
echo "   |  | 01101110 0010000 01100100 |  |"
echo "   |  | 01111000 01100001 0110111 |  |"
echo "   |  | 01110000 01101100 0110010 |  |"
echo "   |  |                           |  |"
echo "   |  | 01000111 01010000 0101010 |  |"
echo "   |  | 0100000 01101001 01110011 |  |"
echo "   |  | 0100000 01100001 01110111 |  |"
echo "   |  | 1100101 01110011 01101111 |  |"
echo "   |  | 1101101 01100101 00101110 |  |"
echo "   |  |                           |  |"
echo "    \\ \\_________________________/  /"
echo "     \\_____________________________/"

# Check and install optional dependencies
dependencies=("assetfinder" "amass" "httprobe" "wayback")
missing_dependencies=()

for dependency in "${dependencies[@]}"; do
    if ! command -v "$dependency" &> /dev/null; then
        missing_dependencies+=("$dependency")
    fi
done

if [ ${#missing_dependencies[@]} -gt 0 ]; then
    echo "The following dependencies are missing: ${missing_dependencies[*]}"
    read -p "Do you want to install them now? (yes/no): " install_dependencies
    if [[ "$install_dependencies" == "yes" ]]; then
        sudo apt-get update
        sudo apt-get install ${missing_dependencies[*]}
        go install github.com/haccer/subjack@latest
        go install github.com/tomnomnom/waybackurls@latest
    else
        echo "Please install the missing dependencies before running the script."
        exit 1
    fi
fi

url=$1
if [ -z "$url" ]; then
    echo "Usage: rec0n <target_domain>"
    exit 1
fi

echo "Do you want to capture screenshots using Eyewitness? (yes/no)"
read capture_screenshots

if [[ "$capture_screenshots" == "yes" ]]; then
    echo "[+] Running eyewitness against all compiled domains..."
    python3 EyeWitness/EyeWitness.py --web -f $url/recon/httprobe/alive.txt -d $url/recon/eyewitness --resolve
fi

# Create directories
if [ ! -d "$url" ]; then
    mkdir $url
fi
if [ ! -d "$url/recon" ]; then
    mkdir $url/recon
fi
if [ ! -d "$url/recon/scans" ]; then
    mkdir $url/recon/scans
fi
if [ ! -d "$url/recon/httprobe" ]; then
    mkdir $url/recon/httprobe
fi
if [ ! -d "$url/recon/potential_takeovers" ]; then
    mkdir $url/recon/potential_takeovers
fi
if [ ! -d "$url/recon/wayback" ]; then
    mkdir $url/recon/wayback
fi
if [ ! -d "$url/recon/wayback/params" ]; then
    mkdir $url/recon/wayback/params
fi
if [ ! -d "$url/recon/wayback/extensions" ]; then
    mkdir $url/recon/wayback/extensions
fi
if [ ! -f "$url/recon/httprobe/alive.txt" ]; then
    touch $url/recon/httprobe/alive.txt
fi
if [ ! -f "$url/recon/final.txt" ]; then
    touch $url/recon/final.txt
fi

# Harvesting subdomains with assetfinder
echo "[+] Harvesting subdomains with assetfinder..."
assetfinder $url >> $url/recon/assets.txt
cat $url/recon/assets.txt | grep $1 >> $url/recon/final.txt
rm $url/recon/assets.txt

# Probing for alive domains
echo "[+] Probing for alive domains..."
cat $url/recon/final.txt | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' >> $url/recon/httprobe/a.txt
sort -u $url/recon/httprobe/a.txt > $url/recon/httprobe/alive.txt
rm $url/recon/httprobe/a.txt

# Checking for possible subdomain takeover
echo "[+] Checking for possible subdomain takeover..."
if [ ! -f "$url/recon/potential_takeovers/potential_takeovers.txt" ]; then
    touch $url/recon/potential_takeovers/potential_takeovers.txt
fi
subjack -w $url/recon/final.txt -t 100 -timeout 30 -ssl -c ~/go/src/github.com/haccer/subjack/fingerprints.json -v 3 -o $url/recon/potential_takeovers/potential_takeovers.txt

# Scanning for open ports
echo "[+] Scanning for open ports..."
nmap -iL $url/recon/httprobe/alive.txt -T4 -oA $url/recon/scans/scanned.txt

# Scraping wayback data
echo "[+] Scraping wayback data..."
cat $url/recon/final.txt | waybackurls >> $url/recon/wayback/wayback_output.txt
sort -u $url/recon/wayback/wayback_output.txt > $url/recon/wayback/wayback_sorted.txt

# Pulling and compiling all possible params found in wayback data
echo "[+] Pulling and compiling all possible params found in wayback data..."
cat $url/recon/wayback/wayback_sorted.txt | grep '?*=' | cut -d '=' -f 1 | sort -u >> $url/recon/wayback/params/wayback_params.txt
for line in $(cat $url/recon/wayback/params/wayback_params.txt); do
    echo $line'=';
done

# Pulling and compiling js/php/aspx/jsp/json files from wayback output
echo "[+] Pulling and compiling js/php/aspx/jsp/json files from wayback output..."
for line in $(cat $url/recon/wayback/wayback_sorted.txt); do
    ext="${line##*.}"
    case "$ext" in
        js)
            echo $line >> $url/recon/wayback/extensions/js1.txt
            ;;
        html)
            echo $line >> $url/recon/wayback/extensions/jsp1.txt
            ;;
        json)
            echo $line >> $url/recon/wayback/extensions/json1.txt
            ;;
        php)
            echo $line >> $url/recon/wayback/extensions/php1.txt
            ;;
        aspx)
            echo $line >> $url/recon/wayback/extensions/aspx1.txt
            ;;
    esac
done

# Remove temporary files
rm $url/recon/wayback/extensions/js1.txt
rm $url/recon/wayback/extensions/jsp1.txt
rm $url/recon/wayback/extensions/json1.txt
rm $url/recon/wayback/extensions/php1.txt
rm $url/recon/wayback/extensions/aspx1.txt

echo "Rec0n completed!"
