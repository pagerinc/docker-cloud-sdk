FROM google/cloud-sdk:279.0.0-alpine@sha256:10f170068c5a7483961990b886443456e7b9f3cc8a271294cadf43d535a0b095

ENV HADOLINT_VERSION='v1.17.3' \
	HELM_GCS_VERSION='v0.2.0' \
	HELM_HOME='/root/.helm' \
	HELM_VERSION='2.16.1' \
	KUBEVAL_VERSION='0.14.0' \
	SHELLCHECK_VERSION='0.7.0' \
	SOPS_VERSION='3.3.1' \
	YAMLLINT_VERSION='1.15.0'

RUN apk add --no-cache --virtual .build-deps \
		tar=1.32-r0 \
		gzip=1.10-r0 \
		xz=5.2.4-r0 \
	&& apk add --no-cache \
		make=4.2.1-r2 \
		jq=1.6-r0 \
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
	&& echo 'installing kubeval' \
	&& curl -fsSLO "https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz" \
	&& tar -xvzf kubeval-linux-amd64.tar.gz -C /usr/local/bin \
	&& rm kubeval-linux-amd64.tar.gz \
	&& echo 'installing hadolint' \
	&& curl -sL "https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-x86_64" \
		-o /usr/local/bin/hadolint \
	&& chmod +x /usr/local/bin/hadolint \
	&& echo 'installing shellcheck' \
	&& curl -fsSLO "https://shellcheck.storage.googleapis.com/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz" \
	&& tar --strip-components=1 -xvJf shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz -C /usr/local/bin \
	&& rm shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz \
	&& chmod +x /usr/local/bin/shellcheck \
	&& apk del .build-deps
