#!/bin/sh
#
# dinda-site
#    Boot script for /etc/init.d/
#
# chkconfig:    2345 96 02
# description:  dinda-site  \
#               Boot script for /etc/init.d/
#
# Marcus Vinicius Fereira            ferreira.mv[ at ].gmail.com
# Pedro Matiello                     matiello[ at ].baby.com.br
# 2013-12
#

# Source function library.
. /etc/rc.d/init.d/functions

app_user="baby"
app_cmd="/eden/app/fake-clearsale/sh/unicorn-init.sh"

/bin/su - $app_user -c "${app_cmd} ${1}"
