#!/bin/zsh
#
# Copyright 2014 by Idiap Research Institute, http://www.idiap.ch
#
# See the file COPYING for the licence associated with this software.
#
# Author(s):
#   Milos Cernak, April 2014
#
this=$0
source $(dirname $0)/config.sh
source $(dirname $0)/grid.sh

autoload create-mlp-file-list.sh

# Just to make sure feacat does not crash when the output is redirected
exec 3> tty.log

mlpSizeName=$mlpWeightFile:t:r
activationFile=$activationID-$mlpSizeName.pfile

echo "Generating htk features from $activationFile"
if [[ -e $activationFile ]]
then
    create-mlp-file-list.sh $fileList prob-list.txt

    cat prob-list.txt \
        | cut -d' ' -f2  | xargs -n 1 dirname \
        | sort -u | xargs -n 1 mkdir -p

    $feacat -ipf pfile -opf htk -pad 4 -i $activationFile -olist prob-list.txt
    rm -f $activationFile
fi

