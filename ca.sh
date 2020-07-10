#!/usr/bin/env bash

# reachable by web server
outfile="/var/www/html/sectigo_tmp/status.txt"

# one FQDN per line
fqdns="/opt/our_fqdns.txt"


echo "Report generation started at `date +'%Y-%m-%d %H:%M:%S %Z'`

NOTE: Problem sites are those with \"TERENA SSL High Assurance CA 3\"

Hostname                              Issuer
====================================================" > "${outfile}"
cat "${fqdns}" |
  while read fqdn; do
    printf '%-38s' "${fqdn}"; openssl s_client -connect "$fqdn":443 < /dev/null 2>/dev/null | openssl x509 -noout -issuer 2>&1 | head -n 1 | sed 's/.*=\ //g';
  done | sort -b -k2 -k1 >> "${outfile}"

  echo  "
  
Report generation finished at `date +'%Y-%m-%d %H:%M:%S %Z'`" >> "${outfile}"
