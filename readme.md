# Ionic Boilerplate for OS X

Features:

* Uses NPM only (no bower)
* Lightning fast build scripts
* OS X automation to launch Safari and simulator in debugging mode

## Requirements

* node v5
* brew
* fswatch

`brew install fswatch`

## Setup

### Clone the Repo

    git clone git@github.com:benallfree/ionic-boilerplate.git
    npm install

### Configure the project

Update `config.xml`

    <widget id="...">
    <name>
    <description>
    <author>
  
Update `ionic.project`

Update `src/haml/home.haml`

Update `src/haml/debug.haml`

`mkdir www`

### Add a platform

`ionic platform add ios`


## Building

To build the entire system, run `./build.sh`

To watch for source code changes and automatically re-launch the simulator on change, use `./watch.sh`
  
# For production

Update `config.xml`

    <content src="index.html">
