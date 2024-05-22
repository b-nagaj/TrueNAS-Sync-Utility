#!/bin/bash

# Initialize variables for filenames and directories to exclude
exclude_files=()
exclude_directories=()

# Parse command line options
while getopts 'lra:e:' OPTION; do
  case "$OPTION" in
    l)
      echo "syncing local files to TrueNAS..."
      rsync_options=(-lrv)
      src_directory=/home/bryce/Documents/*
      destination_directory=/home/bryce/TrueNAS
      ;;
    r)
      echo "syncing TrueNAS files to local machine..."
      rsync_options=(-lrv)
      src_directory=/home/bryce/TrueNAS/*
      destination_directory=/home/bryce/Documents
      ;;
    e)
      exclude_file="$OPTARG"
      ;;
    ?)
      echo "script usage: ./sync.sh [-l] [-r] [-e exclude_file]"
      exit 1
      ;;
  esac
done

# Shift options
shift "$((OPTIND - 1))"

# Read exclusions from file
if [ -n "$exclude_file" ]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "/"* ]]; then
      exclude_directories+=("$line")
    else
      exclude_files+=("$line")
    fi
  done < "$exclude_file"
fi

# Add exclusions to rsync command
for file in "${exclude_files[@]}"; do
  rsync_options+=("--exclude=$file")
done

for dir in "${exclude_directories[@]}"; do
  rsync_options+=("--exclude=$dir/")
done

# Perform rsync operation
rsync "${rsync_options[@]}" ${src_directory} ${destination_directory}

echo "done!"
