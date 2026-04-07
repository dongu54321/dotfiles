### capitalization is important. Space separated.
### Null is a month 0 space filler and has to be there for ease of use later.
MONTHS=(Null Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

cd /media/WD_Black_1TB/DATA/NEXTCLOUD/Gau               ### pretty obvious I think
for file in *.jpg                 ### we are going to loop for .wav files
do                                ### start of your loop
    ### your file format is YYYY-MM-DD-HH-MM-SS-xxxxxxxxxx.wav so
    ### get the year and month out of filename
    year=$(echo ${file} | cut -d"-" -f1)
    month=$(echo ${file} | cut -d"-" -f2)
    ### create the variable for store directory name
    STOREDIR=20${year}/${month}
    mkdir -p ${STOREDIR}
    mv "${file}" ${STOREDIR}
done
find . -empty -type d -delete
for file in *.jpg *.mov *.jpeg *.JPG *.mp4 *.PNG *.MOV *.JPEG                 ### we are going to loop for .wav files
do                                ### start of your loop
    ### your file format is YYYY-MM-DD-HH-MM-SS-xxxxxxxxxx.wav so
    ### get the year and month out of filename
    year=$(echo ${file} | cut -d"-" -f1)
    month=$(echo ${file} | cut -d"-" -f2)
    ### create the variable for store directory name
    STOREDIR=20${year}/${month}
    mkdir -p ${STOREDIR}
    mv "${file}" ${STOREDIR}
done