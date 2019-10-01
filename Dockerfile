FROM google/cloud-sdk:264.0.0-alpine@sha256:f99b0f118cc67a8a6696f2c6c65dea2c92d82dd45c29f4ca357448a681cf4d88

ENV HELM_GCS_VERSION='v0.2.0' \
	HELM_HOME='/root/.helm' \
	HELM_VERSION='2.14.3' \
	HUB_VERSION=2.12.3 \
	SOPS_VERSION='3.3.1' \
	YAMLLINT_VERSION='1.15.0'

RUN apk --no-cache add \
		make \
		jq \
	&& gcloud components install \
		kubectl \
	&& echo 'installing yamllint' \
	&& apk --no-cache add py-pip \
	&& pip install -q --no-cache-dir "yamllint==${YAMLLINT_VERSION}" \
	&& apk del py-pip \
	&& echo 'installing sops' \
	&& curl -sL "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux" \
		-o /usr/local/bin/sops \
	&& chmod +x /usr/local/bin/sops \
	&& echo 'installing helm plugins' \
	&& curl -fsSLO "https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz" \
	&& tar --strip-components=1 -xvzf helm-v${HELM_VERSION}-linux-amd64.tar.gz -C /usr/local/bin \
	&& rm helm-v${HELM_VERSION}-linux-amd64.tar.gz \
	&& chmod +x /usr/local/bin/helm \
	&& mkdir -p /root/.helm/plugins \
	&& helm plugin install https://github.com/viglesiasce/helm-gcs.git \
		--version "${HELM_GCS_VERSION}" \
	&& helm plugin install https://github.com/pagerinc/helm-diff \
		--version 'master' \
	&& echo 'installing hub' \
	&& curl -L "https://github.com/github/hub/releases/download/v${HUB_VERSION}/hub-linux-amd64-${HUB_VERSION}.tgz" | tar xvz \
	&& mv hub-linux-amd64-${HUB_VERSION}/bin/hub /usr/local/bin/hub \
	&& chmod +x /usr/local/bin/hub \
	&& rm -rf hub-linux-amd64-${HUB_VERSION}

# Install Docker and shellcheck
COPY --from=docker:18.09.9@sha256:7215e8e09ea282e517aa350fc5380c1773c117b1867316fb59076d901e252d15 /usr/local/bin/docker /usr/local/bin/docker
COPY --from=koalaman/shellcheck-alpine:v0.7.0@sha256:169a51b086af0ab181e32801c15deb78944bb433d4f2c0a21cc30d4e60547065 /bin/shellcheck /bin/shellcheck
