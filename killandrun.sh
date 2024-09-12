#!/bin/bash

# please make sure the shell is put in the SCRIPT_DIR 

PORT_NUMBER=453
#the directory where the script is located
SCRIPT_DIR="/root/webFAAAST${PORT_NUMBER}"
CONFIG_FILE="${SCRIPT_DIR}/data/config.json"
STARTER_JAR="${SCRIPT_DIR}/starter-1.0.1.jar"
output_file="${SCRIPT_DIR}/faaast${PORT_NUMBER}Output.log"

CHECK_FORMAT=true

DPP_DIR="${SCRIPT_DIR}"
DPP_KEYWORD="products"
# Function to check if port ${PORT_NUMBER} is in use
check_port() {
    lsof -i :${PORT_NUMBER} -t
}

find_dpp() {

    # Check if the directory exists
    if [[ ! -d "$DPP_DIR" ]]; then
        echo "Directory '$DPP_DIR' does not exist."
        return 1
    fi

    # Find the first JSON file with the keyword in its name
    local result=$(find "$DPP_DIR" -type f -name "*$DPP_KEYWORD*.json" | head -n 1)

    # Check if any file was found
    if [[ -z "$result" ]]; then
        echo "No JSON file with keyword '$DPP_KEYWORD' found in directory '$DPP_DIR'."
        return 1
    fi

    # Return the filename
    echo "$result"
}

set_validation() {
    if [[ "$CHECK_FORMAT" == true ]]; then
        echo ""
    elif [[ "$CHECK_FORMAT" == false ]]; then
        echo "--no-validation"
    else
        echo "Invalid input: CHECK_FORMAT should be 'true' or 'false'."
        return 1
    fi
}

# Function to run the Java command
run_java_faaast() {
    nohup java -jar ${STARTER_JAR} --model $(find_dpp) $(set_validation) --config ${CONFIG_FILE} > $output_file 2>&1 &
}

echo "port number: ${PORT_NUMBER}"
echo "found DPP file: $(find_dpp)"
echo "validation: $(set_validation)"


# Print some empty lines for better readability
echo
echo
echo
echo
echo


# Detect the process using port 473 using the function
PID=$(check_port)

# Remove the old output file if it exists
if [ -f "$output_file" ]; then
    rm "$output_file"
    echo "Remove old outputLog"
fi


# Check if a process was found
if [ -z "$PID" ]; then
    echo "No process is using port ${PORT_NUMBER}."
else
    echo "Process using port ${PORT_NUMBER}: $PID"
    
    # Kill the process
    kill -9 $PID
    echo "Process $PID has been killed."
fi

sleep 3

# Print some empty lines for better readability
echo
echo
echo
echo
echo

# Run the Java command
echo "Running Java command..."
run_java_faaast

sleep 10

if [ -z "$PID" ]; then
    echo "No process using port ${PORT_NUMBER} after 10 seconds. Checking again in 10 seconds..."
    sleep 10
    PID=$(check_port)
    
    if [ -z "$PID" ]; then
        echo "No process using port ${PORT_NUMBER} after 20 seconds. Checking again in 10 seconds..."
        sleep 10
        PID=$(check_port)
        
        if [ -z "$PID" ]; then
            echo "The Java command failed. No process is using port ${PORT_NUMBER} after 30 seconds. Try again..."
        else
            echo "Process using port ${PORT_NUMBER}: $PID"
            echo "OK restart now"
        fi
    else
        echo "Process using port ${PORT_NUMBER}: $PID"
        echo "OK restart now"
    fi
else
    echo "Process using port ${PORT_NUMBER}: $PID"
    echo "OK restart now"
fi

echo "Sleeping for 20 seconds to allow Java process to write output..."
sleep 20


# Print the content of the output file
if [ -f "$output_file" ]; then
    echo "Content of $output_file:"
    cat "$output_file"
else
    echo "$output_file file does not exist."
fi

echo "You can use the following commands to manage the firewall and check the port status:"
echo "sudo ufw enable"
echo "sudo lsof -i :${PORT_NUMBER}"
echo "sudo ufw status"
echo "sudo ufw allow ${PORT_NUMBER}"
