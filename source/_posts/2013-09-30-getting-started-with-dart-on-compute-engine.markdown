---
layout: post
title: "Getting Started with Dart on Compute Engine"
date: 2013-09-30 20:41
comments: true
categories: 
- Dart
- Google
- ComputeEngine
- Stream
- Rikulo
---

Quick how-to on using [dart](http://www.dartlang.org) with [Compute Engine](https://cloud.google.com/products/compute-engine). If not aware, right now is a great time to dive into Compute Engine cause google is giving away $2,000 worth of [credits](https://plus.google.com/111783114889748547827/posts/Bou747dCfNb) to individuals interested in trying it out. I've been using it for about 2-3 months now and totally love it. 

What peeked my interest is it was flexable enough to run the dartvm as a server with minimal configuration. The one configuration hurdle was dependency of `GLIBC >= 2.15` in the dartvm binaries. The good news is with a simple startup script the compute engine instance can be provisioned to support the latest linux [dart-sdk](https://storage.googleapis.com/dart-editor-archive-integration/latest/dartsdk-linux-64.tar.gz).

The main tool we will use to provision a compute engine instance is [gcutil](https://developers.google.com/compute/docs/gcutil/). We could of used dartvm and [google_compute_v1beta15_api](http://pub.dartlang.org/packages/google_compute_v1beta15_api) but will save that for a later post.

After signing up for [Compute Engine](https://cloud.google.com/products/compute-engine) the next step should be to download and configure `gcutil`. 

```bash
$ wget https://google-compute-engine-tools.googlecode.com/files/gcutil-1.8.4.tar.gz 
$ tar xzvpf gcutil-1.8.4.tar.gz -C $HOME 
$ export PATH=./gcutil-1.8.4:$PATH
$ gcutil version
1.8.4
```

Next we want to create a `startup.sh` script that will be deployed to the compute engine instance. The script is a simple way to run additional commands to provision the instance. For dart we need to add a new `deb` source, update sources, install dependencies, fetch & unpack dart-sdk, and then execute our dart server. In the final line of the `startup.sh` script the command will create a dart server from the user account tied to this compute instance. Simply we clone a public git repo, install pub dependencies and screen a detached session that runs the dart server. This is not a very fancy way to deploy dart but a simple and quick way to get something running with no troubles. A real life deployment might include some trendy fab/chef/puppet combo. 


```bash startup.sh
#!/usr/bin/env bash

# Add an addtional source for the latest glibc
sudo sed -i '1i deb http://ftp.us.debian.org/debian/ jessie main' /etc/apt/sources.list

# Update sources 
sudo apt-get update

# Download latest glibc
sudo DEBIAN_FRONTEND=noninteractive apt-get -t jessie install -y libc6 libc6-dev libc6-dbg git screen

# Download the latest dart sdk
wget https://storage.googleapis.com/dart-editor-archive-integration/latest/dartsdk-linux-64.tar.gz -O /dartsdk-linux-64.tar.gz

# Unpack the dart sdk
tar -zxvf /dartsdk-linux-64.tar.gz -C /

su - financeCoding -c 'ls -al && cd ~ && pwd && git clone https://github.com/rikulo/stream.git && /dart-sdk/bin/dart --version && cd stream && /dart-sdk/bin/dart --version && /dart-sdk/bin/pub install && cd example/hello-static && screen -d -m /dart-sdk/bin/dart webapp/main.dart'
```

After we have the `startup.sh` script we then create another deployment script. The following script will be the gcutil commands needed to actually create and provision the compute instance. The last part of our script includes a firewall rule for the port that the [stream](https://github.com/rikulo/stream) sample is running on. Without proper firewall rules no access from the outside is possible.  

```bash deploy-dart-compute.sh
#!/usr/bin/env bash
set +o xtrace

USER=financeCoding
PROJECT=dart-compute-project
INSTANCE_NAME=dart-compute
TAGS=dart
MACHINE_TYPE=g1-small
NETWORK=default
IP=ephemeral
IMAGE=https://www.googleapis.com/compute/v1beta15/projects/debian-cloud/global/images/debian-7-wheezy-v20130816
SCOPES=https://www.googleapis.com/auth/userinfo.email,https://www.googleapis.com/auth/compute,https://www.googleapis.com/auth/devstorage.full_control
PERSISTENT_BOOT_DISK=true
ZONE=us-central1-b
STARTUP_SCRIPT=startup.sh
GCUTIL="gcutil --service_version=v1beta15 --project=$PROJECT"

$GCUTIL addinstance $INSTANCE_NAME --tags=$TAGS --zone=$ZONE --machine_type=$MACHINE_TYPE --network=$NETWORK --external_ip_address=$IP --service_account_scopes=$SCOPES --image=$IMAGE --persistent_boot_disk=$PERSISTENT_BOOT_DISK --metadata_from_file=startup-script:$STARTUP_SCRIPT

rc=$?
if [[ $rc != 0 ]] ; then
	echo "Not able to add instance"
    exit $rc
fi

$GCUTIL addfirewall $INSTANCE_NAME --allowed "tcp:8080"

rc=$?
if [[ $rc != 0 ]] ; then
	echo "Not able to provision firewall or has already been provisioned"
    exit $rc
fi

exit $rc
```

[![compute-engine-console](/images/2013-09-30-getting-started-with-dart-on-compute-engine/compute-engine-console.png)](/images/2013-09-30-getting-started-with-dart-on-compute-engine/compute-engine-console.png) 

[![stream-client](/images/2013-09-30-getting-started-with-dart-on-compute-engine/stream-client.png)](/images/2013-09-30-getting-started-with-dart-on-compute-engine/stream-client.png) 

And thats all that is needed to get dart on compute engine in two easy steps. The code can be found here [gist](https://gist.github.com/financeCoding/6789537).