# Docker container for CrashPlan Enterprise
[![Docker Automated build](https://img.shields.io/docker/automated/jlesage/crashplan-enterprise.svg)](https://hub.docker.com/r/jlesage/crashplan-enterprise/) [![Docker Image](https://images.microbadger.com/badges/image/jlesage/crashplan-enterprise.svg)](http://microbadger.com/#/images/jlesage/crashplan-enterprise) [![Build Status](https://travis-ci.org/jlesage/docker-crashplan-enterprise.svg?branch=master)](https://travis-ci.org/jlesage/docker-crashplan-enterprise) [![GitHub Release](https://img.shields.io/github/release/jlesage/docker-crashplan-enterprise.svg)](https://github.com/jlesage/docker-crashplan-enterprise/releases/latest) [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/JocelynLeSage/0usd)

This is a Docker container for [CrashPlan Enterprise](https://www.code42.com).

The GUI of the application is accessed through a modern web browser (no installation or configuration needed on client side) or via any VNC client.

---

[![CrashPlan Enterprise logo](https://images.weserv.nl/?url=raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/crashplan-enterprise-icon.png&w=200)](https://www.code42.com)[![CrashPlan Enterprise](https://dummyimage.com/400x110/ffffff/575757&text=CrashPlan+Enterprise)](https://www.code42.com)

One solution to safeguard corporate data against data loss, leak, misuse
and theft.

---

## Quick Start

**NOTE**: The Docker command provided in this quick start is given as an example
and parameters should be adjusted to your need.

Launch the CrashPlan Enterprise docker container with the following command:
```
docker run -d \
    --name=crashplan-enterprise \
    -p 5800:5800 \
    -v /docker/appdata/crashplan-enterprise:/config:rw \
    -v $HOME:/storage:ro \
    jlesage/crashplan-enterprise
```

Where:
  - `/docker/appdata/crashplan-enterprise`: This is where the application stores its configuration, log and any files needing persistency.
  - `$HOME`: This location contains files from your host that need to be accessible by the application.

Browse to `http://your-host-ip:5800` to access the CrashPlan Enterprise GUI.
Files from the host appear under the `/storage` folder in the container.

## Documentation

Full documentation is available at https://github.com/jlesage/docker-crashplan-enterprise.

## Support or Contact

Having troubles with the container or have questions?  Please
[create a new issue].

For other great Dockerized applications, see https://jlesage.github.io/docker-apps.

[create a new issue]: https://github.com/jlesage/docker-crashplan-enterprise/issues
