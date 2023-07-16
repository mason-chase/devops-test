# DevOps Test

## Must do:

1. [GitOps Principles](https://en.wikipedia.org/wiki/DevOps#GitOps)
2. Document your solution

## Requirements and Step


1. Setup a Kubernete cluster on a single node (CP + Worker) using Kubespray
2. Create a Helm Chart that bootstraps a Wordpress application with MySQL and PhpMyAdmin ingress

- Wordpress Ingress
- MySQL Deployment
- PhpMyAdmin has an Ingress

## Nice to do

1. Create a Terraform script for Kubernete cluster
2. Create a CI/CD Azure Pipeline in yaml format in the root project.

## Delivery
1. You will be given a VPS running Ubuntu 22, you must be able deploy and with single command line on this VPS.
2. You must plan your code in such way that if we erase the VPS and start over, we must arrive at the same state that you intended.
3. Must have a single execution script/file that we can bootstrap and review your result in a clean Ubuntu server in our environment
4. Clone/copy this repository into a new Github repository and add your result, then share the result with user: `mason-chase` on GitHub in private mode.
5. We must be able to navigate to `https://candidate-name.domain.com/dbadmin` and observe PhpMyAdmin UI and it must work
6. WordPress must be available at `https://candidate-name.domain.com/wordpress`
