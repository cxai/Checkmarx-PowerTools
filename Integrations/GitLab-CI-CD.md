# How to configure Gitlab CI/CD with Checkmarx scanning

* Configure a new runner by going to GitLab settings, under the 'runner' sectiion. Copy the GitLab CI/CD runner keys.
* Install and register the [GitLab docker runner](https://docs.gitlab.com/runner/install/docker.html) on the server that will be executing the pipeline:

      docker run --rm -it --name gitlab-runner -v gitlab-runner:/etc/gitlab-runner gitlab/gitlab-runner register \
	--non-interactive \
  	--executor "docker" \
  	--docker-image openjdk:8-alpine \
  	--url "https://gitlab.com/" \
  	--registration-token "YOUR KEY HERE" \
  	--description "docker-runner" \
  	--tag-list "docker" \
  	--run-untagged \
  	--locked="false"

If you want to see all the options for the [runner registration](http://docs.gitlab.com/runner/register/#docker) run

`docker run --rm -it --name gitlab-runner -v gitlab-runner:/etc/gitlab-runner gitlab/gitlab-runner register -h`

* Start the runner

`docker run -d --name gitlab-runner -v gitlab-runner:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:latest`

* Choose the way you want to do the scan: using the Checkmarx CLI or using REST/curl. Copy `.gitlab-ci-cxcli.yml` or `.gitlab-ci-rest.yml` from this repository and rename it to `.gitlab-ci.yml`
* Change the url in `.gitlab-ci.yml` to match that of your gitlab pipleline runner. Set the proper username and a password.
* Save `.gitlab-ci.yml` to the root of your repository and push the code. This will start the scan.

## Proof of Concept setup on GitLab.com
* Create a repo with some vulnerable code, e.g. clone https://github.com/kiview/damn-vulnerable-spring-boot-app
* Setup the new gitlab repo with login, commit, email, sshkey
* Grab the GitLab CI/CD runner keys from https://gitlab.com/'myname/myrepo'/settings/ci_cd, under the 'runner' settings
* Register the runner and start it per the directions above
* Start ngrok on your CxServer to get an external IP: `ngrok http 80`
* Get `.gitlab-ci-cxcli.yml` or `.gitlab-ci-rest.yml` and rename it to `.gitlab-ci.yml`
* Change the url in `.gitlab-ci.yml` to match that which ngrok gave you. Set the proper username and password
* Push the code to start the scan
