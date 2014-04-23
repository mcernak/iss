#!/bin/zsh
#
# Copyright 2014 by Idiap Research Institute, http://www.idiap.ch
#
# See the file COPYING for the licence associated with this software.
#
# Author(s):
#   Mathew Doss,  April 2014
#   Milos Cernak, April 2014
#
this=$0
source $(dirname $0)/config.sh
source $(dirname $0)/grid.sh

autoload create-phone-list.sh

# Create phonelist (no sp, just sil)
echo Writing PhoneList
create-phone-list.sh $trainLabels
awk '{print $1" "NR}' hmm-list.txt > hmm-list-map.txt

model_dir="hybrid"
nphone=`cat hmm-list-map.txt | wc -l`

mkdir -p ${model_dir} hmmdefs
cp hmm-list.txt hmmdefs/
echo "sp" >> hmmdefs/hmm-list.txt

cat hmm-list-map.txt | while read ph lab ; do
    prob=""
    for dset in `seq 1 $nphone` ; do
        if [ $dset -eq $lab ] ; then
            if [ $dset -eq 1 ] ; then
                prob="1.0"
            else
                prob="$prob 1.0"
            fi
        else
            if [ $dset -eq 1 ] ; then
                prob="0.0"
            else
                prob="$prob 0.0"
            fi
         fi
    done

    echo "3 $nphone" > ${model_dir}/${ph}.model
    echo $prob >> ${model_dir}/${ph}.model
    echo $prob >> ${model_dir}/${ph}.model
    echo $prob >> ${model_dir}/${ph}.model
    echo "0.5 0.5 0.0" >> ${model_dir}/${ph}.model
    echo "0.0 0.5 0.5" >> ${model_dir}/${ph}.model
    echo "0.0 0.0 0.5" >> ${model_dir}/${ph}.model
done

echo "$nphone" > hmm-list.txt
cat hmm-list-map.txt | awk '{ print $1}' >> hmm-list.txt
get-htk-hmm.py hmm-list.txt hybrid
rm -f hmm-list.txt

# add 'sp'
hybridHMMdef=hmmdefs/hybrid.hmmdef
echo '~h "sp"' >> $hybridHMMdef
echo "<BEGINHMM>" >> $hybridHMMdef
echo "<NUMSTATES> 3" >> $hybridHMMdef
echo "<STATE> 2" >> $hybridHMMdef
head -16 $hybridHMMdef | tail -n 4 >> $hybridHMMdef
echo "<TRANSP> 3" >> $hybridHMMdef
echo "0.0 1.0 0.0" >> $hybridHMMdef
echo "0.0 0.5 0.5" >> $hybridHMMdef
echo "0.0 0.0 0.0" >> $hybridHMMdef
echo "<ENDHMM>" >> $hybridHMMdef

