## Download and install
Download and install via the [official notes](https://go.dev/doc/install)

## Toolchain setup

```shell
# formatter/import fixer
go install golang.org/x/tools/cmd/goimports@latest

# linter
curl -sSfL https://golangci-lint.run/install.sh | sh -s -- -b $(go env GOPATH)/bin v2.12.2 # or use the recommended installation snippet from: https://golangci-lint.run/docs/welcome/install/local/
```

## VS Code setup

Add the following opinionated setup in your global user settings (Ctrl + Shift + P --> "Preferences: Open User Settings (JSON)")

```json
"go.lintTool": "golangci-lint",
"go.lintOnSave": "package",
"go.useLanguageServer": true,
"gopls": {
"ui.semanticTokens": true
},
"editor.formatOnSave": true,
"go.formatTool": "goimports",
"[go]": {
"editor.formatOnSave": true,
},
"go.testFlags": [
"-v",
// "-race"
],
"go.coverOnSave": false
```