FROM linuxcontainers/debian-slim:12

# Configure Build Defaults
ARG TARGETARCH
ARG TARGETOS

# Configure DevContainer User
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

# Configure Powershell
ARG DOTNET_VERSION=9.0.305
ARG DOTNET_PATH=/dotnet
ARG POWERSHELL_ARCH=${TARGETARCH}
ARG POWERSHELL_OS=${TARGETOS}
ARG POWERSHELL_VERSION=7.5.3
ARG POWERSHELL_PATH=/opt/microsoft/powershell/7
ARG POWERSHELL_MODULE_ROOT='.'

# Save Powershell configuration
ENV DOTNET_VERSION=${DOTNET_VERSION}
ENV DOTNET_PATH=${DOTNET_PATH}
ENV DOTNET_ROOT=${DOTNET_PATH}
ENV POWERSHELL_ARCH=${POWERSHELL_ARCH}
ENV POWERSHELL_OS=${POWERSHELL_OS}
ENV POWERSHELL_VERSION=${POWERSHELL_VERSION}
ENV POWERSHELL_PATH=${POWERSHELL_PATH}
ENV POWERSHELL_MODULE_ROOT=${POWERSHELL_MODULE_ROOT}
ENV PSModulePath=${POWERSHELL_MODULE_ROOT}/Modules

# Ensure dotnet is in our PATH
ENV PATH=${PATH}:${DOTNET_PATH}

# Install the dependencies
RUN apt-get update && apt-get install --yes \
    curl \
    git \
    libc6 \
    libgcc-s1 \
    libgssapi-krb5-2 \
    libicu72 \
    libssl3 \
    libstdc++6 \
    sudo \
    zlib1g

# Download the Debian dotnet repository configuration
RUN curl --location --silent --output /tmp/dotnet-sdk-${DOTNET_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz \
    https://builds.dotnet.microsoft.com/dotnet/Sdk/${DOTNET_VERSION}/dotnet-sdk-${DOTNET_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz

# Install dotnet sdk
RUN mkdir --parents ${DOTNET_PATH} && tar zxf /tmp/dotnet-sdk-${DOTNET_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz -C ${DOTNET_PATH}

# Download the powershell '.tar.gz' archive
RUN curl --location --silent --output /tmp/powershell.tar.gz \
    https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-${POWERSHELL_OS}-${POWERSHELL_ARCH}.tar.gz

# Expand powershell to the target folder
RUN mkdir --parents ${POWERSHELL_PATH}

# Expand powershell to the target folder
RUN tar zxf /tmp/powershell.tar.gz -C ${POWERSHELL_PATH}

# Set execute permissions
RUN chmod +x ${POWERSHELL_PATH}/pwsh

# Create the symbolic link that points to pwsh
RUN ln --symbolic ${POWERSHELL_PATH}/pwsh /usr/bin/pwsh

# Create the user
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} --create-home "${USERNAME}" \
    && adduser ${USERNAME} sudo

# Add sudo support
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Change default shell
RUN chsh ${USERNAME} --shell "${POWERSHELL_PATH}/pwsh"

# Set the default user
USER ${USERNAME}

# Install Required Modules
RUN pwsh -command "Install-Module Pester,PSScriptAnalyzer -Force"
