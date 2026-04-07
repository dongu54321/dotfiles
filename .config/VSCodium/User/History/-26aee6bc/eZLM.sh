#!/bin/bash
# Requirements:
# • sqlite3 must be installed.
# • gpg (for encryption/decryption)
# • tdl command (for uploading & exporting) installed and configured.
# • jq for JSON parsing.
#
# This script defines two functions:
#   backup_folder <folder>
#   recover_backup <backup_name> <output_directory> <random_file1> [random_file2 ...]
#
# backup_folder:
#   - Creates an archive named foldername-YYYYMMDD using one pipeline (tar | gpg | split).
#   - Encrypts the archive using GPG symmetric AES256.
#   - Splits the encrypted stream into 1700MB pieces.
#   - Renames each split piece to a random 16-character alpha-numeric filename.
#   - Saves the mapping between the original split piece and its random name in an SQLite DB.
#   - Uploads each random file to the chat using tdl.
#   - Exports the chat history (which creates tdl-export.json).
#   - For each file, uses jq to match the random file to a file id in tdl-export.json and saves the file id to the DB.
#
# recover_backup:
#   - Uses the stored mapping to reassemble, decrypt, and extract the backup.
#
# Set the chat id for use with tdl.

chatid=4696726478

# Global variables
SPLIT_SIZE="1700m"                       # Split size for backup pieces
MAPPING_DB="$HOME/scripts/backup_map.db" # SQLite DB file to store mapping

# Initialize (or create) the SQLite database and update mapping table to include file_id.
initialize_db() {
    if [ ! -f "$MAPPING_DB" ]; then
        sqlite3 "$MAPPING_DB" "CREATE TABLE IF NOT EXISTS mapping (
            backup_name TEXT,
            original_piece TEXT,
            random_name TEXT,
            file_id TEXT
        );"
    else
        # Ensure file_id column exists. (SQLite doesn't support ALTER TABLE DROP COLUMN.)
        sqlite3 "$MAPPING_DB" "ALTER TABLE mapping ADD COLUMN file_id TEXT;" 2>/dev/null
    fi
}

# Generate a random filename (16 alphanumeric characters)
random_filename() {
    tr -dc 'A-Za-z0-9' </dev/urandom | head -c 16
}

# Function to backup a folder.
# Usage: backup_folder folder_path
backup_folder() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: backup_folder folder_path"
        return 1
    fi

    local folder="$1"
    if [ ! -d "$folder" ]; then
        echo "Error: Folder '$folder' does not exist."
        return 1
    fi

    # Create backup name using folder basename and current date.
    local folder_basename
    folder_basename=$(basename "$folder")
    local date_str
    date_str=$(date +%Y%m%d)
    local backup_name="${folder_basename}-${date_str}"

    initialize_db

    echo "Creating encrypted backup for folder '$folder' as '$backup_name' using a pipeline (tar | gpg | split)..."
    # Create the encrypted backup and split it into pieces.
    #tar -I 'zstd -7' -cf - -C "$(dirname "$folder")" "$folder_basename" | \
    tar -I 'zstd -7' -cf - --exclude-caches --exclude-backups --exclude='*cache*' --exclude='*Cache*' --exclude='*telegram*' \
        -C "$(dirname "$folder")" "$folder_basename" | gpg -o- -c --batch --passphrase "MoMo6789\!@#" | \
        split -b "$SPLIT_SIZE" - "${backup_name}.tar.zst.gpg."
    if [ $? -ne 0 ]; then
        echo "Backup process failed."
        return 1
    fi

    # Array to store the generated random filenames.
    random_files=()

    # Process each generated split piece: rename it to a random name and record the mapping.
    for original in ${backup_name}.tar.zst.gpg.*; do
        local rand_name
        rand_name=$(random_filename)
        while [ -f "$rand_name" ]; do
            rand_name=$(random_filename)
        done

        mv "$original" "$rand_name"
        echo "Mapping: $backup_name - $(basename "$original") -> $rand_name"
        sqlite3 "$MAPPING_DB" "INSERT INTO mapping (backup_name, original_piece, random_name) VALUES ('$backup_name', '$(basename "$original")', '$rand_name');"
        random_files+=("$rand_name")
    done

    # Upload each random file using tdl.
    echo "Uploading backup pieces to chat id $chatid..."
    for file in "${random_files[@]}"; do
        tdl up -p "$file" -c "$chatid" --rm
    done
    count=${#random_files[@]}
    echo "Uploaded $count backup piece(s)."

    # Export chat history which should create/update tdl-export.json.
    tdl chat export -c "$chatid" --all -T last -i "$count"

    # For each file, find the file id in tdl-export.json and update the database.
    # (Assume that tdl-export.json is in the current directory.)
    for file in "${random_files[@]}"; do
        # Use the file name (or another identifier if needed) in the jq filter.
        # Here we assume that the JSON file contains messages where the .file field
        # matches a value comparable to "$file". Modify "$file" below if you need a different variable.
        jq --arg fname "$file" -r '.messages[] | select(.file == $fname) | "\(.id)"' tdl-export.json | while read id; do
            if [ -n "$id" ]; then
                echo "Exact match found for '$file' -> ID: $id"
                # Update the mapping entry for this file by setting file_id.
                sqlite3 "$MAPPING_DB" "UPDATE mapping SET file_id = '$id' WHERE random_name = '$file' AND backup_name = '$backup_name';"
            else
                echo "Error: No match found for file '$file' in tdl-export.json."
            fi
        done
    done

    echo "Backup complete. Backup name: $backup_name. Mapping and file IDs saved in $MAPPING_DB"
}

