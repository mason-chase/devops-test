# DevOps Test

1. Please create a git repository and add the below repository as a git submodule,
https://github.com/Star2Billing/a2billing

2. Create a Helm Chart project that boots below servers:

traefik  (TCP 80) that routes /customer to and /admin
asterisk (TCP/UDP 5060)
web-customer docker image: php-apache (/customer)
web-admin    docker image: php-apache (/admin)
mysql or mariadb

you can create a `bootstrap.sh` that boots the project.
Share the result with user: mason-chase on GitHub in private mode.

Typically this task could take 3 to 6 hours for someone who doesn't know about Asterisk
or SIP protocol.

A2billing has its installation guide in INSTALL.rst,
you can use it as a reference to create a Docker-compose file.

Use MicroSIP from https://www.microsip.org/
and dial 77 , you should get user's credit balance

3. Add Pipeline (You can choose Azure or Gitlab) for automatic testing and automatic deployment
