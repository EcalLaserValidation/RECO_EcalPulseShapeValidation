#!/bin/bash -ex
#Jenkins script for TPGAnalysis and ECAL conditions' validation

echo "Running automated fast track validation script. Will compare ECAL trigger primitives rate difference for two different sets of conditions "
echo "reference and test sqlite files"
echo "usage: ./tpganalysis_jenkins_2021.sh $sqlite1 $sqlite2 $week $year $(getconf _NPROCESSORS_ONLN)"

###############################
dataset=/EGamma/Run2018D-v1/RAW
GT=112X_dataRun2_v9
#GT=106X_dataRun2_v33
#reference=320040
reference=323841
sqlite1=$1
sqlite2=$2
week=$3
year=$4
#nevents=1000
nevents=1000
INSTALL=true
RUN=true
###############################

datasetpath=`echo ${dataset} | tr '/' '_'`


export CMSREL=CMSSW_11_2_0
export RELNAME=PSVal_1120
export SCRAM_ARCH=slc7_amd64_gcc900

if ${INSTALL}; then
scram p -n $RELNAME CMSSW $CMSREL
cd $RELNAME/src
eval `scram runtime -sh`

git cms-init

mkdir Validation
cd Validation
eval `scram unset -sh`; git clone https://:@gitlab.cern.ch:8443/zghiche/EcalPulseShapeValidation.git
#git clone https://:@gitlab.cern.ch:8443/zghiche/EcalPulseShapeValidation.git
export USER_CXXFLAGS="-Wno-delete-non-virtual-dtor -Wno-error=unused-but-set-variable -Wno-error=unused-variable -Wno-error=sign-compare -Wno-error=reorder"
scram b -j $(getconf _NPROCESSORS_ONLN)
else
cd $RELNAME/src
fi
eval `scram runtime -sh`
cd EcalPulseShapeValidation/test
if ${RUN}; then
wget http://cern.ch/ecaldpg/ecal/pulseshapes_db/EcalPulseShape_${sqlite1}.db
wget http://cern.ch/ecaldpg/ecal/pulseshapes_db/EcalPulseShape_${sqlite2}.db


./runEcalPulseShape_jenkins.sh jenkins $reference $dataset $GT $nevents $sqlite1 $(getconf _NPROCESSORS_ONLN) &
wait
./runEcalPulseShape_jenkins.sh jenkins $reference $dataset $GT $nevents $sqlite2 $(getconf _NPROCESSORS_ONLN) &
wait
fi
cp addhist_jenkins_2021.sh log_and_results/${reference}_${datasetpath}_PS_IOV_${sqlite1}_batch/.
pushd log_and_results/${reference}_${datasetpath}_PS_IOV_${sqlite1}_batch/
./addhist_jenkins_2021.sh ${sqlite1} &
popd
cp addhist_jenkins_2021.sh log_and_results/${reference}_${datasetpath}_PS_IOV_${sqlite2}_batch/.
pushd log_and_results/${reference}_${datasetpath}_PS_IOV_${sqlite2}_batch/
./addhist_jenkins_2021.sh ${sqlite2} &
popd
wait

mv log_and_results/${reference}_${datasetpath}_PS_IOV_${sqlite1}_batch/EcalSlimValidationMiniaod_${sqlite1}.root ../macro/.

#wget http://cern.ch/ecaltrg/ReferenceNTuples/TPG/newhistoTPG_${sqlite1}.root  
#mv newhistoTPG_${sqlite1}.root ../../TPGPlotting/plots/.

mv log_and_results/${reference}_${datasetpath}_PS_IOV_${sqlite2}_batch/EcalSlimValidationMiniaod_${sqlite2}.root ../macro/.

cd ../macro/

./validationplots_jenkins_2021.sh $sqlite1 $sqlite2 $reference $week ${datasetpath}

