# Prints every requirement statement in this solution, without its test cases.
#
# Run it with no arguments, on Windows. It looks in spec/requirements under
# the folder above this script, and reads each .feature file only from its
# Feature line to the first keyword after it, so cases can't reach the
# output. Drafts (.draft.feature) aren't approved yet and are skipped.
# Problems are reported by key, never by quoting the file.

$ErrorActionPreference = 'Stop'

try {
    [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
} catch {
    # Some hosts have no console to set this on, and the default still works.
}

function Read-Statement([string] $Path) {
    $keyword = '^(Background|Example|Examples|Rule|Scenario|Scenario Outline|Scenario Template|Scenarios):|^[@#]'
    $step = '^(Given|When|Then|And|But)[ \t]|^\*[ \t]'

    $reader = New-Object System.IO.StreamReader($Path, [System.Text.Encoding]::UTF8)
    try {
        $feature = $false
        $lines = New-Object System.Collections.Generic.List[string]
        while ($null -ne ($raw = $reader.ReadLine())) {
            $line = $raw.Trim()
            if (-not $feature) {
                if ($line -cmatch '^Feature:') { $feature = $true }
                continue
            }
            if ($line -cmatch $keyword) {
                return (($lines -join ' ') -replace '\s+', ' ').Trim()
            }
            # A step before any keyword could be a misplaced case.
            if ($line -cmatch $step) { return '' }
            $lines.Add($line)
        }
        # With no keyword there's no telling where the statement ends.
        return ''
    } finally {
        $reader.Dispose()
    }
}

$solution = Split-Path -Parent $PSScriptRoot
$requirements = Join-Path (Join-Path $solution 'spec') 'requirements'

if (-not (Test-Path -LiteralPath $requirements -PathType Container)) {
    [Console]::Error.WriteLine("No requirements folder at $requirements")
    exit 1
}

$status = 0
foreach ($group in Get-ChildItem -LiteralPath $requirements -Directory | Sort-Object Name) {
    foreach ($file in Get-ChildItem -LiteralPath $group.FullName -Filter '*.feature' -File |
            Where-Object { $_.Name -notlike '*.draft.feature' } | Sort-Object Name) {
        $key = "$($group.Name).$($file.BaseName)"
        $statement = Read-Statement $file.FullName

        if ($statement) {
            [Console]::Out.WriteLine("${key}: $statement")
        } else {
            [Console]::Error.WriteLine("${key}: needs a Feature line, a statement, then a case")
            $status = 1
        }
    }
}

exit $status
