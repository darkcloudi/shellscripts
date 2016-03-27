#! /bin/sh -p

#dependency scripts that need to exist under the same directory (It will allow you to access the shared functions that do not exist as part of this script)
. setEnv.sh
. deployComponents.sh

#NOT TESTED

readonly USER=`whoami`
readonly USER_HOME=`echo ~`
readonly DATE=`date +%Y%m%d`
readonly SCRIPT_NAME=`basename $0`
readonly NEXUS_URL='http://sam.com:8080/nexus/content/reposotories'
readonly NEXUS_LATEST='LATEST' 
readonly NEXUS_RELEASE='RELEASE'
readonly DATA_DIR='/home/'$USER'/nexus'
readonly M2_DIR='/home/'$USER’/.m2/repository/groupID’
readonly DEPLOY_FILES_SCRIPT=‘deployPuppetFiles.sh’
readonly PUPPET_MODULES_DIR='/home/'$USER’/.puppet/modules’
 
readonly FILE1=’groupdID:artifactID1’
readonly FILE2=’groupdID:artifactID2’
readonly FILE3=’groupdID:artifactID3’
 
# MY SERVERS
readonly SERVER1=‘server1.sam.com’
readonly SERVER2=‘server2.sam.com’
readonly SERVER3=‘server3.sam.com’
readonly SERVER4=i’server4.sam.com’
readonly TESTSERVER1=‘testserver1.sam.com’


#If you don't want to deploy certain artifact just copy the variable name between dotted lines in comment section below 

readonly files=($FILE1 $FILE2 FILE3)


function validateDirectories { 
if [[ ! -d $(DATA_DIR) 11 then echo "${DATA_DIR) does not exist, creating.. • ." mkdir -P $(DATA_DIR) 
fi 

function cleanupFiles { 
  if [[ -d $(DATA_DIR1 ]]; then 
      rm -f $(DATA_DIR}/* 
      echo "Old .tar.gz files now removed" 
     # Cleanup m2 to make sure files come 
     rm -rf $M2_DIR 
  fi 
} 

function getFilesFromNexus {

echo 1. GET RELEASE 
echo 2. GET LATEST 

read CHOICE 
case $CHOICE in 
    1) VERSION=SNEXUS_RELEASE;; 
    2) VERSION=$NEXUS_LATEST;; 
    *) echo "Bad Choice\a";; 
esac

echo $VERSION “will be used”
echo “Gettlng Files From Nexus Repo" 

for file in “${files[@]}” 
do 
echo "Processing $file" 
mvn org.apache.maven.plugins:maven-dependency-plugin:2.8:get -Ddest=$DATA_DIR -Dtransitive=false -DremoteRepositories=$NEXUS_URL - Dartifact="$file:$VERSION:tar.gz:puppet" 

if [[ $STATUS -eq 0 ]];
then 
   echo "Downloaded $file successful" 
else 
  echo "$file download failed" 
  exit 1; 
fi 
done
 
echo "Downloaded following files from Nexus" 
puppet_files=`ls -trh $DATA_DIR` 
for file in ${puppet_files} 
do 
  echo ${file} 
done 


echo "Copying deploy script: $DEPLOY_FILES_SCRTPT to $DATA_DIR" 
cp $DEPLOY_FILES_SCRIPT $DATA_DIR 

# chmod files so they can be accessed by procuser when copied to REF/OPS 
chmod uog+rwx -R $DATA_DIR 

}

function moveFilesToPuppetDir { 
if [ 1 -eq 0 ); then 
  echo "Moved Files From $DATA_DIR to $PUPPET_DIR successful" 
fi 

function ftpFiles { 
 echo 1. RELEASE TO OPS
 echo 2. RELEASE TO REF
 echo 3. RELEASE TO INT 
 echo 4. DEV 1 
 echo 5. DEV 2 
 echo 6. DEV 3 
 echo 7. LOCAL DEPLOY
 echo 8. CLEAN LOCAL DEPLOY 

CLEAN=“0”

read SERVERCHOICE
case $SERVERCHOICE in
  1) SERVERS=“OPS”;;
  2) SERVERS=“REF”;;
  3) SERVERS=“INT”;;
  4) SERVERS=“DEV1”;;
  5) SERVERS=“DEV2”;;
  6) SERVERS=“DEV”;;
  7) SERVERS=“DEV”
             CLEAN=“1”;;
  *) echo “Bad Choice\a”;;
esac


if [[ $SERVERS == “OPS” ]];
 then
  echo “FTP to Ref Server”
 scp -p -r $DATA_DIR $USER@$SERVER1:/tmp/

elif [[ $SERVERS == “REF” ]];
 then
  echo “FTP to Ref Server”
 scp -p -r $DATA_DIR $USER@$SERVER2:/tmp/
elif [[ $SERVERS == “INT” ]];
 then
  echo “FTP to Ref Server”
 scp -p -r $DATA_DIR $USER@$SERVER3:/tmp/
elif [[ $SERVERS == “DEV1” ]];
 then
  echo “FTP to Ref Server”
 scp -p -r $DATA_DIR $USER@$SERVER4:/tmp/
elif [[ $SERVERS == “DEV2” ]];
 then
  echo “FTP to Ref Server”
 scp -p -r $DATA_DIR $USER@$TESTSERVER1:/tmp/
elif [[ $SERVERS == “DEV” ]];
 #Local Deployment (My Server)
 then
   shutDownmMongo
   shutDownJBoss

   return_dir=`pwd`

   cd $DATA_DIR

   #Unpack the downloaded files
   echo “Unpacking files”
   for f in *.tar.gz; do
     echo $f
     tar -xf $f &
   done
   wait

   if [[ ! -d $PUPPET_MODULES_DIR ]]
   then
     echo “Creating puppet modules root dir: $PUPPET_MODULES_DIR”
     mkdir -p $PUPPET_MODULES_DIR
   fi

   echo “Copying puppet components to: $PUPPET_MODULES_DIR”
   for D in */; do
   echo $D
   if [[ -d $PUPPET_MODULES_DIR/$D ]]
   then
   echo “Removing previous modules: $PUPPET_MODULES_DIR/$D”
   rm -rf $PUPPET_MODULES_DIR/$D
   fi

   echo “Deploying Components”

   if [[ $CLEAN == “1” ]]
   then 
   echo “Cleaning previous project”
     cleanDeployment
   fi

   deployComponents

  else

   echo “Invalid selection”
   exit 1
  fi
 }


############
# MAIN     #
############

echo ${SCRIPT_NAME} is starting at `date +%H:%M:%S`

setEnv 

echo "Started Cleanup of old files" 
validateDirectories 
echo "Ended cleanup" 

echo "Started Cleanup of old files" 
cleanupFiles 
echo "Ended cleanup" 

echo "Started to Request Files" 
getFilesFromNexus 
echo "Request Files Complete" 

#echo "Started to move files to Puppet Directory" 
#moveFilesToPuppetDir 
#echo "Files moved to Puppet Directory" 

echo "FTP File - Started" 
ftpFiles 
echo "FTP Files - Completed" 


echo ${SCRIPT_NAME} is ending at `date +%H:%M:%S`






