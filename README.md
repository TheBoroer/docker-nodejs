## Introduction

This is a Dockerfile to build a container image for nodeJS, with the ability to push and pull source code to and from git.

### Git repository

The source files for this project can be found here: [https://github.com/TheBoroer/docker-nodejs](https://github.com/TheBoroer/docker-nodejs)

If you have any improvements please submit a pull request.

### Docker hub repository

The Docker hub build can be found here: [https://hub.docker.com/u/boro/nodejs/](https://hub.docker.com/u/boro/nodejs/)

## Versions

Available Node.js version tags include:

- `14`
- `16`
- `18`
- `20`
- `22`
- `24`

_Alpine versions are automatically selected based on the Node.js version (uses the latest compatible Alpine Linux version for each Node.js release)._

## Building from source

To build from source you need to clone the git repo and run docker build:

```
git clone https://github.com/TheBoroer/docker-nodejs.git
cd docker-nodejs
docker build -t nodejs:node-18 .
```

### Building with custom Node.js version

You can build the image with a specific Node.js version using the `NODE_VERSION` build argument:

```
docker build --build-arg NODE_VERSION=20 -t nodejs:node-20 .
```

The build argument automatically uses the Alpine Linux base image (e.g., `NODE_VERSION=20` becomes `node:20-alpine`).

## Continuous Integration

This project uses Drone CI to automatically build Docker images for multiple Node.js versions. The `.drone.yml` configuration builds images for Node.js 14, 16, 18, 20, 22, and 24, and pushes them to Docker Hub with appropriate tags.

**Required Drone Secrets:**

- `dockerhub_username` - Your Docker Hub username
- `dockerhub_password` - Your Docker Hub password or access token

The build process automatically triggers on pushes to the `main` or `master` branches, as well as on git tags.

## Pulling from Docker Hub

```
docker pull boro/nodejs:node-18
```

You can pull specific Node.js versions:

```
docker pull boro/nodejs:node-14
docker pull boro/nodejs:node-16
docker pull boro/nodejs:node-18
docker pull boro/nodejs:node-20
docker pull boro/nodejs:node-22
docker pull boro/nodejs:node-24
```

## Running

To simply run the container:

```
docker run -d boro/nodejs:node-18
```

### Installing NPM Components

To install component for you node application to run simply include a `packages.json` file in the root of your application. The container will then install the components on start.

### Starting your application

At the moment the container looks for `server.js` in your web root and executes that.

### Available Configuration Parameters

The following flags are a list of all the currently supported options that can be changed by passing in the variables to docker with the -e flag.

- **NODE_START** : Set to a custom node start command (e.g. `npm start` or `node dist/server.js`). Defaults to `node server.js` in the `/app` directory.
- **USE_YARN** : Set to 1 to install packages via Yarn instead of NPM.
- **GIT_REPO** : URL to the repository containing your source code. If you are using a personal token, this is the https URL without https://, e.g github.com/project/ for ssh prepend with git@ e.g git@github.com:project.git
- **GIT_BRANCH** : Select a specific branch (optional)
- **GIT_EMAIL** : Set your email for code pushing (required for git to work)
- **GIT_NAME** : Set your name for code pushing (required for git to work)
- **GIT_PERSONAL_TOKEN** : Personal access token for your git account (required for HTTPS git access)
- **GIT_USERNAME** : Git username for use with personal tokens. (required for HTTPS git access)
- **RUN_SCRIPTS** : Set to 1 to execute scripts

### Dynamically Pulling code from git

One of the nice features of this container is its ability to pull code from a git repository with a couple of environmental variables passed at run time.

REQUIRED: To create a personal access token on Github follow this [guide](https://help.github.com/articles/creating-an-access-token-for-command-line-use/).

#### Personal Access token

You can pass the container your personal access token from your git account using the **GIT_PERSONAL_TOKEN** flag. This token must be setup with the correct permissions in git in order to push and pull code.

Since the access token acts as a password with limited access, the git push/pull uses HTTPS to authenticate. You will need to specify your **GIT_USERNAME** and **GIT_PERSONAL_TOKEN** variables to push and pull. You'll need to also have the **GIT_EMAIL**, **GIT_NAME** and **GIT_REPO** common variables defined.

```
docker run -d -e 'GIT_EMAIL=email_address' -e 'GIT_NAME=full_name' -e 'GIT_USERNAME=git_username' -e 'GIT_REPO=github.com/project' -e 'GIT_PERSONAL_TOKEN=<long_token_string_here>' boro/nodejs:node-18
```

To pull a repository and specify a branch add the **GIT_BRANCH** environment variable:

```
docker run -d -e 'GIT_EMAIL=email_address' -e 'GIT_NAME=full_name' -e 'GIT_USERNAME=git_username' -e 'GIT_REPO=github.com/project' -e 'GIT_PERSONAL_TOKEN=<long_token_string_here>' -e 'GIT_BRANCH=stage' boro/nodejs:node-18
```

### Scripting

There is often an occasion where you need to run a script on code to do a transformation once code lands in the container. For this reason we have developed scripting support. By including a scripts folder in your git repository and passing the **RUN_SCRIPTS=1** flag to your command line the container will execute your scripts. Please see the [repo layout guidelines](docs/repo_layout.md) for more details on how to organise this.

## Special Git Features

Specify the `GIT_EMAIL` and `GIT_NAME` variables for this to work. They are used to set up git correctly and allow the container to push/pull.

### Using environment variables

To set the variables pass them in as environment variables on the docker command line.

Example:

```
docker run -d -e 'YOUR_VAR=VALUE' boro/nodejs:node-18
```

## Logging and Errors

### Logging

All logs should now print out in stdout/stderr and are available via the docker logs command:

```
docker logs <CONTAINER_NAME>
```

### WebRoot

You can set your webroot in the container to anything you want using the `WEBROOT` variable e.g -e "WEBROOT=/app/public". By default code is checked out into /app/ so if your git repository does not have code in the root you'll need to use this variable.
