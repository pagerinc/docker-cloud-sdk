FROM google/cloud-sdk:274.0.1-alpine@sha256:cc824eeb6355cdc59cd3dad705fdd6899d0a137154a68025df5598739f8c422f

ENV DOCKER_COMPOSE_VERSION='1.24.1' \
	HELM_GCS_VERSION='v0.2.0' \
	HELM_HOME='/root/.helm' \
	HELM_VERSION='2.16.1' \
	KUBEVAL_VERSION='0.14.0' \
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
	&& echo 'installing kubeval' \
	&& curl -fsSLO "https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz" \
	&& tar -xvzf kubeval-linux-amd64.tar.gz -C /usr/local/bin \
	&& rm kubeval-linux-amd64.tar.gz \
	&& echo 'installing docker-compose' \
	&& curl -fsSL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/run.sh" -o /usr/local/bin/docker-compose \
	&& chmod +x /usr/local/bin/docker-compose

# Install Docker hadolint and shellcheck
COPY --from=docker:19.03.5@sha256:83a5911718a8e472a56f615f2939358508dfc6f6f0eaa460ef58460d7c18d723 /usr/local/bin/docker /usr/local/bin/docker
COPY --from=koalaman/shellcheck-alpine:v0.7.0@sha256:169a51b086af0ab181e32801c15deb78944bb433d4f2c0a21cc30d4e60547065 /bin/shellcheck /bin/shellcheck
COPY --from=hadolint/hadolint:v1.17.3-debian@sha256:9bf3695c7116d45888c5bcab779b7b1c45a3ce3f5518e1e7f4b6e19b85a1c4a1 /bin/hadolint /bin/hadolint
