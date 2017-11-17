#!/usr/bin/env bash

# ensure pathname correct when runs in a different place
basedir=$(dirname $0)
logdir=/var/www/miq/vmdb/log
logfile=${logdir}/pg_inspector.log
# default postgresql password: smartvm

# show message on screen and also append to log file
rm -f logfile
exec > >(tee -ia ${logfile})
exec 2>&1
echo ""
echo "inspect_pg runs on $(date)"
rm -f ${logdir}/pg_inspector_locks_output_blocked_connections.yml

# Run step 1, 3 and 4 in sequence, assume step 2 has done before.
bundle exec ${basedir}/inspect_pg.rb

# remove first only if all steps success
if [ $? -ne '0' ]; then
  echo "Fails to generate lock output."
  exit 1
fi
rm -f ${logdir}/pg_inspector_output.tar.gz

# collect the output
cd ${logdir}
echo "Boom! Number of locks: $(grep pid pg_inspector_locks.yml | wc -l )"
[[ -s pg_inspector_locks_output_blocked_connections.yml ]] && echo "Boom! Something blocked!"
filename="pg_test_output_$(date +%F-%H%M%S).tar.gz"
tar -czf ${filename} pg_inspector*
echo "Successfully output to ${logdir}/${filename}"
