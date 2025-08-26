# Powershell Project

This is an example Powershell module project that can be used as a guide for projects that want to create and
publish Powershell modules.

## Requirements

This project assumes you have Powershell 7 available and is configured to use `pwsh` as the default shell for this project and that you have installed `Pester` and `PSScriptAnalyzer`:

    PS> Install-Module Pester,PSScriptAnalyzer

## Features at a Glance

This project includes a boilerplate Powershell module that includes the following:

- Powershell module auto loading support
- Powershell testing with Pester
- Powershell linting with PSScriptAnalyzer
- Pre-Commit support, including Pester and PSScriptAnalyzer validation
- Dev Container support in VSCode (Podman or Docker)
- Example functions with VSCode snippets

## Examples

The following examples can be found in `./Modules/Claco.Powershell/Examples/Examples.psm1`:

- **Invoke-SimpleExample**: A simple function demonstrating the use of common parameters.
- **Invoke-PipelineExample**: A simple function demonstrating the use of pipeline processing.

These were created using the Powershell snippets for VsCode included in this project. You can call those while editing
any `.ps1`, or `.psm1` file:

    cmdlet-simple<TAB>
    cmdlet-pipeline<TAB>

The examples are not exported by the module by default. To try them out, import the file above, then you can run the commands directly:

    PS> Import-Module ./Modules/Claco.Powershell/Examples/Examples.psm1
    PS> Invoke-SimpleExample
    Running Invoke-SimpleExample...
