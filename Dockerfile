#
# crashplan-enterprise Dockerfile
#
# https://github.com/jlesage/docker-crashplan-enterprise
#

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software versions.
ARG CRASHPLAN_VERSION=10.4.1
ARG CRASHPLAN_TIMESTAMP=15252000061041
ARG CRASHPLAN_BUILD=19

# Define software download URLs.
ARG CRASHPLAN_URL=https://download.crashplan.com/installs/agent/cloud/${CRASHPLAN_VERSION}/${CRASHPLAN_BUILD}/install/Code42_${CRASHPLAN_VERSION}_${CRASHPLAN_TIMESTAMP}_${CRASHPLAN_BUILD}_Linux.tgz

# Build CrashPlan.
FROM ubuntu:20.04 AS crashplan
ARG CRASHPLAN_URL
WORKDIR /tmp
COPY src/crashplan /build
RUN /build/build.sh "${CRASHPLAN_URL}"

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.16-v4.2.1

ARG DOCKER_IMAGE_VERSION
ARG CRASHPLAN_VERSION

# Define container build variables.
ARG TARGETDIR=/usr/local/crashplan

# Define working directory.
WORKDIR /tmp

# Install CrashPlan.
COPY --from=crashplan /tmp/crashplan-rootfs /
RUN \
    # Keep a copy of the default config.
    mv ${TARGETDIR}/conf /defaults/conf && \
    # Make sure the UI connects by default to the engine using the loopback IP address (127.0.0.1).
    sed-patch '/<orgType>ENTERPRISE<\/orgType>/a \\t<serviceUIConfig>\n\t\t<serviceHost>127.0.0.1<\/serviceHost>\n\t<\/serviceUIConfig>' /defaults/conf/default.service.xml && \
    # Add the javaMemoryHeapMax setting to the default service file.
    sed-patch '/<serviceUIConfig>/i\\t<javaMemoryHeapMax nil="true"/>' /defaults/conf/default.service.xml && \
    # Prevent automatic updates.
    rm -r /usr/local/crashplan/upgrade && \
    touch /usr/local/crashplan/upgrade && chmod 400 /usr/local/crashplan/upgrade && \
    # The configuration directory should be stored outside the container.
    ln -s /config/conf $TARGETDIR/conf && \
    # The cache directory should be stored outside the container.
    ln -s /config/cache $TARGETDIR/cache && \
    # The log directory should be stored outside the container.
    rm -r $TARGETDIR/log && \
    ln -s /config/log $TARGETDIR/log && \
    # The '/var/lib/crashplan' directory should be stored outside the container.
    ln -s /config/var /var/lib/crashplan && \
    # The '/repository' directory should be stored outside the container.
    # NOTE: The '/repository/metadata' directory in 6.7.0 changed to
    #       '/usr/local/crashplan/metadata' in 6.7.1.
    ln -s /config/repository/metadata /usr/local/crashplan/metadata

# Misc adjustments.
RUN  \
    # Clear stuff from /etc/fstab to avoid showing irrelevant devices in the open
    # file dialog window.
    echo > /etc/fstab && \
    # Save the current CrashPlan version.
    echo "${CRASHPLAN_VERSION}" > /defaults/cp_version

# Install dependencies.
RUN \
    add-pkg \
        # For the monitor.
        bc

# Enable log monitoring.
RUN \
    sed-patch 's|LOG_FILES=|LOG_FILES=/config/log/service.log.0|' /etc/logmonitor/logmonitor.conf && \
    sed-patch 's|STATUS_FILES=|STATUS_FILES=/config/log/app.log|' /etc/logmonitor/logmonitor.conf

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/jlesage/docker-templates/raw/master/jlesage/images/crashplan-enterprise-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "CrashPlan Enterprise" && \
    set-cont-env APP_VERSION "$CRASHPLAN_VERSION" && \
    set-cont-env DOCKER_IMAGE_VERSION "$DOCKER_IMAGE_VERSION" && \
    true

# Set public environment variables.
ENV \
    CRASHPLAN_SRV_MAX_MEM=1024M

# Define mountable directories.
VOLUME ["/storage"]

# Metadata.
LABEL \
    org.label-schema.name="crashplan-enterprise" \
    org.label-schema.description="Docker container for CrashPlan PRO" \
    org.label-schema.version="${DOCKER_IMAGE_VERSION:-unknown}" \
    org.label-schema.vcs-url="https://github.com/jlesage/docker-crashplan-enterprise" \
    org.label-schema.schema-version="1.0"
