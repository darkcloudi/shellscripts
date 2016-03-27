#! /bin/sh -p

#SCRIPT NOT TESTED

readonly USER_NAME=`whoami` 
readonly PROC_USER='prSAM01' 
readonly DATEr=`date +%Y%m%d%H%M` 

#THIS SCRIPT SHOULD NOT BE RUN ON THE /PUPPET/MODULES DIRECTORY

 
#Check using procuser 
if [ $USER_NAME !-= $PROC_USER ] 
then 
     echo "You are running as: "  $USER_NAME ", please sudo to " $PROC_USER " and and try again" 
     exit 1
fi 

#Unpack the downloaded files 
echo 'Unpacking files' 
  for t in *.tar.gz; do 
    echo $t 
    tar -xf $f &
  done
wait
  
# Move the untared files 
echo 'Moving tar files copied to /puppet modules directory to /tmp/sam_"${DATE}  
mkdir 'sam_'$DATE
mv *.tar.gz 'sam_'$DATE
mv 'sam_'$DATE '/tmp/.' 

echo "Copying puppet components to: /puppet/modules" 

for D in */; do 
  echo $D  
   if [[ -d /puppet/modules/$D ]] 
   then 
     echo "Removing previous module: /puppet/modules/$D" 
     rm -rf /puppet/modules/$D 
   fi 
   cp -r $D /puppet/modules 
   rm -rf $D 
done 


for t in *;  do 
echo "Removing "$t 
rm -rf $t 
done 

echo "Updated...." >> /puppet/update.log 
date >> /puppet/update.log 

# Deploy puppet files? 

