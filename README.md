## Introduction
This is a Dockerfile to build a container image for nodeJS, with the ability to push and pull source code to and from git.

### Git repository
The source files for this project can be found here: [https://github.com/TheBoroer/docker-nodejs](https://github.com/TheBoroer/docker-nodejs)

If you have any improvements please submit a pull request.
### Docker hub repository
The Docker hub build can be found here: [https://hub.docker.com/u/boro/nodejs/](https://hub.docker.com/u/boro/nodejs/)
## Versions
| Tag | nodeJS | Alpine | Freebind ([repo](https://github.com/blechschmidt/freebind)) |
|-----|--------|--------|----------|
| latest | 10.16.0 | 3.9 | yes |
| 10.16.0 | 10.16.0 | 3.9 | yes |
| 8.11.2 | 8.11.2 | 3.6 | yes |
| 8.6.0 | 8.6.0 | 3.6 | yes |
| 6.11.4 | 6.11.4 | 3.4 | yes |
| 4.6.0 | 4.6.0 | 3.4 | no |

## Building from source
To build from source you need to clone the git repo and run docker build:
```
git clone https://github.com/TheBoroer/docker-nodejs
.git
docker build -t nodejs:latest .
```

## Pulling from Docker Hub
```
docker pull boro/nodejs
```

## Running
To simply run the container:
```
sudo docker run -d boro/nodejs
```

### Installing NPM Components
To install component for you node application to run simply include a ```packages.json``` file in the root of your application. The container will then install the components on start.
### Starting your application
At the moment the container looks for ```server.js``` in your web root and executes that.
### Available Configuration Parameters
The following flags are a list of all the currently supported options that can be changed by passing in the variables to docker with the -e flag.

 - **GIT_REPO** : URL to the repository containing your source code. If you are using a personal token, this is the https URL without https://, e.g github.com/project/ for ssh prepend with git@ e.g git@github.com:project.git
 - **GIT_BRANCH** : Select a specific branch (optional)
 - **GIT_EMAIL** : Set your email for code pushing (required for git to work)
 - **GIT_NAME** : Set your name for code pushing (required for git to work)
 - **SSH_KEY** : Private SSH deploy key for your repository base64 encoded (requires write permissions for pushing)
 - **GIT_PERSONAL_TOKEN** : Personal access token for your git account (required for HTTPS git access)
 - **GIT_USERNAME** : Git username for use with personal tokens. (required for HTTPS git access)
 - **WEBROOT** : Change the default webroot directory from `/var/www/html` to your own setting
 - **RUN_SCRIPTS** : Set to 1 to execute scripts


### Dynamically Pulling code from git
One of the nice features of this container is its ability to pull code from a git repository with a couple of environmental variables passed at run time.

REQUIRED: To create a personal access token on Github follow this [guide](https://help.github.com/articles/creating-an-access-token-for-command-line-use/).

#### Personal Access token

You can pass the container your personal access token from your git account using the __GIT_PERSONAL_TOKEN__ flag. This token must be setup with the correct permissions in git in order to push and pull code.

Since the access token acts as a password with limited access, the git push/pull uses HTTPS to authenticate. You will need to specify your __GIT_USERNAME__ and __GIT_PERSONAL_TOKEN__ variables to push and pull. You'll need to also have the __GIT_EMAIL__, __GIT_NAME__ and __GIT_REPO__ common variables defined.

```
docker run -d -e 'GIT_EMAIL=email_address' -e 'GIT_NAME=full_name' -e 'GIT_USERNAME=git_username' -e 'GIT_REPO=github.com/project' -e 'GIT_PERSONAL_TOKEN=<long_token_string_here>' richarvey/nginx-nodejs:latest
```

To pull a repository and specify a branch add the __GIT_BRANCH__ environment variable:
```
docker run -d -e 'GIT_EMAIL=email_address' -e 'GIT_NAME=full_name' -e 'GIT_USERNAME=git_username' -e 'GIT_REPO=github.com/project' -e 'GIT_PERSONAL_TOKEN=<long_token_string_here>' -e 'GIT_BRANCH=stage' richarvey/nginx-nodejs:latest
```

### Scripting
There is often an occasion where you need to run a script on code to do a transformation once code lands in the container. For this reason we have developed scripting support. By including a scripts folder in your git repository and passing the __RUN_SCRIPTS=1__ flag to your command line the container will execute your scripts. Please see the [repo layout guidelines](docs/repo_layout.md) for more details on how to organise this.

## Special Git Features
Specify the ```GIT_EMAIL``` and ```GIT_NAME``` variables for this to work. They are used to set up git correctly and allow the following commands to work.

### Push code to Git
To push code changes made within the container back to git run:
```
sudo docker exec -t -i <CONTAINER_NAME> /usr/bin/push
```

### Pull code from Git (Refresh)
In order to refresh the code in a container and pull newer code from git run:
```
sudo docker exec -t -i <CONTAINER_NAME> /usr/bin/pull
```

### Using environment variables

To set the variables pass them in as environment variables on the docker command line.

Example:
```
sudo docker run -d -e 'YOUR_VAR=VALUE' boro/nodejs
```

## Logging and Errors

### Logging
All logs should now print out in stdout/stderr and are available via the docker logs command:
```
docker logs <CONTAINER_NAME>
```
### WebRoot
You can set your webroot in the container to anything you want using the ```WEBROOT``` variable e.g -e "WEBROOT=/var/www/html/public". By default code is checked out into /var/www/html/ so if your git repository does not have code in the root you'll need to use this variable.
