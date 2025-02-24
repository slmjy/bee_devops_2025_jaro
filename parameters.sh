#!/bin/bash

# Function to display help
display_help() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -u, --uptime        Display uptime"
  echo "  -d, --distroname    Display distribution name"
  echo "  -v, --kernel-version Display kernel version"
  echo "  -a, --architecture  Display architecture"
  echo "  -m, --memory        Display memory information"
  echo "  -s, --user          Display current user"
  echo "  -r, --folder <path> Specify folder for file creation"
  echo "  -f, --file <name>   Specify file name (created inside folder from -r)"
  echo "  -l, --links <path>  Specify directory for links"
  echo "  -n, --netInfo       Display network information"
  echo "  -t, --netTest       Perform network test"
  echo "  -h, --help          Display this help message"
  exit 0
}

# Check for NO parameters before looping
if [[ $# -eq 0 ]]; then
  display_help
fi

echo "System information for host: $(hostname):"
echo "-------------------------------------------"

# Initialize variables
folder=""
filename=""
links_dir=""


net_info() {
  INTERFACE=$(ip route | awk '/default/ {print $5}')
  IPV4_ADDR=$(ip -o -4 addr show "$INTERFACE" | awk '{print $4}' | cut -d/ -f1)
  IPV6_ADDR=$(ip -o -6 addr show "$INTERFACE" scope global | awk '{print $4}' | cut -d/ -f1 | head -n1)
  MAC_ADDR=$(cat /sys/class/net/"$INTERFACE"/address)

  echo "Network Interface: $INTERFACE"
  echo "IPv4 Address: $IPV4_ADDR"
  echo "IPv6 Address: $IPV6_ADDR"
  echo "MAC Address: $MAC_ADDR"
}

net_test() {
  TARGET="google.cz" 
  echo "Pinging $TARGET..."

  if ping -c 1 "$TARGET" &>/dev/null; then
    echo "Network test successful: $TARGET is reachable."
  else
    echo "Network test failed: $TARGET is unreachable."
  fi
}


while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--uptime) echo "Uptime: $(uptime)"; shift;;
    -d|--distroname) DISTRONAME=$(lsb_release -d | awk -F: '{print $2}' | tr -d '[:space:]'); echo "Distribution: $DISTRONAME"; shift;;
    -v|--kernel-version) echo "Kernel version: $(uname -r)"; shift;;
    -a|--architecture) echo "Architecture: $(uname -m)"; shift;;
    -m|--memory) TOTALMEM=$(free -m | awk '/Mem:/ {print $2}'); FREEMEM=$(free -m | awk '/Mem:/ {print $4}'); echo "Total memory: ${TOTALMEM}MB"; echo "Free memory: ${FREEMEM}MB"; shift;;
    -s|--user) echo "Current user: $(whoami)"; shift;;
    -n|--netInfo) net_info; shift;;
    -t|--netTest) net_test; shift;;
    -r|--folder) 
      if [[ -z "$2" ]]; then
        echo "Error: Option $1 requires an argument."
        exit 1
      fi
      folder="$2"; shift 2;;
    -f|--file)
      if [[ -z "$2" ]]; then
        echo "Error: Option $1 requires an argument."
        exit 1
      fi
      file="$2"; shift 2;;
    -l|--links)
      if [[ -z "$2" ]]; then
        echo "Error: Option $1 requires an argument."
        exit 1
      fi
      links_dir="$2"; shift 2;;
    -h|--help) display_help;;  
    *) echo "Invalid option: $1"; exit 1;;
  esac
done


# Aall three parameters (-r, -f, -l) must be provided together
if [[ -n "$folder" || -n "$filename" || -n "$links_dir" ]]; then
  if [[ -z "$folder" || -z "$filename" || -z "$links_dir" ]]; then
    echo "Error: The -r/--folder, -f/--file, and -l/--links options must be used together."
    exit 1
  fi

  # Ensure the folder and links directory exist
  mkdir -p "$folder" || { echo "Error: Could not create directory '$folder'"; exit 1; }
  mkdir -p "$links_dir" || { echo "Error: Could not create links directory '$links_dir'"; exit 1; }

  # Construct full file path
  file_path="$folder/$filename"

  # Create the file and write to it
  echo "Ahoj" > "$file_path" || { echo "Error: File '$file_path' is not writable."; exit 1; }

  file_path=$(readlink -f "$file_path")
  links_dir=$(readlink -f "$links_dir")

  # Create symbolic and hard links
  rm -f "$links_dir/softlink" "$links_dir/hardlink"
  ln -sf "$file_path" "$links_dir/softlink" || { echo "Error: Could not create symbolic link."; exit 1; }
  ln -f "$file_path" "$links_dir/hardlink" || { echo "Error: Could not create hard link."; exit 1; }

  echo "File and links created successfully!"
fi

exit 0
