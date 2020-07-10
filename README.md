# digicert2sectigo

Ansible playbook to help with requesting new certificates after the Digicert mass revocation of July 2020.
It will iterate over a list of Digicert order numbers and:

* Fetch the corresponding data (CSR, requester email address(es), common name,
  Subject alt names) from the Digicert API
* Using that data, request a new certificate from the Sectigo API

# Requirements

Quick setup on a Debian based system:

```
sudo apt-get -yy install git python3-venv
git clone https://github.com/GEANT/digicert2sectigo.git
cd digicert2sectigo
python3 -m venv venv
source venv/bin/activate
pip install wheel
pip install ansible
```


# Configuration

* Edit the file `digicert_orders.txt` so that it has one order number per line
* Edit the file `config.yml` and change the various parameters. This involves
  getting API keys and is some work. See
https://wiki.surfnet.nl/display/SCERTS/REST+API (todo: english). Leave the
`sectigo_cert_profile_id` - this will come in the next step.
* Run the playbook once using the `profile` tag, to get a list of certificate
  profiles that are available to you:

```
(venv) dnmvisser@NUC8i5BEK digicert2sectigo$ ansible-playbook playbook.yml -t profile
[WARNING]: No inventory was parsed, only implicit localhost is available

PLAY [localhost] *****************************************************************************************************************************

TASK [Fetch certificate profiles from Sectigo API] *******************************************************************************************
ok: [localhost]

TASK [debug] *********************************************************************************************************************************
ok: [localhost] => 
  profiles.json:
  - id: 8555
    name: GÉANT OV Multi-Domain (customized for GÉANT Vereniging)
    terms:
    - 365
    - 730
  - id: 8557
    name: GÉANT EV Multi-Domain (customized for GÉANT Vereniging)
    terms:
    - 365
    - 730
  - id: 8559
    name: GÉANT IGTF Multi Domain (customized for GÉANT Vereniging)
    terms:
    - 365
    - 395
  - id: 8562
    name: GÉANT Wildcard SSL (customized for GÉANT Vereniging)
    terms:
    - 365
    - 730
  - id: 8575
    name: GÉANT OV Multi-Domain
    terms:
    - 365
    - 730
  - id: 8578
    name: GÉANT EV Multi-Domain
    terms:
    - 365
    - 730
  - id: 8582
    name: GÉANT IGTF Multi Domain
    terms:
    - 365
    - 395
  - id: 8586
    name: GÉANT Wildcard SSL
    terms:
    - 365
    - 730
  - id: 8589
    name: EV Anchor Certificate
    terms:
    - 395
```
* Pick a suitable profile id and populate `sectigo_cert_profile_id` and
`sectigo_cert_term` in the `config.yml` file.
* Review all the other options.
* Run the playbook without any tags:

```
(venv) dnmvisser@NUC8i5BEK digicert2sectigo$ ansible-playbook playbook.yml
[WARNING]: No inventory was parsed, only implicit localhost is available

PLAY [localhost] ***********************************************************************************************************************

TASK [Process certificate orders] ******************************************************************************************************
included: /Users/dnmvisser/git/github.com/GEANT/digicert2sectigo/_cert.yml for localhost

TASK [Fetch data for certificate order 21399578 from Digicert API] *********************************************************************
ok: [localhost]

TASK [Request new certificate through Sectigo API (common name: web.domain.org)] ***************************************************
ok: [localhost]

PLAY RECAP *****************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

If you look into the Certmanager, the new request should be visible (and already
be auto approved - depending on the permissions of the API user).

# More examples

## Give the order number(s) as command line argument

If you don't want to process a long list, but just one or two.
Supply the numbers as a JSON list, for instance:

```
ansible-playbook playbook.yml -e digicert_orders='[12345667]'
```

or multiple numbers:

```
ansible-playbook playbook.yml -e digicert_orders='[12345667,87263332]'
```


# Gotchas/TODO

* Map certificate types better (currently hardcoded to one profile). For
instance wildcards are not handled.
* Make this idempotent, by keeping a log of digicert orders that have
successfully been requested through the Sectigo API.
* Map email addresses to different ones. For example people that have
  left/fired/etc. No use in sending new certificates to them.

# Extras

* In order to keep an eye on the progress, run the `ac.sh` shell script every 5
  or 10 minutes from cron. It needs a file containing with FQDNs, one per line.
And an output file. Output looks like this:
```
Report generation started at 2020-07-10 17:45:00 CEST

NOTE: Problem sites are those with "TERENA SSL High Assurance CA 3"

Hostname                              Issuer
====================================================
cacti.geant.org                       GEANT EV ECC CA 4
catalogue.geant.org                   GEANT EV ECC CA 4
compendium.geant.org                  GEANT EV ECC CA 4
compendiumdatabase.geant.org          GEANT EV ECC CA 4
e-academy.geant.org                   GEANT EV ECC CA 4
eventr.geant.org                      GEANT EV ECC CA 4
events.geant.org                      GEANT EV ECC CA 4
hosted.geant.org                      GEANT EV ECC CA 4
indico.geant.org                      GEANT EV ECC CA 4
lg.geant.org                          GEANT EV ECC CA 4
login.geant.org                       GEANT EV ECC CA 4
owncloud.geant.org                    GEANT EV ECC CA 4
proxy.eduteams.org                    GEANT EV ECC CA 4
tf-csirt.org                          GEANT EV ECC CA 4
tnc19.geant.org                       GEANT EV ECC CA 4
tools.geant.net                       GEANT EV ECC CA 4
up2university.eu                      GEANT EV ECC CA 4
wiki.geant.org                        GEANT EV ECC CA 4
wiki.refeds.org                       GEANT EV ECC CA 4
bamboo.software.geant.org             GEANT EV RSA CA 4
bitbucket.software.geant.org          GEANT EV RSA CA 4
cat.eduroam.org                       GEANT EV RSA CA 4
edumeet.org                           GEANT EV RSA CA 4
f-ticks.edugain.org                   GEANT EV RSA CA 4
filesender.geant.org                  GEANT EV RSA CA 4
gateway.geant.org                     TERENA SSL CA 3
proxy.acc.eduteams.org                TERENA SSL CA 3
flowmon.geant.net                     TERENA SSL High Assurance CA 3
md-vpn-si.geant.net                   TERENA SSL High Assurance CA 3
met.refeds.org                        TERENA SSL High Assurance CA 3
omega.terena.org                      TERENA SSL High Assurance CA 3
pmp-central.geant.org                 TERENA SSL High Assurance CA 3
prod-insight.geant.org                TERENA SSL High Assurance CA 3
reep.refeds.org                       TERENA SSL High Assurance CA 3
sc.geant.org                          TERENA SSL High Assurance CA 3
services.oer.geant.org                TERENA SSL High Assurance CA 3
sso.up2university.eu                  TERENA SSL High Assurance CA 3
swan.open.up2university.eu            TERENA SSL High Assurance CA 3
tts.geant.net                         TERENA SSL High Assurance CA 3

Report generation finished at 2020-07-10 17:47:49 CEST
```
