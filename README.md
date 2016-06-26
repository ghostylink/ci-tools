# Purpose

A docker image containing all dependencies for testing.
Built from the [tutum/lamp](https://hub.docker.com/r/tutum/lamp/) image

[Current image stage](http://dockeri.co/image/ghostylink/ci-tools)

# Testing ghostylink main project

* A MySQL database
* Apache web server
* PHP (including XDebug extenstion to gather code coverage)

```bash
export PATH_TO_CODE="/path/to/ghostylink/project"
CID = $(docker run -it -d -v $PATH_TO_CODE:/tested_code ghostylink/ci-tools)
docker exec -it $CID ant <target>
```

