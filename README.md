# Example Powershell Module Project

This is an example Powershell module project that can be used as a guide for projects that want to create and
publish Powershell modules.

- [Requirements](#requirements)
- [Features at a Glance](#features-at-a-glance)
  - [Helper Functions](#helper-functions)
  - [Module Publishing](#module-publishing)
  - [Linting](#linting)
  - [Testing](#testing)
- [Examples](#examples)
  - [ShouldProcess and -WhatIf](#shouldprocess-and--whatif)
  - [ShouldProcess and -Debug](#shouldpress-and--debug)
  - [ShouldProcess and -Verbose](#shouldprocess-and--verbose)
  - [Configuring Continuous Integration](#configuring-continuous-integration)
- [Project Details](#project-details)
  - [.devcontainer/](#devcontainer)
  - [.vscode/](#vscode)
  - [Modules/](#modules)
  - [Miscellaneous Files](#miscellaneous-files)
- [Module Details](#module-details)
  - [Claco.Powershell.psd1](#clacopowershellpsd1)
  - [Claco.Powershell.psm1](#clacopowershellpsm1)
  - [Miscellaneous Folders](#miscellaneous-folders)
- [Function Style Guide](#function-style-guide)
  - [Function Layout](#function-layout)
  - [Error Handling](#error-handling)
  - [Writing Output](#writing-output)
  - [Using -Debug, -Verbose, -WhatIf, -Confirm](#using--debug--verbose--whatif--confirm)

## Requirements

This project assumes you have Powershell 7 available in your `PATH`, and that you have installed the `Pester` and `PSScriptAnalyzer` modules:

```powershell
PS> Install-Module Pester,PSScriptAnalyzer
```

## Features at a Glance

This project includes a boilerplate Powershell module that includes the following:

- Powershell module [autoloading](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_modules?view=powershell-7.5#module-autoloading) support
- Powershell testing with [Pester](https://pester.dev/)
- Powershell linting with [PSScriptAnalyzer](https://learn.microsoft.com/en-us/powershell/module/psscriptanalyzer/)
- [Pre-Commit](https://pre-commit.com/) support (including Pester and PSScriptAnalyzer validation)
- [Dev Container](https://code.visualstudio.com/docs/devcontainers/containers) support in VSCode ([Podman](https://podman.io/) or [Docker](https://www.docker.com/))
- Example cmdlets with VSCode user defined [snippets](https://code.visualstudio.com/docs/editing/userdefinedsnippets)
- Cmdlets/VSCode [tasks](https://code.visualstudio.com/docs/debugtest/tasks) to publish module to local workspace repository

### Helper Functions

This project includes some functions to aid in determining and controlling verbose and debug output workflows.

This project recommends that you use these to decide what functions you call that should, _or should not_, also supply verbose or debug output, by passing the appropriate value or preference value to the function being called.

#### `Test-Verbose` and `Get-VerbosePreference`

These functions detects if verbose output has been requested in the current calling context.

```powershell
# Invoke-ApiRequest -Verbose
function Invoke-ApiRequest {
  [CmdletBinding()]
  param ()

  try {
    Write-DebugFunctionStart

    $IsVerbose = Test-Verbose

    Invoke-RestMethod -Uri 'https://blogs.msdn.microsoft.com/powershell/feed/' -Verbose:$IsVerbose | Format-List
  } catch {
    Write-Exception
  } finally {
    Write-DebugFunctionEnd
  }
}
```

You can also set `VerbosePreference` for the current function scope rather than passing `-Verbose` to all individual function calls:

```powershell
# Invoke-ApiRequest -Verbose
function Invoke-ApiRequest {
  [CmdletBinding()]
  param ()

  try {
    Write-DebugFunctionStart

    $VerbosePreference = Get-VerbosePreference

    $Feeds = Invoke-RestMethod -Uri 'https://blogs.msdn.microsoft.com/powershell/feed/' # -Verbose:$IsVerbose
    foreach ($Feed in $Feeds) {
        Invoke-RestMethod -Url "https://example.com/cache/preload/$($Feed.Url)" # -Verbose:$IsVerbose
    }
  } catch {
    Write-Exception
  } finally {
    Write-DebugFunctionEnd
  }
}
```

#### `Test-Debug` and `Get-DebugsPreference`

These work just like `Test-Verbose` and `Get-VerbosePreference`, but for `-Debug` options instead:

```powershell
# Invoke-ApiRequest -Debug
function Invoke-ApiRequest {
  [CmdletBinding()]
  param ()

  try {
    Write-DebugFunctionStart

    $IsDebug = Test-Debug

    Invoke-RestMethod -Uri 'https://blogs.msdn.microsoft.com/powershell/feed/' -Debug:$IsDebug | Format-List
  } catch {
    Write-Exception
  } finally {
    Write-DebugFunctionEnd
  }
}
```

### Module Publishing

This project contains VsCode tasks and functions to publish the current module to a local workspace `PSRepository` for local testing and troubleshooting:

First, initialize the workspace repository:

```powershell
PS> Initialize-WorkspaceRepository
Initializing workspace repository 'ws.claco.powershell' in '/Users/claco/Projects/claco.powershell/.PSWorkspaceRepository'...

Name                      InstallationPolicy   SourceLocation
----                      ------------------   --------------
ws.claco.powershell       Trusted              /Users/claco/Projects/claco.powershell/.PSWorkspaceRepository
```

Now, execute `Publish-WOrkspaceModule` to publish the module in this repository for testing:

```powershell
PS> Publish-WorkspaceModule -Repository PSGallery
Publishing module 'Claco.Powershell.0.0.1.nupkg' to repository 'PSGallery'...
```

You can publish this module to any NuGet repository that configured using the `-Repository` parameter:

### Linting

This project is configured to use `PSScriptAnalyzer` to lint the Powershell in this project using the settings in [PSScriptAnalyzerSettings.psd1](./Modules/Claco.Powershell/PSScriptAnalyzerSettings.psd1) by default.

You can lint the project using the VsCode task or run the command:

```powershell
Invoke-Lint
Linting '../claco.powershell' with settings './Modules/Claco.Powershell/PSScriptAnalyzerSettings.psd1'.
No issues detected.
```

Pre-Commit is also configured to run the lint:

```shell
pre-commit run -a invoke-lint
invoke-lint..............................................................Passed
```

### Testing

This project is configured to use `Pester` to test the Powershell in this project using the settings in [PesterConfiguration.psd1](./Modules/Claco.Powershell/PesterConfiguration.psd1) by default.

You can lint the project using the VsCode task or run the command:

```powershell
Invoke-Test
Pester v5.7.1

Starting discovery in 4 files.
Discovery found 70 tests in 25ms.
Running tests.

Running tests from '/Users/claco/Projects/claco.powershell/Modules/Claco.Powershell/Claco.Powershell.Tests.ps1'
Describing Invoke-Lint
  [+] Loads PSScriptAnalyzerSettings.psd1 if it exists 21ms (20ms|1ms)
  [+] Does not throw exceptions by default 9ms (9ms|0ms)
  [+] Writes exception to Warning stream by default 12ms (11ms|0ms)
...
```

Pre-Commit is also configured to run the tests:

```shell
pre-commit run -a invoke-test
invoke-test..............................................................Passed
```

You can also pass `-Cover` to outout tet coverage information during local development.

## Examples

The following examples can be found in [Modules Examples](./Modules/Claco.Powershell/Examples/Examples.psm1):

- `Invoke-SimpleExample`: A simple function demonstrating the use of common parameters and their associated [preference variables](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.5).

- `Invoke-PipelineExample`: A simple function demonstrating the use of [pipeline](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-7.5) processing.

These were created using the [Powershell snippets](.vscode/powershell.code-snippets) for VsCode included in this project. You can call those while editing any `.ps1`, or `.psm1` file:

```powershell
cmdlet-simple<TAB>
cmdlet-pipeline<TAB>
```

The examples are not exported by the module by default. To try them out, import the file above, then you can run the commands directly:

```powershell
PS> Import-Module ./Modules/Claco.Powershell/Examples/Examples.psm1
PS> Invoke-SimpleExample
Running Invoke-SimpleExample...
```

### ShouldProcess and -WhatIf

The example functions, and their corresponding snippets, support `ShouldProcess` and the `-WhatIf` parameter.

For demonstration purposes, the `ShouldProcess` blocks contain the majority of function code, even code that is read-only, or safe to perform as they do not alter target state in any way:

```powershell
PS> Invoke-SimpleExample -WhatIf
What if: Performing the operation "Process" on target "Invoke-SimpleExample".
```

This project recommends you always place read-only code, or code that does not alter target state, outside of `ShouldProcess` blocks, and only wrap blocks of code in `ShouldProcess` when it will write, or otherwise alter the target state in some way.
For example, if you have a function `Clear-RepositoryCache`, it would list and even read files, but only consult `ShouldProcess` for the item removal if other conditions are met:

```powershell
foreach ($ProcessingPath in $Path) {
  $Contents = Get-Content -Path $ProcessingPath

  if ($Content -like 'DELETE') {
    if ($PSCmdlet.ShouldProcess($ProcessingPath, 'DELETE')) {
        Remove-Item -Path $ProcessingPath
    }
  }
}
```

This allows the maximum amount of code paths to be run during testing and ci troubleshooting while keeping unsafe, or undesired operations from being executed unintentionally:

```yaml
# .gitlab-ci.yml
variables:
  WhatIfPreference: true

restart-repository:
  script:
    - Clear-RepositoryCache      # lists, reads, but won't delete cache items until WhatIfPreference is $false
    - Restart-RepositoryService  # won't restart the service until WhatIfPreference is $false

# this is the same as:
# restart-repository:
#   script:
#     - Clear-RepositoryCache -WhatIf
#     - Restart-RepositoryService -WhatIf
```

See [Everything you wanted to know about ShouldProcess](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.5) for more information.

### ShouldPress and -Debug

`Invoke-SimpleExample` has `ConfirmImpact` set to `Low`, which is the default.
If `ConfirmPreference` is set to `Low`, or higher (`High` is the default), all `ShouldProcess` blocks will prompt the user for confirmation when `-Debug` is passed in addition to displaying any output from `Write-Debug`:

```powershell
DEBUG: ›››› Invoke-SimpleExample ››››››››››››››››››››››››››››››››››››››››››››››››››
DEBUG: ConfirmPreference=High
DEBUG: WhatIfPreference=False

Confirm
Are you sure you want to perform this action?
Performing the operation "Process" on target "Invoke-SimpleExample".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):
Running Invoke-SimpleExample...
DEBUG: ‹‹‹‹ Invoke-SimpleExample ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
```

You can prevent this behavior in one of four ways:

- change your cmdlet to set the `ConfirmImpact` attribute to `None`
- set `$ConfirmPreference` to `None` prior to calling `Invoke-SimpleExample`
- pass `-Confirm:$false` when calling `Invoke-SimpleExample`s
- ¹pass `-Force`, which sets `$ConfirmPreference` to `None` prior to calling `ShouldProcess`

```powershell
Invoke-SimpleExample -Debug -Confirm:$false
DEBUG: ›››› Invoke-SimpleExample ››››››››››››››››››››››››››››››››››››››››››››››››››
DEBUG: ConfirmPreference=None
DEBUG: WhatIfPreference=False
Running Invoke-SimpleExample...
DEBUG: ‹‹‹‹ Invoke-SimpleExample ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
```

_¹ `-Force` override of `ConfirmPreference` within the function only works if `ConfirmImpact` and `ConfirmPreference` are the same value. Not sure if this is a bug, a quirk, or for what reasons and why._

See [Everything you wanted to know about ShouldProcess](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.5) for more information.

### ShouldProcess and -Verbose

In addition to displaying any content from calls to `Write-Verbose`, `-Verbose` also has the added benefit that it will also print out the same type of message that `-WhatIf` prints, but the block will be executed instead of being skipped:

```powershell
Invoke-SimpleExample -Verbose
VERBOSE: Performing the operation "Process" on target "Invoke-SimpleExample".
Running Invoke-SimpleExample...
```

### Configuring Continuous Integration

You can combine these different options and preferences above to easily enable or disable debug output, verbose output, confirmation prompt suppression, and other options in CI systems, while retaining the normal behavior when running in an interactive terminal by a person.

```yaml
# .gitlab-ci.yml
variables:
  ConfirmPreference: 'None'               # -NonInteractive, never prompt for confirmation in ci automation
  DebugPreference: 'SilentlyContinue'     # set to 'Continue' to display additional debug information in the job logs
  ErrorActionPreference: 'Stop'           # always stop execution when an error is encountered in ci automation
  InformationPreference: 'Continue'       # automatically output Write-Information like Write-Host in the job logs
  VerbosePreference: 'SilentlyContinue'   # set to 'Continue' to display additional verbose information in the job logs
```

See [About Preference Variables](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.5) for other preference variables that you can use to globally control the behavior of entire workflows and pipelines without having to alter `script:` block function invocations.

## Project Details

### .devcontainer/

This folder contains the VsCode dev container configuration. See [Developing inside a Container](https://code.visualstudio.com/docs/devcontainers/containers) for more information.

To use the dev container, choose "*Dev Containers: Rebuild and Reopen in Container*" from the VsCode command palette.

#### .devcontainer/devcontainer.json

This is the primary dev container configuration which tells VsCode how to interact with the dev container that is built using [.devcontainer/Dockerfile](.devcontainer/Dockerfile).

This container is configured to pass the container workspace folder as a `--build-arg` so that the [Modules](./Modules/) folder can be added to `PSModulePath`. This allows the module to be autoloaded without having to call `Import-Module` when working in this project.

```json
  "build": {
    "args": {
      "POWERSHELL_MODULE_ROOT": "${containerWorkspaceFolder}"
    },
    "context": "..",
    "dockerfile": "Dockerfile"
  },
```

It also sets the user that is configured inside of the container, as well as asking VsCode to auto install the recommended[extensions](.vscode/extensions.json) used in this project.

```json
  "customizations": {
    "vscode": {
      "extensions": [
        "editorconfig.editorconfig",
        "ms-vscode-remote.remote-containers",
        "ms-vscode.powershell",
        "streetsidesoftware.code-spell-checker",
        "usernamehw.remove-empty-lines"
      ],
      "settings": {}
    }
  },
  "remoteUser": "vscode"
```

#### .devcontainer/Dockerfile

This is the Dockerfile used to build the dev container. It's primary purpose is to install powershell and dotnet into a non root user for local development.

It can be configured in a variety of ways using the following `ARG`/`--build-arg` options for the user configuration and dotnet/powershell installation configuration:

```dockerfile
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ARG DOTNET_VERSION=9.0.305
ARG DOTNET_PATH=/dotnet
ARG POWERSHELL_ARCH=${TARGETARCH}
ARG POWERSHELL_OS=${TARGETOS}
ARG POWERSHELL_VERSION=7.5.3
ARG POWERSHELL_PATH=/opt/microsoft/powershell/7
ARG POWERSHELL_MODULE_ROOT='.'
```

The [Modules](./Modules/) folder is added to `PSModulePath` so it is automatically loaded without having to call Import-Module during development, and `dotnet` is added to `PATH` so it is available to powershell and the user:

```dockerfile
ENV PSModulePath=${POWERSHELL_MODULE_ROOT}/Modules
ENV PATH=${PATH}:${DOTNET_PATH}
```

 Finally, the required powershell modules are installed in the users session:

```dockerfile
USER ${USERNAME}
RUN pwsh -command "Install-Module Pester,PSScriptAnalyzer -Force"
```

### .vscode/

This folder contains project specific VsCode settings that are used both inside, and outside, of dev containers. This includes any tasks, snippets, launch configurations, tasks, and settings.

#### .vscode/extensions.json

This tells VsCode what extensions are recommended for ths current project and relevant settings. You can aso tell VsCode what recommendations to ignore if they're being annoying or just incompatible with the project for some reason.

```json
{
  "recommendations": [
    "editorconfig.editorconfig",
    "ms-vscode-remote.remote-containers",
    "ms-vscode.powershell",
    "redhat.vscode-yaml",
    "streetsidesoftware.code-spell-checker",
    "usernamehw.remove-empty-lines"
  ]
}
```

#### .vscode/launch.json

This file contains a launch configurations that tell VsCode how to start, or run things, in Powershell. These are typically used for debugging and other related activities. See [Visual Studio Code debug configuration](https://code.visualstudio.com/docs/debugtest/debugging-configuration).

THe current configuration uses `Import-Module` to ensure the current project module is loaded and available in tasks:

```json
    {
      "name": "PowerShell: Module Interactive Session",
      "type": "PowerShell",
      "request": "launch",
      "script": "Import-Module -Force ${workspaceFolder}/Modules/Claco.Powershell/Claco.Powershell.psd1"
    }
```

#### .vscode/powershell.code-snippets

This is a set of project specific Powershell module snippets. They're used to generate the [Modules Examples](./Modules/Claco.Powershell/Examples/Examples.psm1).

#### .vscode/settings.json

The are project workspace specific settings to ensure consistent code formatting and user experience for VsCode users of this project. We'll cover some of the more important settings below.

The [PSScriptAnalyzerSettings.psd1](./Modules/Claco.Powershell/PSScriptAnalyzerSettings.psd1) file is configured to be used by VsCode Powershell language extension linting in the ui, and uses the `$pester` problem matcher in [tasks](#vscodetasksjson) to display any linting issues in the "*Problems View*" in vscode::

```json
  "powershell.scriptAnalysis.settingsPath": "./Modules/Claco.Powershell/PSScriptAnalyzerSettings.psd1",
```

The integrated terminal is configured to use `pwsh` as the default shell, and ensures the [Modules](./Modules/) folder is added to `PSModulePath` for module auto loading:

```json
  "terminal.integrated.defaultProfile.osx": "pwsh",
  "terminal.integrated.env.linux": {
    "PSModulePath": "${workspaceFolder}/Modules"
  },
  "terminal.integrated.env.osx": {
    "PSModulePath": "${workspaceFolder}/Modules"
  },
```

#### .vscode/tasks.json

There are some predefined tasks for VsCode users that call their corresponding cmdlets. These include:

- `Initialize-WorkspaceRepository`: Creates a local `PSRepository` in the root of this projects folder
- `Invoke-Lint`: Lint the project using `PSScriptAnalyzer`
- `Invoke-Test`: Run project test suite using `Pester`
- `Publish-WorkspaceModule`: Publishes the project module to the local [PSRepository](https://learn.microsoft.com/en-us/powershell/gallery/how-to/working-with-local-psrepositories?view=powershellget-3.x) for further testing

See the [Pester](https://pester.dev/) and [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer?tab=readme-ov-file#table-of-contents) documentation for more information how these are configured and run generally.

While you can configure tasks to run directly in the default shell, running them in a separate child process to `pwsh` keeps failing tasks from effecting or terminating the parent shell process:

```json
  "options": {
    "shell": {
      "executable": "pwsh",
      "args": [
      "-NonInteractive",
      "-NoProfile",
      "-Command"
      ]
    }
  }
```

You can run these tasks by selecting "*Tasks: Run Task*" in the VsCode command palette.

## Modules

This is the folder where this projects Powershell [module](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_modules?view=powershell-7.5) resides. This folder is automatically added to `PSModulePath` so any module folders within it are available in `pwsh` without having to call `Import-Module` unless you need to reload it during development.

See [How to Write a PowerShell Script Module](https://learn.microsoft.com/en-us/powershell/scripting/developer/module/how-to-write-a-powershell-script-module?view=powershell-7.5) for more information about module layout.

### Modules/Claco.Powershell

This is the main project modules folder, which contains the following files:

- `Claco.Powershell.psd1`: [Module manifest](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_module_manifests?view=powershell-7.5) file with module details for importing and publishing
- `Claco.Powershell.psm1`: Primary module code file where top level functions and cmdlets reside
- `Claco.Powershell.Tests.ps1`: [Pester](https://pester.dev/) tests for the code in the primary module file
- `PesterConfiguration.psd1`: [Pester configuration](https://pester.dev/docs/usage/configuration) file used in `Invoke-Test`
- `PSScriptAnalyzerSettings.psd1`: [PSScriptAnalyzer configuration](https://learn.microsoft.com/en-us/powershell/module/psscriptanalyzer/invoke-scriptanalyzer?view=ps-modules) file used in `Invoke-Lint`

A more detailed breakdown of the module code itself is located in [Module Details](#module-details) information.

### Miscellaneous Files

- `.dockerignore`: List of files and folders that should not be sent to the Docker build context
- `.editorconfig`: [EditorConfig](https://editorconfig.org/) setting file to control some formatting aspects of sets of files
- `.gitignore`: Standard git ignore file to prevent certain files and folders from being committed
- `.pre-commit-config.yaml`: [Pre-Commit](https://pre-commit.com/) configuration file

#### Pre-Commit Powershell Hooks

Because Powershell can treat errors as both terminating and non termination events, we have to take steps to ensure that the ways in which the functions are called surface proper non zero exit codes

```yaml
  # Invoke-Lint returns result output and writes exceptions to the Warning stream.
  #   It throws no exceptions and returns no exit codes.
  #   Convert the reported count as the exit code for pre-commit.
  entry: pwsh -NoLogo -NoProfile -NonInteractive -Command "Write-Output ($Report=Invoke-Lint); exit $Report.Count"

  # Invoke-Test returns result output and writes exceptions to the Warning stream.
  #   It ignores Pester exceptions and exit code workflows to control the workflow.
  #   It throws no exceptions and returns no exit codes.
  #   Return the $LASTEXITCODE set by Pester for pre-commit.
  entry: pwsh -NoLogo -NoProfile -NonInteractive -Command "Invoke-Test; exit $LASTEXITCODE"
```

## Module Details

The [Modules](./Modules/) folder contains the primary Powershell module to b linted, tested, and released by this project.
This folder _may_ contain other module folders, with the following caveats:

- the code in other module folders will be linted, and will fail it there are issues in those files as well
- the tests in other module folders wil be executed, and will fail if there are issues in those tests or modules
- will _not_ be published individually, or within the primary module package

### Claco.Powershell.psd1

This is the primary modules [manifest](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_module_manifests?view=powershell-7.5) file that was generated using `New-ModuleManifest`.
This tells Powershell how to version, load, and package your module in `pwsh` and as a NuGet package.

By default, only functions or cmdlets [or other types] exported using `Export-ModuleMember` in `RootModule` are available when the module is imported using `Import-Module`:

```powershell
  # Script module or binary module file associated with this manifest.
  RootModule           = '.\Claco.Powershell.psm1'
```

Functions exported in the files listed in `NestedModules` are only available to the code inside the module itself, and are not exported when `Import-Module` is used.

```powershell
  # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
  NestedModules        = @(
    '.\Examples\Examples.psm1'
    '.\Testing\Testing.psm1'
    '.\Utilities\Utilities.psm1'
  )
```

You *may* import those files directly, which will import any exported functions into your current shell session:

```powershell
    PS> Import-Module ./Modules/Claco.Powershell/Utilities/Utilities.psm1
    PS> Test-Debug
    False
```

You *may also* reconfigure `FunctionsToExport` and other `*ToExport` settings to specifically export functions in `RootModule` *and* `NestedModules` files:

```powershell
  # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
  FunctionsToExport    = @('Invoke-Lint', 'Invoke-Test', 'Test-Debug', 'Assert-ContainsStackTrace')
```

See [How to write a PowerShell module manifest](https://learn.microsoft.com/en-us/powershell/scripting/developer/module/how-to-write-a-powershell-module-manifest?view=powershell-7.5) for more information about module manifests.

#### Claco.Powershell.psm1

This file contains top level functions that are usually, but not always, exported when `Import-Module Claco.Powershell` is called.
It is recommended that you keep this file as small as possible, and only include functions or cmdlets that are either generic in nature, or difficult to categorize with other functions or cmdlets.

By default, only module members exported using `Export-ModuleMember` are available when the file is imported using `Import-Module`:

```powershell
Export-ModuleMember -Function Initialize-WorkspaceRepository
Export-ModuleMember -Function Invoke-Lint, Invoke-Test
Export-ModuleMember -Function Publish-WorkspaceModule
```

Any functions or cmdlets not exported specifically will not be available outside of the current file scope.

#### Claco.Powershell.Tests.ps1

This is the `Pester` tests file for the primary module code, and follows the [Pester file placement and naming](https://pester.dev/docs/usage/file-placement-and-naming) conventions.

Because we're following consistent file naming conventions, it's easy to write generic module import logic in tests that is more resilient to file renames and code reorganization:

```powershell
# Claco.Powershell.Tests.ps1 › Claco.Powershell.psm1 | Import-Module
BeforeAll {
    Import-Module $PSCommandPath.Replace('.Tests.ps1', '.psm1')
}
```

This has the added benefit that you are testing your `.psm1` module exports, and not relying on any accidental global loading of the entire module under test.
Functions or cmdlets not exported will effectively be "private" and will not be seen in tests by default unless you use `InModuleScope`.

#### Miscellaneous Folders

While you *may* choose to organize your code in various ways, this project organizes like-minded functions into files and folders named in ways that make code reorganization easier as the project grows.

You can also use `.ps1` files or truly nested modules using `.psd1/psm1` files in sub folders matching their names:

```powershell
  # Organize like-minded module members in sub folders named the same
  # Each .psm1 file has a corresponding .Tests.ps1 file
  NestedModules        = @(
    '.\Examples\Examples.psm1'
    '.\Testing\Testing.psm1'
    '.\Utilities\Utilities.psm1'
  )

  # This would also work:
  # Each .ps1 file has a corresponding .Tests.ps1 file
  NestedModules        = @(
    '.\Examples.ps1'
    '.\Testing.ps1'
    '.\Utilities.ps1'
  )

  # Support for nesting and publishing:
  # Each .psd1 has a corresponding .psm1 or .ps1 file *and* a .Tests.ps1 file
  # Each folder can also be published using Publish-Module -Path .\Utilities\
  NestedModules        = @(
    '.\Examples\Examples.psm1'
    '.\Testing\Testing.psm1'
    '.\Utilities\Utilities.psm1'
  )
```

## Function Style Guide

The functions in this module follow a simple format following a few basic stylistic preferences:

### Function Layout

- always declare functions using the `CmdLetBindingAttribute`
- put all logic in a `try/catch/finally` statements
- start with `Write-DebugFunctionStart` before any logic
- call `Write-DebugFunctionEnd` in `finally`
- writes exception errors and stack traces to the `Warning` stream by default
- exports the function when `Import-Module` is called

```powershell
function Invoke-Example {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([void])]
  param ()

  try {
    Write-DebugFunctionStart

    Write-Debug "ConfirmPreference=$ConfirmPreference"
    Write-Debug "WhatIfPreference=$WhatIfPreference"

    if ($PSCmdlet.ShouldProcess('Invoke-Example', 'Call')) {
        Write-Host 'Running example...'
    }
  } catch {
    Write-Exception
  } finally {
    Write-DebugFunctionEnd
  }

  return
}

Export-ModuleMember -Function Invoke-Example
```

### Error Handling

By default, exceptions are caught in `catch` blocks,  and `Write-Exception` writes the non-terminating error message and stack trace to the `Warning` stream using `Write-Warning`.

```powershell
Invoke-SimpleExample
WARNING: ┈┈ Exception StackTrace ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈
WARNING: The term 'Test-Debug' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
WARNING: at Invoke-SimpleExample, ./Modules/Claco.Powershell/Examples/Examples.psm1: line 52
at <ScriptBlock>, <No file>: line 1
WARNING: ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈
```

You can write exceptions as an `ErrorRecord` to the `Error` stream instead by setting `$ExceptionActionPreference` to anything other than `Continue` or `SilentlyContinue`, or passing the `-ExceptionAction` parameter to `Write-Exception` with the desired value:

```powershell
$ExceptionActionPreference = 'Stop'
Invoke-SimpleExample
Write-Error: The term 'Test-Debug' is not recognized as a name of a cmdlet, function, script file, or executable program. Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
```

_The value in `$ExceptionActionPreference` is passed to the `-ErrorAction` parameter when calling `Write-Error`._

### Writing Output

Generally, this module recommends the following strategy for deciding on when to write information using `Write-Host`, `Write-Verbose`, or `Write-Debug`:

- use `Write-Host` or `Write-Information` to communicate basic function information like action requested, action result, and outcome. This should be the minimal output displayed in ci job output for readability.
    - "performing action x..."
    - "action successful" / "skipped"
    - "n things successfully processed"

- use `Write-Verbose` when you want to communicate extra information about why decisions were made, actions skipped, and other additional information to aid the reader in determining why some action happened.
    - "item already exists but -Force specified, deleting item"

- use `Write-Debug` when you want to communicate the value of important variables or settings to aid in troubleshooting technical issues
    - "MySetting='$MySetting'"

- use `Write-Warning` when you want to communicate unexpected state or other non fatal issues
    - "folder nod found. recreating path"

#### `Write-Host` vs. `Write-Information`

In modern Powershell, `Write-Host` writes to the same `Information` stream as `Write-Information` so there's no reason you can't use it.
`Write-Host` has the added benefit that it supports `-NoNewLine`, `-ForeGroundColor`, and other options not available in `Write-Information` that make writing colored, more dynamic messages easier.
`Write-Host` also happens irrespective of what `$InformationPreference` is set to.

Whatever you choose, be consistent. This project has opted to always use `Write-Host` internally, and sets `$InformationPreference` to `Continue` for consistent output and behavior in CI and other environments.

### Using `-Debug`, `-Verbose`, `-WhatIf`, `-Confirm`

This project recommends that you define rules about when you should and should not pass preference variables to functions you call within your own functions and cmdlets. This is especially important with `-WhatIf` and `-Confirm`, which control the flow of anything supporting `ShouldProcess`, and avoiding unintended actions when `-WhatIf` is requested.

```powershell
# Invoke-ApiRequest -Verbose
function Invoke-ApiRequest {
  [CmdletBinding()]
  param ()

  try {
    Write-DebugFunctionStart

    $IsDebug = Test-Debug
    $IsVerbose = Test-Verbose

    Initialize-Feed -Uri 'https://blogs.msdn.microsoft.com/powershell/feed/' -Verbose:$IsVerbose -Debug:$IsDebug -WhatIf:$WhatIfPreference -Confirm:$false
  } catch {
    Write-Exception
  } finally {
    Write-DebugFunctionEnd
  }
}
```
