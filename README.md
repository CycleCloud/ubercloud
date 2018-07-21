# CycleCloud project for running generic UberCloud Containter cluster and ANSYS 19 clusters on Azure

## Pre-requisites
- The following information from your UberCloud representative:
    1. Credentials (username and password) for the docker registry
    2. Ubercloud's docker registry servername (required for generic clusters)
    3. URI for the container (required for generic clusters)
    4. Container name (required for generic clusters)

## Usage
- From the root of this project, upload the project into the CycleCloud locker:
```
    $ cyclecloud project upload LOCKER-NAME
```

* Import the cluster as a template:
  * Generic UberCloud cluster template
```
    $ cyclecloud import_template -f templates/ubercloud_template.txt -c UberCloud
```
  * UberCloud ANSYS 19.0 cluster template
```
  $ cyclecloud import_template -f templates/ansys19_template.txt -c ANSYS_19.0
```
* Use the CycleCloud UI to launch an Ubercloud Cluster
