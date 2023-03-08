#!/bin/bash
#
# BUILDS A SINGLE .SQL FILE
# by 3n3a
#

SRC_FOLDER="./src"
OUTPUT_FILE="./install.sql"

# the source files, in order of dependency
FILES=("plpgsql-json-to-html.sql" "python3u-json-to-html.sql" "table-to-html.sql" "table-to-html-pg.sql" "html-caching.sql")

DATE=$(date -R)
echo -e "---\n--- GENERATED BY SQL-BUILDER\n--- PLEASE DO NOT EDIT DIRECTLY\n--- CREATED AT $DATE\n---\n\n" > $OUTPUT_FILE

for file in ${FILES[@]}
do
    echo -e "\n\n---\n--- FROM: $file ---\n---\n" >> $OUTPUT_FILE
    cat "$SRC_FOLDER/$file" >> $OUTPUT_FILE
    echo "Added $file"
done

echo "Finished creating $OUTPUT_FILE!!"