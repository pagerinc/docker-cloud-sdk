FROM google/cloud-sdk:262.0.0-alpine@sha256:2c70db867cfd11777f29f1dcebed8efa37afc8add47cb77132125c65c80f010d

# Install Docker and GCR Credentials helper
ENV DOCKER_VERSION='18.09.3' \
	DOCKER_API_VERSION='1.23'

RUN apk --no-cache add \
		make \
		jq \
	&& gcloud components install \
		gsutil \
		kubectl \
	&& curl -fsSLO \
		"https://download-stage.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" \
	&& tar --strip-components=1 -xvzf docker-${DOCKER_VERSION}.tgz -C /usr/local/bin \
	&& rm docker-${DOCKER_VERSION}.tgz \
	&& chmod +x /usr/local/bin/docker

COPY .docker /root/.docker

# Install yamllint
ENV YAMLLINT_VERSION='1.15.0'

RUN apk --no-cache add py-pip \
	&& pip install -q --no-cache-dir "yamllint==${YAMLLINT_VERSION}" \
	&& apk del py-pip

# Install sops
ENV SOPS_VERSION='3.3.1'

RUN curl -sL \
		"https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux" \
		-o /tmp/sops \
	&& chmod +x /tmp/sops \
	&& mv /tmp/sops /usr/local/bin/

# Install Helm and the GCS plugin for chart repos
ENV HELM_VERSION='2.14.3' \
	HELM_GCS_VERSION='v0.2.0' \
	HELM_HOME='/root/.helm'

RUN curl -fsSLO \
		"https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz" \
	&& tar --strip-components=1 -xvzf helm-v${HELM_VERSION}-linux-amd64.tar.gz -C /usr/local/bin \
	&& rm helm-v${HELM_VERSION}-linux-amd64.tar.gz \
	&& chmod +x /usr/local/bin/helm \
	&& mkdir -p /root/.helm/plugins \
	&& helm plugin install https://github.com/viglesiasce/helm-gcs.git \
		--version "${HELM_GCS_VERSION}" \
	&& helm plugin install https://github.com/pagerinc/helm-diff \
		--version 'master'

# Install shellcheck
COPY --from=koalaman/shellcheck-alpine:v0.7.0@sha256:169a51b086af0ab181e32801c15deb78944bb433d4f2c0a21cc30d4e60547065 /bin/shellcheck /bin/shellcheck

# Install hub
ENV HUB_VERSION=2.12.3
ENV HUB_BASE_URL=https://github.com/github/hub/releases/download
ENV HUB_TAR_FILE="v${HUB_VERSION}/hub-linux-amd64-${HUB_VERSION}.tgz"

RUN curl -L ${HUB_BASE_URL}/${HUB_TAR_FILE} |tar xvz && \
	mv hub-linux-amd64-${HUB_VERSION}/bin/hub /usr/local/bin/hub && \
	chmod +x /usr/local/bin/hub && \
	rm -rf hub-linux-amd64-${HUB_VERSION}
