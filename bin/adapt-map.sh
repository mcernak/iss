#!/bin/zsh
#
# Copyright 2012 by Idiap Research Institute, http://www.idiap.ch
#
# See the file COPYING for the licence associated with this software.
#
# Author(s):
#
# György Szaszák, November 2012
#
this=$0
source $(dirname $0)/config.sh

autoload deal create-file-list.sh

nIter=1	#Default
[[ $1 != "" ]] && nIter=$1
if [[ ! "$nIter" = <-> ]]
then
    echo "Usage: adapt-map.sh [Number of HERest cycles]"
    exit 1
fi

# needs hmmMapDir, mapTau

opts=(
  $htsOptions
  -B
  -C $hmmMapDir/map.cnf
  -t $prune
  -I $adaptMLF
  -H $tiedModelDir/mmf-$mixOrder.bin
  -M $hmmMapDir
  -s $tiedModelDir/stats.txt
  -u pmvw
)

# add additional dependency directory (for parent xforms)
if [[ $depTransDir != "" ]] ; then
  opts+=(
    -J $depTransDir
  )
fi

# use SAT for MAP input
if [[ $satTransDir != "" ]] && [[ ! $inputTransDir != "" ]] ; then
  opts+=(
    -J $satTransDir $satTransExt
    -E $satTransDir $satTransExt
    -a
  )
fi

# use an input transform for MAP input
if [[ $inputTransDir != "" ]] && [[ ! $satTransDir != "" ]] ; then
  opts+=(
    -J $inputTransDir $inputTransExt
    -a
  )
fi

# use SAT + input transform for MAP input
if [[ $inputTransDir != "" ]] && [[ $satTransDir != "" ]] ; then
  opts+=(
    -J $inputTransDir $inputTransExt
    -J $satTransDir
    -E $satTransDir $satTransExt
    -a
  )
fi

opts+=(
  -h $decodePattern
)

function Split
{
  mkdir -p $hmmMapDir
  
  cat $htsConfig >  $hmmMapDir/map.cnf
  echo "MAPTAU = $mapTau" >>  $hmmMapDir/map.cnf

  [[ ! -e $adaptList ]] && create-file-list.sh $adaptList
    
    mkdir -p deal
    #[[ ! -e deal/$adaptList.01 ]] && \
	deal $adaptList deal/$adaptList.{01..$nJobs}
}

function Array
{
    # Run the extraction
    echo Running MAP adaptation

    $herest -p $gridTask -S deal/${adaptList}.$grid0Task $opts $hmmMapDir/hmm-list.txt
    #echo "$herest | $htsOptions | -p $gridTask | $opts | $hmmMapDir/hmm-list.txt"
}

function Merge
{
    #echo "$herest -p 0 | $opts | $hmmMapDir/hmm-list.txt | $hmmMapDir/HER{1..$nJobs}.hmm.acc"
    $herest -p 0 $opts $hmmMapDir/hmm-list.txt $hmmMapDir/HER{1..$nJobs}.hmm.acc
    rm $hmmMapDir/HER{1..$nJobs}.hmm.acc
}
     
# Grid
array=( $nJobs $nIter )
source $(dirname $0)/grid.sh
