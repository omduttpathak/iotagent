ARG NODE_VERSION=10.15.3
FROM node:${NODE_VERSION}
ARG GITLAB_GROUP=csp_containerizationandautomation
ARG GITLAB_REPOSITORY=iotagent
ARG DOWNLOAD=1.9.0

# Copying Build time arguments to environment variables so they are persisted at run time and can be 
# inspected within a running container.
# see: https://vsupalov.com/docker-build-time-env-values/  for a deeper explanation.

ENV GITLAB_GROUP=${GITLAB_GROUP}
ENV GITLAB_REPOSITORY=${GITLAB_REPOSITORY}
ENV DOWNLOAD=${DOWNLOAD}

MAINTAINER FIWARE IoTAgent Team. Telefónica I+D

#
# The following RUN command retrieves the source code from GitHub.
# 
# To obtain the latest stable release run this Docker file with the parameters
# --no-cache --build-arg DOWNLOAD=stable
# To obtain any speciifc version of a release run this Docker file with the parameters
# --no-cache --build-arg DOWNLOAD=1.7.0
#
# The default download is the latest tip of the master of the named repository on GitHub
#
# Alternatively for local development, just copy this Dockerfile into file the root of the repository and 
# replace the whole RUN statement by the following COPY statement in your local source using :
#
# COPY . /opt/iotajson/
#
#RUN if [ "${DOWNLOAD}" = "latest" ] ; \
#	then \
#		RELEASE="master"; \
#		echo "INFO: Building Latest Development"; \
#	elif [ "${DOWNLOAD}" = "stable" ]; \
#	then \
#		RELEASE=$(curl -s https://api.github.com/repos/"${GITHUB_ACCOUNT}"/"${GITHUB_REPOSITORY}"/releases/latest | grep 'tag_name' | cut -d\" -f4); \
#		echo "INFO: Building Latest Stable Release: ${RELEASE}"; \
#	else \
#	 	RELEASE="${DOWNLOAD}"; \
#	 	echo "INFO: Building Release: ${RELEASE}"; \
#	fi && \
	# Ensure that unzip is installed, and download the sources
RUN	apt-get update && \
#	apt-get install -y  --no-install-recommends unzip && \
	apt-get install -y git-core && \
#	wget https://github.com/telefonicaid/iotagent-json/archive/1.9.0.zip && \
#	unzip 1.9.0.zip && \
	git clone http://fiware-csp-user:password@192.168.100.178/"${GITLAB_GROUP}"/"${GITLAB_REPOSITORY}".git && \
#	wget --no-check-certificate -O source.zip https://github.com/"${GITHUB_ACCOUNT}"/"${GITHUB_REPOSITORY}"/archive/"${RELEASE}".zip && \
#	unzip source.zip && \
#	rm source.zip && \
#	mv "${GITHUB_REPOSITORY}-${RELEASE}" /opt/iotajson && \
	mv iotagent /opt/ && \
#	rm -rf /opt/iotagent-json-1.9.0/lib/bindings/HTTPBinding.js && \
	# Remove unzip and clean apt cache
	apt-get clean && \
#	apt-get remove -y unzip && \
	apt-get -y autoremove


WORKDIR /opt/iotagent

#ADD	HTTPBinding.js /opt/iotagent/lib/bindings/

RUN \
	# Ensure that Git is installed prior to running npm install
	apt-get update && \
	apt-get install -y apt-utils && \
	apt-get install -y git && \
	npm install pm2@3.2.2 -g && \
	npm install --production --silent && \
	echo "INFO: npm install --production..." && \
#	npm install --production && \
	# Remove Git and clean apt cache
	apt-get clean && \
	apt-get remove -y git && \
	apt-get -y autoremove

USER node
ENV NODE_ENV=production

ENTRYPOINT ["pm2-runtime", "bin/iotagent-json"]
CMD ["-- ", "config.js"]