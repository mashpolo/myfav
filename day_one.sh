#!/bin/bash
 
echo "写日记吗？帅哥!"
read ANS
 
ans=`echo $ANS | tr 'A-Z' 'a-z'`
if [ "$ans" != "y" ]
then
   echo "再见，别忘了今天的日记"
   exit 0
fi
# copy template from base
cp -rp ./dayone_base ./dayone_tp
dayone_template="./dayone_tp"
# this file name will trigger vim to create a new file with given template
vim $dayone_template
 
# get daily content
CONTENT=`cat $dayone_template`
 
# save content to dayone2
FINAL_CONTENT="$CONTENT"

echo "$FINAL_CONTENT" | dayone2 new
 
# clean tmp file
rm $dayone_template
