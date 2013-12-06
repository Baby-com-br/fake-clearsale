#!/bin/bash
#
# Unicorn handle shell script
#   Ref: https://gist.github.com/3052776
#        https://gist.github.com/421663
#
# Unicorn SIGNALS:
#   http://unicorn.bogomips.org/SIGNALS.html
#
# Controlling Nginx:
#   http://nginx.org/en/docs/control.html
#
# Obs:
# - CMD: use bundle binstubs (bundle install --binstubs) to
#        forget about "bundle exec" stuff, run in demonize mode
#        bin/unicorn is for Rack application (config.ru in root dir), but
#        bin/unicorn_rails is to use with Rails 2.3
#
# - To handle "app_preload true" configuration we should
#   use USR2+QUIT signals, not HUP!  So we rewrite capistrano
#   deployment scripts to manage it.
#
# File:
#   sh/unicorn-init.sh
#
# Marcus Vinicius Fereira            ferreira.mv[ at ].gmail.com
# Pedro Matiello                     matiello[ at ].baby.com.br
# 2013-12
#

#et -e # exit if any error

###
### my env
###
RAILS_ENV=${RAILS_ENV-production}
TIMEOUT=${TIMEOUT-60}

DIR="/eden/app/fake-clearsale"
CMD="bundle exec unicorn -D -c ${DIR}/current/config/unicorn.rb -E $RAILS_ENV"
RVM="/usr/local/rvm/environments/ruby-1.9.3-p194"
PROG="unicorn"
SOCK="/tmp/fake-clearsale.sock"

# Am I inside aws?
[ -e /etc/profile.d/aws.sh ] && source /etc/profile.d/aws.sh

endnow() {
    echo "$1" && exit 1
}

# Source function library.
. /etc/rc.d/init.d/functions

[ -d ${DIR}/current ] && cd ${DIR}/current || endnow "\$DIR: ${DIR}/current does not exist."
# -f $RVM           ] && source $RVM       || endnow "\$RVM: $RVM does not exist."
[ -f $RVM           ] && source $RVM

###
# signaling
###
       PID="${DIR}/tmp/unicorn.pid"
   old_pid="${PID}.oldbin"
worker_pid="${DIR}/tmp/worker.pid"

sig()       {
    test -s "$PID"     && \
    kill -$1 `cat $PID` 2>/dev/null
}
oldsig()    {
    test -s "$old_pid" && \
    kill -$1 `cat $old_pid` 2>/dev/null
}
workersig() {
    test -s "${worker_pid}.${2}" && \
    kill -$1 `cat ${worker_pid}.${2}` 2>/dev/null
}


###
### main
###
case "$1" in
  start)
    sig 0 && echo "$PROG: Already running" && exit 0

    echo -n "Starting Dinda site: "
    $CMD && echo_success || echo_failure
    echo
    ;;

  stop)
    echo -n "Stopping Dinda site: "
    if sig QUIT
    then
        echo_success && echo && exit 0
    else
        echo "$PROG: Already stopped."
        /bin/rm -f $SOCK
    fi
    ;;

  stop-force)
    echo -n "Stopping force Dinda site: "
    if sig TERM
    then
        echo_success && echo && exit 0
    else
        echo "$PROG: Already stopped."
        /bin/rm -f $SOCK
        echo
    fi
    ;;

  stop-worker)
    workersig QUIT $2 && exit 0
    echo >&2 "Worker $2: Already stopped."
    ;;

  restart)
    # stop
    if sig QUIT
    then
        echo -n "Restart: Sleeping... "
        sleep 2
        echo "Done."
    else
        echo "$PROG: Already stopped."
    fi

    # start
    echo -n "Start: "
    $CMD
    echo "Done."
    ;;

  reload)
    sig HUP && echo "$PROG: reloaded OK" && exit 0
    echo "$PROG: Couldn't reload, starting '[$CMD]' instead"

    echo -n "Reload: "
    $CMD && echo_success || echo_failure
    echo
    ;;

  upgrade)
    if sig USR2 && sleep 20 && sig 0 && oldsig QUIT
    then

      ###
      # wait for $old_pid to die
      ###
      n=$TIMEOUT
      while test -s $old_pid && test $n -ge 0
      do
          echo >&2 "Waiting for old master to die... ($n)" && sleep 1 && n=$(( $n - 1 ))
      done ; echo

      ###
      # not dead: leave it
      ###
      if test $n -lt 0 && test -s $old_pid
      then
        echo "$PROG (old) $old_pid still exists after $TIMEOUT seconds"
        exit 1
      fi
      exit 0

    fi

    ###
    # Unicorn was stopped ?
    ###
    echo "$PROG: Could not upgrade, starting '$CMD' instead"
    $CMD && echo_success
    ;;

  status)
    sig 0 && echo "$PROG: is running [`cat $PID`]" && exit 0
    echo "$PROG: Not running"
    ;;

  status-old)
    oldsig 0 && echo "$PROG (old): is running [`cat ${PID}.oldbin`]" && exit 0
    echo "$PROG (old): Not running"
    ;;

  status-worker)
    workersig 0 $2 && echo >&2 "Worker $2: is running [`cat ${worker_pid}.${2}`]" && exit 0
    echo >&2 "Worker $2: Not running"
    ;;

  rotate|reopen-logs)
    sig USR1 && echo rotated logs OK && exit 0
    echo >&2 "Couldn't rotate logs"  && exit 1
    ;;

  *)
    cat >&2 <<USAGE

  Usage: $0
           <start|stop|stop-force|stop-worker>
           <restart|reload|upgrade>
           <status|status-old|status-worker>
           <rotate|reopen-logs>

    start:         run \$CMD
    stop:          send QUIT: graceful shutdown.
    stop-force:    send TERM: fast shutdown.
    stop-worker:   send QUIT to a worker: graceful shutdown.
    restart:       stop + start
    reload:        send HUP. Fallback to \$CMD if error.
    upgrade:       use USR2 + QUIT to replace $PROG. Start \$CMD if is out.
    status:        check PID on $PROG
    status-old:    check PID on $PROG (old)
    status-worker: check PID on worker
    rotate:        send USR1, to reopen logs.
    reopen-logs:   send USR1, to reopen logs.

USAGE
    exit 1
    ;;
esac

# vim:ft=sh
