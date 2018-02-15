# CycleCloud project for running UberCloud Containters in a Univa Cluster on Azure

## Pre-requisites
- gridengine project with Univa packages uploaded into a CycleCloud locker (_details to follow_)
- A license for Univa Grid Engine
- The following information from your UberCloud representative:
    1. Ubercloud's docker registry servername
    2. Credentials (username and password) for the docker registry
    3. URI for the container registry
    4. Container name

## Usage
- From the root of this project, upload the project into the CycleCloud locker:
```
    $ cyclecloud project upload LOCKER-NAME
```

- Import the cluster as a template:
```
    $ cyclecloud import_template -f templates/ubercloud_univa_template.txt -c UberCloud
```

- Use the CycleCloud UI to launch an Ubercloud Cluster
