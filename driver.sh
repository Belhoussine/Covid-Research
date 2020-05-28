#!/bin/bash

# After making promute, copy this script into the build directory
# Change the "FILES" variable to the script (or scripts) you would like to execute
# to profile different mutation scripts, you can run this script with the "time" command 

# generate list of mutations
./proMuteBatch 6M0J E:E 493:493 X mutList

# append the correct flags
sed -i 's/$/ em/' mutList

# Customize with your scripts
FILES=("mutList")

# Execute the lines in the script
for FILE in $FILES; do

  # Create a directory to store the output of the mutation script
  mkdir -p "${FILE}_output"

  # Read each mutation into an array
  readarray -t LINES < "$FILE"

  # Routine to execute for every mutation
  for LINE in "${LINES[@]}"; do

    # Make a directory to store outputs
    # Structure is PDBID.Chain.Location.Res2.output
    OUTPUTDIRNAME=$(echo $LINE | awk '{ print $2"."$3"."$4"."$5".output" }')
    echo [INFO] Creating Directory $OUTPUTDIRNAME
    mkdir -p $OUTPUTDIRNAME

    # Directory to look for EM files that were generated
    # Structure is PDBID.Res1LocationRes2
    EMDIRNAME=$(echo $LINE | awk '{ print $2"."$3$4$5 }')

    $LINE

    # Move all output files: PDB, Fasta, and EM data
    mv *.txt $OUTPUTDIRNAME
    mv *.pdb $OUTPUTDIRNAME
    mv external/em/$EMDIRNAME $OUTPUTDIRNAME
    echo [INFO] Moving files to $OUTPUTDIRNAME

  done
  # cleanup output
  rm -rf "${FILE}_output"
  echo [INFO] Cleaning outputs from last run
  echo [INFO] Moving new files to "${FILE}_output"
  mv *.output "${FILE}_output"

done
