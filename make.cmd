@echo off

setlocal
FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-list --tags --max-count=1`) DO (
set GIT_COMMIT=%%F
)
if not defined CLC_VERSION set CLC_VERSION=UNKNOWN
echo CLC_VERSION: %CLC_VERSION%
set ldflags="-X 'github.com/hazelcast/hazelcast-commandline-client/internal.GitCommit=%GIT_COMMIT%' -X 'github.com/hazelcast/hazelcast-commandline-client/internal.Version=%CLC_VERSION%' -X 'github.com/hazelcast/hazelcast-go-client/internal.ClientType=CLC' -X 'github.com/hazelcast/hazelcast-go-client/internal.ClientVersion=%CLC_VERSION%'"

REM default target is build
if "%1" == "" (
    goto :build
)

set target_failed=0

call :%1
if errorlevel 1 (
    if not "%target_failed%" == "1" (
        echo Unknown target: %1
    )
)

goto :end

:build
    go-winres make --in windows/winres.json --product-version=%CLC_VERSION% --file-version=%CLC_VERSION%
    go-winres make --in extras/windows/winres.json --product-version=%CLC_VERSION% --file-version=%CLC_VERSION% --out cmd\clc\rsrc
    go build -tags base,hazelcastinternal,hazelcastinternaltest -ldflags %ldflags% -o build\clc.exe ./cmd/clc
    if errorlevel 1 (
        echo Build failed
        set target_failed=1
        exit /b 1
    )
    goto :end

:installer
    call make.cmd build
    ISCC.exe /O%cd%/build /Fhazelcast-clc-setup_%CLC_VERSION%_amd64 /DSourceDir=%cd% %cd%\extras\windows\installer\hazelcast-clc-installer.iss
    if errorlevel 1 (
        echo Building the installer failed
        set target_failed=1
        exit /b 1
    )
    goto :end

:test
    go test -tags base,hazelcastinternal,hazelcastinternaltest -p 1 -v -count 1 ./...
    if errorlevel 1 (
        echo Test failed
        set target_failed=1
        exit /b 1
    )
    goto :end


:end
endlocal
