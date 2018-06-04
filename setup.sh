#!/bin/bash

set -e -u
set -x

cd $HOME/gpdb/gpAux/gpdemo
source $HOME/gpdb.master/greenplum_path.sh
export PGHOST=`hostname`
gpssh-exkeys -h `hostname`
make
source gpdemo-env.sh
