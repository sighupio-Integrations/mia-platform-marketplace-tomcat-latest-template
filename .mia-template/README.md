# sighup-secure-containers

## Summary

%CUSTOM_PLUGIN_SERVICE_DESCRIPTION%

## Local Development

To setup node, we suggest using [asdf][asdf] in combination with [direnv][direnv]: we wrote a short [blog post][direnv-asdf-blog-post] on how to set them up; alternatively your favourite package manager will likely work as well, at the cost of losing some handy automations.

Once you have all the dependency in place, you can create your local `.envrc` file, to ensure they get loaded automatically in your environment.

```shell
cp .envrc.dist .envrc
```

In order to start the service locally you can use the following command:

```shell
make run
```

And then verify that it is working by running the following command:

```shell
curl http://localhost:8080/
```

As a result the terminal should return you the following message:

```json
{"message":"Hello World!"}
```

## Contributing

To contribute to the project, please be mindful for this simple rules:

0. Don’t commit directly on master
0. Start your branches with `feature/` or `fix/` based on the content of the branch
0. Refer to the GitHub issue id inside the name of the branch, eg: `fix/123-slug-of-the-issue`
0. Write your commit messages in English
0. Write commit messages using [the imperative mood][imperative-mood]
0. Use [Conventional Commits][conventional-commits] for your commit messages
0. Once you are happy with your branch, open a [Merge Request][merge-request]

## Run the Docker Image

In order to run the docker image you need to have an active [SIGHUP Secure Containers][sighup-secure-containers] subscription, then you can pull it using the following commands:

```shell
$ docker login reg.sighup.io -u sighup -p ${REGISTRY_TOKEN}
$ docker pull reg.sighup.io/r/library/java/tomcat:${TOMCAT_VERSION}-openjdk-${OPENJDK_VERSION}
```

And then you can run it in your project's folder using the following command:

```shell
docker run --rm -it \
  -v $(pwd):/app -w /app \
  --entrypoint=/bin/bash \
  reg.sighup.io/r/library/java/tomcat:${TOMCAT_VERSION}-openjdk-${OPENJDK_VERSION}
```

[asdf]: https://asdf-vm.com
[conventional-commits]: https://www.conventionalcommits.org/
[direnv]: https://direnv.net
[merge-request]: %GITLAB_BASE_URL%/%CUSTOM_PLUGIN_PROJECT_FULL_PATH%/merge_requests
[sighup-secure-containers]: https://sighup.io/secure-containers
[imperative-mood]: https://en.wikipedia.org/wiki/Imperative_mood
