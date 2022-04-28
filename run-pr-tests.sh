#!/bin/bash -ex
file=`ls ToRun`
echo $file
if [ -f ToRun/$file ]
then
echo ToRun/$file
    year=`grep "year" ToRun/$file | awk '{print $2}'`
    week=`grep "week" ToRun/$file | awk '{print $2}'`
    sqlite1=`grep "run1" ToRun/$file | awk '{print $2}'`
    sqlite2=`grep "run2" ToRun/$file | awk '{print $2}'`
    type=`grep "type" ToRun/$file | awk '{print $2}'`



###EcalPulseShapeValidation###
cd ../RECO_EcalPulseShapeValidation
cp ToRun/$file RunFiles/.
rm ToRun/$file
git commit -a -m "clean ToRun files"
git remote set-url origin ssh://git@github.com/EcalLaserValidation/RECO_EcalPulseShapeValidation.git
echo "./pulseshapevalidation_jenkins_2021.sh $sqlite1 $sqlite2 $week $year"
./pulseshapevalidation_jenkins_2021.sh $sqlite1 $sqlite2 $week $year 
else
echo "No new files"
fi
git push

