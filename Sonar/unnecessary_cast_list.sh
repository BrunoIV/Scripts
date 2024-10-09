#!/bin/bash
#This script fix the "Unnecessary Cast List" error of sonar applicated to DAO layer of a Spring project
#Example: return (List<String>) query.list(); -> return query.list();
#chmod u+x unnecessary_cast_list.sh
#./unnecessary_cast_list.sh <your-app>


#CONFIG
workDir=~/Workspace/${1}/src/main/java/org/acme/dao

if [ -z "$1" ]
then
	echo "Please, specify the application name as a parameter";
	exit
fi


if ! test -d $workDir; then
  echo "Directory does not exist. Please check the script config"
fi

echo "Press ENTER to start"
read r

currentDir=`pwd`
cd $workDir

#Find recursively lines that contains "return (List", "return (List<Whatever>", etc
grep -Ri --include \*.java "return.*(List" > $currentDir/tmp.txt

while read line; do
	filePath=`echo $line | cut -d ":" -f1`
	
	#Gets the code and remove tabs and spaces
	originalCode=`echo $line | cut -d ":" -f2 | xargs`
	
	#Reversing the line of code, the text before first space is what i need
	#return (List<MyAwesomeObjectDb>) result; ---> result;
	fixedCode=`echo $originalCode | rev | cut -d " " -f1 | rev`
	
	#Debug info
	echo "Replacing $originalCode"
	
	#Replace "return (List<MyAwesomeObjectDb>) result;" with "return result;"
	sed -i "s|${originalCode}|return ${fixedCode}|g" $filePath
done <$currentDir/tmp.txt

rm $currentDir/tmp.txt
