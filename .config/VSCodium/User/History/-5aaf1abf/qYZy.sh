### capitalization is important. Space separated.
### Null is a month 0 space filler and has to be there for ease of use later.
MONTHS=(Null Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

cd /your/ftp/dir                  ### pretty obvious I think
for file in *.jpg                 ### we are going to loop for .wav files
do                                ### start of your loop
    ### your file format is YYYY-MM-DD-HH-MM-SS-xxxxxxxxxx.wav so
    ### get the year and month out of filename
    year=$(echo ${file} | cut -d"-" -f1)
    month=$(echo ${file} | cut -d"-" -f2)
    ### create the variable for store directory name
    STOREDIR=${year}_${MONTHS[${month}]}

    if [ -d ${STOREDIR} ]         ### if the directory exists
    then
        echo mv ${file} ${STOREDIR}    ### move the file
    elif                          ### the directory doesn't exist
        echo mkdir -p ${STOREDIR}         ### create it
        echo mv ${file} ${STOREDIR}    ### then move the file
    fi                            ### close if statement
done