# # Function to recover a backup using backup name.
# Usage: recover_backup backup_name output_directory
recover_backup() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: recover_backup backup_name output_directory"
        return 1
    fi

    local backup_name="$1"
    local output_dir="$2"

    initialize_db

    local recover_dir="./tmp_recover_${backup_name}"
    mkdir -p "$recover_dir"

    # Query the database for the file IDs and random names of the split pieces.
    local file_info
    file_info=$(sqlite3 "$MAPPING_DB" "SELECT file_id, random_name, original_piece FROM mapping WHERE backup_name='$backup_name';")

    # Download each split piece using tdl and rename it to its original name.
    echo "Downloading and renaming backup pieces..."
    while IFS='|' read -r file_id random_name original_piece; do
        if [ -n "$file_id" ]; then
            # Download the file to the recover directory.
            tdl dl -u "https://t.me/c/$chatid/$file_id" --template "{{ .FileName }}" -d "$recover_dir"
            mv "$recover_dir/$random_name" "$recover_dir/$original_piece"
        else
            echo "Error: No file ID found for a piece of backup '$backup_name'. Skipping."
        fi
    done <<<"$file_info"

    # Check if any files were downloaded and renamed.
    if [ -z "$(ls -A "$recover_dir")" ]; then
        echo "Error: No files downloaded. Aborting recovery."
        rm -rf "$recover_dir"
        return 1
    fi

    # Concatenate the renamed pieces, decrypt, and extract the backup.
    echo "Concatenating, decrypting, and extracting backup..."
    cat "$recover_dir"/* | gpg --yes --decrypt --batch --passphrase "MoMo6789\!@#" | tar -I zstd -xpf - -C "$output_dir"
    if [ $? -ne 0 ]; then
        echo "Error: Decryption or extraction failed."
        return 1
    fi

    # Cleanup temporary recovery files.
    rm -rf "$recover_dir"
    echo "Recovery complete. Files extracted to '$output_dir'."
}

query_backup() {
    local folder="$1"
    #local date_created=$(date +"%Y-%m-%d-%H-%M-%S")
    #local filename="$(basename "$folder")"

    # echo "Original and Random Filenames:"
    # sqlite3 "$MAPPING_DB" "SELECT file_id, random_name, original_piece FROM mapping WHERE original_piece LIKE '$(basename "$folder")-%.tar.zst.gpg.%'" | while read file_id random_name original_piece; do
    #     echo "Original: $original_piece -> Random: $random_name : ID: $file_id"
    # done
    local file_info
    file_info=$(sqlite3 "$MAPPING_DB" "SELECT file_id, random_name, original_piece FROM mapping WHERE original_piece LIKE '$(basename "$folder")-%.tar.zst.gpg.%';")

    while IFS='|' read -r file_id random_name original_piece; do
        if [ -n "$file_id" ]; then
            # Download the file to the recover directory.
            tdl dl -u "https://t.me/c/$chatid/$file_id" --template "{{ .FileName }}" -d "$recover_dir"
            echo "$original_piece - $random_name - $file_id"
        else
            echo "Error: No file ID found for a piece of backup '$folder'. Skipping."
            echo "Try more specific like sonarr-20250330"
            echo "or Use sqlite browser to browse the database"
        fi
    done <<<"$file_info"
}
            # backup_name TEXT,    original_piece LIKE '$(basename "$folder")-%.tar.zst.gpg.%'
            # original_piece TEXT,
            # random_name TEXT,
            # file_id TEXT
# Example usage:
#   backup_folder /path/to/folder
#   recover_backup backup_name output_directory random_file1 [random_file2 ...]
#
# After backup, the random file pieces are uploaded (and file IDs are saved) using tdl and tdl-export.json.

# End of script

# #list chat
# tdl chat ls
# #https://docs.iyear.me/tdl/guide/upload/
# tdl up -p ./reinstall.list -c '912632625'
# tdl dl -u https://t.me/c/912632625/15886 --template "{{ .FileName }}" -d .

# tdl chat export -c 912632625 --all

# # {"id":912632625,"messages":[{"id":15886,"type":"message","file":"reinstall.list"},{"id":15885,"type":"message","file":"reinstall.list"},{"id":15884,"type":"message","file":"reinstall.list"}]}

# # {"id":91222a2325,"messages":[{"id":121386,"type":"message","file":"reinstall.list"},{"id":1331885,"type":"message","file":"abcxyz.list"},{"id":31331,"type":"message","file":"abcxyz-2025-03-23.list"}]}

# jq '.messages[] | select(.file | contains("abcxyz"))' input.json

# tdl chat export -c 4696726478  --all -T last -i 100

# chatid=4696726478
# count=$(find . -name "*.list" -type f | wc -l)
# #tdl chat export -c 4696726478  --all -T last -i $count
# function upload () {
#     for item in ./*.list; do
#         tdl up -p "$item" -c "$chatid"
#     done
# }
# chatid=4696726478
# for item in ./*.list; do
#     tdl up -p $"$item" -c "$chatid"
#     count++
# done
# tdl chat export -c "$chatid" --all -T last -i "$count"
# jq '.messages[] | select(.file | contains("abcxyz"))' tdl-export.json

# for item in ./*.list; do
#     jq -r '.messages[] | select(.file | contains("$item")) | "\(.id) \(.file)"' tdl-export.json| while read id file; do
#         echo "ID: $id, File: $file"
#         # additional code here
#     done
# done

# #!/bin/bash

# # Loop over each .txt file in the current folder
# for file in *.list; do
#     #echo "Processing text file: $txt"
#     # Use the file name as the search string in input.json for an exact match
#     jq --arg fname "$txt" -r '.messages[] | select(.file == $fname) | "\(.id)"' tdl-export.json | while read id; do
#         echo "Exact match found for '$txt' -> ID: $id"
#         # Additional commands can be added here if needed
#     done
# done
# for file in "${random_files[@]}"; do
#     jq --arg fname "$txt" -r '.messages[] | select(.file == $fname) | "\(.id)"' tdl-export.json | while read id; do
#         echo "Exact match found for '$file' -> ID: $id"
#         SAVE ID FOR FILE TO DATABASE
#     done
# done
