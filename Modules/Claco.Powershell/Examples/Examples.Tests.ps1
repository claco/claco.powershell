BeforeAll {
    Import-Module $PSCommandPath.Replace('.Tests.ps1', '.psm1') -Force

    Import-Module $PSCommandPath\..\..\Testing\Testing.psm1 -Force
}

Describe 'Invoke-SimpleExample' {
    BeforeEach {
        $ConfirmPreference = 'None'
    }

    It 'Returns nothing' {
        Invoke-SimpleExample | Should -Be $null
    }
}

Describe 'Invoke-PipelineExample' {
    It 'Returns PSCustomObject for $PWD that exists' {
        # this is possible in Pester v6
        # $Result = [PSCustomObject]@{
        #     Input  = "$PWD"
        #     Path   = "$PWD"
        #     Exists = $true
        # }

        # Invoke-PipelineExample | Should -Be $Result

        $Result = Invoke-PipelineExample 6>$null

        $Result.Input | Should -Be "$PWD"
        $Result.Path | Should -Be "$PWD"
        $Result.Exists | Should -BeTrue
    }

    It 'Returns PSCustomObject for -Path that does not exist' {
        # this is possible in Pester v6
        # Invoke-PipelineExample -Path 'DoesNotExist' | Should -Be $Result

        $Path = 'DoesNotExist'
        $Result = Invoke-PipelineExample -Path $Path 6>$null

        $Result.Input | Should -Be $Path
        $Result.Path | Should -Be $(Join-Path -Path $PWD -ChildPath $Path)
        $Result.Exists | Should -BeFalse
    }
}
