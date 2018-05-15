# How to configure Gitlab CI/CD with checkmarx scanning

* create repo with some vulnerable code e.g. https://github.com/kiview/damn-vulnerable-spring-boot-app
* setup a new gitlab repo - login/commit/emai/sshkey
* grab the runner keys from https://gitlab.com/'myname/myrepo'/settings/ci_cd under runner settings
* register the runner by running the following

`docker run --rm -it --name gitlab-runner -v gitlab-runner:/etc/gitlab-runner gitlab/gitlab-runner register \
  --non-interactive \
  --executor "docker" \
  --docker-image openjdk:8-alpine \
  --url "https://gitlab.com/" \
  --registration-token "YOUR KEY HERE" \
  --description "docker-runner" \
  --tag-list "docker" \
  --run-untagged \
  --locked="false"`

* start the runner
`docker run -d --name gitlab-runner -v gitlab-runner:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:latest`

https://docs.gitlab.com/runner/install/docker.html

* start ngrok on your CxServer
`ngrok http 80`

* Pick the way you want to do the scan - with CLI `.gitlab-ci-cxcli.yml` or with REST/curl `.gitlab-ci-rest.yml`. Rename that file to `.gitlab-ci.yml`
* Change the url in .gitlab-ci.yml to match that which ngrok gave you. Set the proper username and password
* Push the code, it will start the scan through the pipeline

# Notes
to see all options for the runner registration run
`docker run --rm -it --name gitlab-runner -v gitlab-runner:/etc/gitlab-runner gitlab/gitlab-runner register -h`

http://docs.gitlab.com/runner/register/#docker
