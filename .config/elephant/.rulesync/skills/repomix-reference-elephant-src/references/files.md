# Files

## File: .github/workflows/build.yml

```yaml
name: Build Elephant
on:
  push:
    branches: [main, develop]
    tags: ['v*']
  pull_request:
    branches: [main]
permissions:
  contents: write
env:
  GO_VERSION: '1.24.8'
  PROJECT_NAME: 'elephant'
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: ${{ env.GO_VERSION }}
      - name: Install cross-compilation tools
        run: |
          sudo apt-get update
          sudo apt-get install -y gcc-aarch64-linux-gnu libwayland-dev
      - name: Create build directory
        run: mkdir -p build
      - name: Download Go modules
        run: go mod download
      - name: Build elephant for linux/amd64
        run: |
          echo "Building elephant for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -o build/elephant-linux-amd64 ./cmd/elephant/elephant.go
      - name: Build desktopapplications plugin for linux/amd64
        run: |
          echo "Building desktopapplications plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/desktopapplications-linux-amd64.so ./internal/providers/desktopapplications
      - name: Build files plugin for linux/amd64
        run: |
          echo "Building files plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/files-linux-amd64.so ./internal/providers/files
      - name: Build clipboard plugin for linux/amd64
        run: |
          echo "Building clipboard plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/clipboard-linux-amd64.so ./internal/providers/clipboard
      - name: Build runner plugin for linux/amd64
        run: |
          echo "Building runner plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/runner-linux-amd64.so ./internal/providers/runner
      - name: Build symbols plugin for linux/amd64
        run: |
          echo "Building symbols plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/symbols-linux-amd64.so ./internal/providers/symbols
      - name: Build calc plugin for linux/amd64
        run: |
          echo "Building calc plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/calc-linux-amd64.so ./internal/providers/calc
      - name: Build providerlist plugin for linux/amd64
        run: |
          echo "Building providerlist plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/providerlist-linux-amd64.so ./internal/providers/providerlist
      - name: Build menus plugin for linux/amd64
        run: |
          echo "Building menus plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/menus-linux-amd64.so ./internal/providers/menus
      - name: Build websearch plugin for linux/amd64
        run: |
          echo "Building websearch plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/websearch-linux-amd64.so ./internal/providers/websearch
      - name: Build archlinuxpkgs plugin for linux/amd64
        run: |
          echo "Building archlinuxpkgs plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/archlinuxpkgs-linux-amd64.so ./internal/providers/archlinuxpkgs
      - name: Build todo plugin for linux/amd64
        run: |
          echo "Building todo plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/todo-linux-amd64.so ./internal/providers/todo
      - name: Build unicode plugin for linux/amd64
        run: |
          echo "Building unicode plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/unicode-linux-amd64.so ./internal/providers/unicode
      - name: Build bluetooth plugin for linux/amd64
        run: |
          echo "Building bluetooth plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/bluetooth-linux-amd64.so ./internal/providers/bluetooth
      - name: Build windows plugin for linux/amd64
        run: |
          echo "Building windows plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/windows-linux-amd64.so ./internal/providers/windows
      - name: Build snippets plugin for linux/amd64
        run: |
          echo "Building snippets plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/snippets-linux-amd64.so ./internal/providers/snippets
      - name: Build nirisessions plugin for linux/amd64
        run: |
          echo "Building nirisessions plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/nirisessions-linux-amd64.so ./internal/providers/nirisessions
      - name: Build bookmarks plugin for linux/amd64
        run: |
          echo "Building bookmarks plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/bookmarks-linux-amd64.so ./internal/providers/bookmarks
      - name: Build 1password plugin for linux/amd64
        run: |
          echo "Building 1password plugin for linux/amd64..."
          GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -buildmode=plugin -o build/1password-linux-amd64.so ./internal/providers/1password
      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: build/
          retention-days: 7
  release:
    if: startsWith(github.ref, 'refs/tags/')
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Get version
        id: version
        run: echo "VERSION=${GITHUB_REF#refs/tags/}" >> $GITHUB_OUTPUT
      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-artifacts
          path: build/
      - name: Create archives
        run: |
          echo "Creating archives..."
          cd build
          # Archive main elephant binaries
          tar -czf elephant-linux-amd64.tar.gz elephant-linux-amd64
          # Archive desktopapplications plugin
          tar -czf desktopapplications-linux-amd64.tar.gz desktopapplications-linux-amd64.so
          # Archive files plugin
          tar -czf files-linux-amd64.tar.gz files-linux-amd64.so
          # Archive clipboard plugin
          tar -czf clipboard-linux-amd64.tar.gz clipboard-linux-amd64.so
          # Archive runner plugin
          tar -czf runner-linux-amd64.tar.gz runner-linux-amd64.so
          # Archive symbols plugin
          tar -czf symbols-linux-amd64.tar.gz symbols-linux-amd64.so
          # Archive calc plugin
          tar -czf calc-linux-amd64.tar.gz calc-linux-amd64.so
          # Archive providerlist plugin
          tar -czf providerlist-linux-amd64.tar.gz providerlist-linux-amd64.so
          # Archive menus plugin
          tar -czf menus-linux-amd64.tar.gz menus-linux-amd64.so
          # Archive websearch plugin
          tar -czf websearch-linux-amd64.tar.gz websearch-linux-amd64.so
          # Archive archlinuxpkgs plugin
          tar -czf archlinuxpkgs-linux-amd64.tar.gz archlinuxpkgs-linux-amd64.so
          # Archive todo plugin
          tar -czf todo-linux-amd64.tar.gz todo-linux-amd64.so
          # Archive unicode plugin
          tar -czf unicode-linux-amd64.tar.gz unicode-linux-amd64.so
          # Archive bluetooth plugin
          tar -czf bluetooth-linux-amd64.tar.gz bluetooth-linux-amd64.so
          # Archive windows plugin
          tar -czf windows-linux-amd64.tar.gz windows-linux-amd64.so
          # Archive snippets plugin
          tar -czf snippets-linux-amd64.tar.gz snippets-linux-amd64.so
          # Archive nirisessions plugin
          tar -czf nirisessions-linux-amd64.tar.gz nirisessions-linux-amd64.so
          # Archive bookmarks plugin
          tar -czf bookmarks-linux-amd64.tar.gz bookmarks-linux-amd64.so
          # Archive 1password plugin
          tar -czf 1password-linux-amd64.tar.gz 1password-linux-amd64.so
          echo "Build completed successfully!"
          echo "Created archives:"
          ls -la *.tar.gz
      - name: Generate changelog
        run: |
          # Get previous tag
          PREV_TAG=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo "")
          # Generate changelog
          echo "# Changes in ${{ steps.version.outputs.VERSION }}" > CHANGELOG.md
          echo "" >> CHANGELOG.md
          if [ -n "$PREV_TAG" ]; then
            echo "## Commits since $PREV_TAG:" >> CHANGELOG.md
            git log --pretty=format:"- %s (%h)" $PREV_TAG..HEAD >> CHANGELOG.md
          else
            echo "## All commits:" >> CHANGELOG.md
            git log --pretty=format:"- %s (%h)" >> CHANGELOG.md
          fi
          if [ -f "BREAKING.md" ]; then
            echo "" >> CHANGELOG.md
            echo "## ⚠️ Breaking Changes" >> CHANGELOG.md
            echo "" >> CHANGELOG.md
            cat BREAKING.md >> CHANGELOG.md
            echo "" >> CHANGELOG.md
          fi
      - name: Create Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ steps.version.outputs.VERSION }}
          name: Release ${{ steps.version.outputs.VERSION }}
          body_path: CHANGELOG.md
          draft: false
          prerelease: ${{ contains(steps.version.outputs.VERSION, 'beta') || contains(steps.version.outputs.VERSION, 'alpha') || contains(steps.version.outputs.VERSION, 'rc') }}
          files: build/*.tar.gz
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## File: .github/workflows/github-releases-to-discord.yml

```yaml
on:
  release:
    types: [published]
jobs:
  github-releases-to-discord:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: GitHub Releases to Discord
        uses: SethCohen/github-releases-to-discord@v1
        with:
          webhook_url: ${{ secrets.WEBHOOK_URL }}
          color: '2105893'
          username: 'Release Changelog'
          avatar_url: 'https://cdn.discordapp.com/avatars/487431320314576937/bd64361e4ba6313d561d54e78c9e7171.png'
          content: '||@everyone||'
          footer_title: 'Changelog'
          reduce_headings: true
```

## File: .github/workflows/update-vendor-hash.yml

```yaml
name: Update Vendor Hash
on:
  workflow_dispatch:
  push:
    paths:
      - 'go.mod'
      - 'go.sum'
jobs:
  update-vendor-hash:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      - name: Install Nix
        uses: cachix/install-nix-action@v31
      - name: Update vendor hash
        run: |
          nix run nixpkgs#nix-update -- --flake --version=skip elephant 
          nix run nixpkgs#nix-update -- --flake --version=skip elephant-providers
      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v6
        with:
          commit-message: 'chore(nix): update vendor hash'
          title: 'Update vendor hash'
          body: 'Automated vendor hash update'
          branch: update-vendor-hash
          delete-branch: true
```

## File: .github/changelog_config.json

```json
{
  "categories": [
    {
      "title": "## 🚀 Features",
      "labels": [
        "feature",
        "enhancement",
        "feat",
        "desktopapplications",
        "files",
        "setup",
        "query",
        "comm"
      ]
    },
    {
      "title": "## 🐛 Bug Fixes",
      "labels": ["bug", "bugfix", "fix"]
    },
    {
      "title": "## 🧰 Maintenance",
      "labels": ["maintenance", "chore", "deps"]
    },
    {
      "title": "## 📝 Documentation",
      "labels": ["documentation", "docs", "readme"]
    },
    {
      "title": "## 💥 Breaking Changes",
      "labels": ["breaking", "breaking-change"]
    }
  ],
  "ignore_labels": ["ignore-for-release"],
  "sort": {
    "order": "ASC",
    "on_property": "mergedAt"
  },
  "template": "#{{CHANGELOG}}\n\n<details>\n<summary>Uncategorized</summary>\n\n#{{UNCATEGORIZED}}\n</details>",
  "pr_template": "- #{{TITLE}} by @#{{AUTHOR}} in ##{{NUMBER}}",
  "empty_template": "- No changes",
  "label_extractor": [
    {
      "pattern": "(.)\\s*:\\s*(.*)",
      "target": "$1",
      "flags": "gu"
    },
    {
      "pattern": "\\[Issue\\]",
      "target": "bug"
    }
  ],
  "duplicate_filter": {
    "pattern": "\\[ABC-....\\]",
    "on_property": "title",
    "method": "match"
  },
  "transformers": [
    {
      "pattern": "[\\-\\*] (\\[(...|TEST|CI|SKIP)\\])( )?(.+?)\n(.+?[\\-\\*] )(.+)",
      "target": "- $4\n  - $6"
    }
  ],
  "max_tags_to_fetch": 200,
  "max_pull_requests": 1000,
  "max_back_track_time_days": 365,
  "exclude_merge_branches": ["Owner/qa"],
  "tag_resolver": {
    "method": "semver"
  },
  "base_branches": ["main", "master"]
}
```

## File: .github/FUNDING.yml

```yaml
github: [abenz1267]
ko_fi: andrejbenz
```

## File: assets/elephant.service

```
[Unit]
Description=Elephant
After=graphical-session.target

[Service]
Type=simple
ExecStart=elephant
Restart=on-failure

[Install]
WantedBy=graphical-session.target
```

## File: cmd/elephant/elephant.go

```go
package main
import (
	"context"
	_ "embed"
	"fmt"
	"log"
	"log/slog"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"syscall"
	"time"
	"github.com/abenz1267/elephant/v2/internal/comm"
	"github.com/abenz1267/elephant/v2/internal/comm/client"
	"github.com/abenz1267/elephant/v2/internal/install"
	"github.com/abenz1267/elephant/v2/internal/providers"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/adrg/xdg"
	"github.com/urfave/cli/v3"
)
⋮----
"context"
_ "embed"
"fmt"
"log"
"log/slog"
"os"
"os/exec"
"os/signal"
"path/filepath"
"syscall"
"time"
"github.com/abenz1267/elephant/v2/internal/comm"
"github.com/abenz1267/elephant/v2/internal/comm/client"
"github.com/abenz1267/elephant/v2/internal/install"
"github.com/abenz1267/elephant/v2/internal/providers"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/adrg/xdg"
"github.com/urfave/cli/v3"
⋮----
//go:embed version.txt
var version string
func main()
func runBeforeCommands()
```

## File: internal/comm/client/activate.go

```go
// Package client provides simple functions to communicate with the socket.
package client
import (
	"bytes"
	"encoding/binary"
	"encoding/json"
	"net"
	"strings"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
"bytes"
"encoding/binary"
"encoding/json"
"net"
"strings"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
func Activate(data string)
⋮----
var buffer bytes.Buffer
```

## File: internal/comm/client/common.go

```go
package client
const (
	done  = 255
	empty = 254
)
```

## File: internal/comm/client/menu.go

```go
package client
import (
	"bytes"
	"encoding/binary"
	"encoding/json"
	"net"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
"bytes"
"encoding/binary"
"encoding/json"
"net"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
func RequestMenu(menu string)
⋮----
var buffer bytes.Buffer
```

## File: internal/comm/client/providerstate.go

```go
// Package client provides simple functions to communicate with the socket.
package client
import (
	"bufio"
	"bytes"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"io"
	"net"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
"bufio"
"bytes"
"encoding/binary"
"encoding/json"
"fmt"
"io"
"net"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
func ProviderState(data string, j bool)
⋮----
var buffer bytes.Buffer
```

## File: internal/comm/client/query.go

```go
// Package client provides simple functions to communicate with the socket.
package client
import (
	"bufio"
	"bytes"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
"bufio"
"bytes"
"encoding/binary"
"encoding/json"
"fmt"
"io"
"log/slog"
"net"
"os"
"path/filepath"
"strconv"
"strings"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
var socket string
func init()
func Query(data string, async, j bool)
⋮----
var buffer bytes.Buffer
```

## File: internal/comm/handlers/activationrequesthandler.go

```go
package handlers
import (
	"bytes"
	"encoding/binary"
	"encoding/json"
	"log/slog"
	"net"
	"strings"
	"github.com/abenz1267/elephant/v2/internal/providers"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
	"google.golang.org/protobuf/proto"
)
⋮----
"bytes"
"encoding/binary"
"encoding/json"
"log/slog"
"net"
"strings"
"github.com/abenz1267/elephant/v2/internal/providers"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
"google.golang.org/protobuf/proto"
⋮----
type ActivateRequest struct{}
func (a *ActivateRequest) Handle(format uint8, cid uint32, conn net.Conn, data []byte)
⋮----
var buffer bytes.Buffer
```

## File: internal/comm/handlers/common.go

```go
package handlers
import (
	"bytes"
	"net"
)
⋮----
"bytes"
"net"
⋮----
func writeStatus(status int, conn net.Conn) (bool, error)
⋮----
var buffer bytes.Buffer
```

## File: internal/comm/handlers/menurequesthandler.go

```go
package handlers
import (
	"encoding/json"
	"fmt"
	"log/slog"
	"net"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
	"google.golang.org/protobuf/proto"
)
⋮----
"encoding/json"
"fmt"
"log/slog"
"net"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
"google.golang.org/protobuf/proto"
⋮----
type MenuRequest struct{}
func (a *MenuRequest) Handle(format uint8, cid uint32, conn net.Conn, data []byte)
```

## File: internal/comm/handlers/queryrequesthandler.go

```go
package handlers
import (
	"bytes"
	"context"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"log/slog"
	"net"
	"slices"
	"strings"
	"sync"
	"sync/atomic"
	"time"
	"github.com/abenz1267/elephant/v2/internal/providers"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
	"google.golang.org/protobuf/proto"
)
⋮----
"bytes"
"context"
"encoding/binary"
"encoding/json"
"fmt"
"log/slog"
"net"
"slices"
"strings"
"sync"
"sync/atomic"
"time"
"github.com/abenz1267/elephant/v2/internal/providers"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
"google.golang.org/protobuf/proto"
⋮----
const (
	QueryDone          = 255
	QueryNoResults     = 254
	StatusDone         = 253
	QueryItem          = 0
	QueryAsyncItem     = 1
	ActivationFinished = 2
	ProviderState      = 3
)
var (
	queries                          = make(map[uint32]context.CancelFunc)
type QueryRequest struct{}
func UpdateItem(format uint8, query string, conn net.Conn, item *pb.QueryResponse_Item)
⋮----
var b []byte
var err error
⋮----
var buffer bytes.Buffer
⋮----
func (h *QueryRequest) Handle(format uint8, cid uint32, conn net.Conn, data []byte)
⋮----
var mut sync.Mutex
var wg sync.WaitGroup
⋮----
func sortEntries(a *pb.QueryResponse_Item, b *pb.QueryResponse_Item) int
```

## File: internal/comm/handlers/staterequesthandler.go

```go
package handlers
import (
	"bytes"
	"encoding/binary"
	"encoding/json"
	"log/slog"
	"net"
	"strings"
	"github.com/abenz1267/elephant/v2/internal/providers"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
	"google.golang.org/protobuf/proto"
)
⋮----
"bytes"
"encoding/binary"
"encoding/json"
"log/slog"
"net"
"strings"
"github.com/abenz1267/elephant/v2/internal/providers"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
"google.golang.org/protobuf/proto"
⋮----
type StateRequest struct{}
func (a *StateRequest) Handle(format uint8, cid uint32, conn net.Conn, data []byte)
⋮----
var b []byte
var err error
⋮----
var buffer bytes.Buffer
```

## File: internal/comm/handlers/subscriberequesthandler.go

```go
// Package handlers providers all the communication handlers
package handlers
import (
	"bytes"
	"encoding/binary"
	"encoding/json"
	"log/slog"
	"net"
	"slices"
	"strings"
	"sync"
	"sync/atomic"
	"time"
	"github.com/abenz1267/elephant/v2/internal/providers"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
	"google.golang.org/protobuf/proto"
)
⋮----
"bytes"
"encoding/binary"
"encoding/json"
"log/slog"
"net"
"slices"
"strings"
"sync"
"sync/atomic"
"time"
"github.com/abenz1267/elephant/v2/internal/providers"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
"google.golang.org/protobuf/proto"
⋮----
type SubscribeRequest struct{}
func (a *SubscribeRequest) Handle(format uint8, cid uint32, conn net.Conn, data []byte)
var (
	sid             atomic.Uint32
	subs            map[uint32]*sub
	ProviderUpdated chan string
	mut             sync.Mutex
)
const (
	SubscriptionDataChanged = 0
	SubscriptionHealthCheck = 230
)
type sub struct {
	format   uint8
	sid      uint32
	interval int
	provider string
	query    string
	results  []*pb.QueryResponse_Item
	conn     net.Conn
}
func init()
⋮----
// go checkHealth()
// handle general realtime subs
⋮----
func subscribe(format uint8, interval int, provider, query string, conn net.Conn)
func watch(format uint8, s *sub, conn net.Conn)
⋮----
// check if result is different in length
⋮----
// check if result is different in content
⋮----
func updated(format uint8, conn net.Conn, value string) bool
⋮----
var b []byte
var err error
⋮----
var buffer bytes.Buffer
⋮----
func equals(a *pb.QueryResponse_Item, b *pb.QueryResponse_Item) bool
```

## File: internal/comm/comm.go

```go
// Package comm provides functionallity to communitate with elephant
package comm
import (
	"encoding/binary"
	"io"
	"log/slog"
	"net"
	"os"
	"path/filepath"
	"github.com/abenz1267/elephant/v2/internal/comm/handlers"
)
⋮----
"encoding/binary"
"io"
"log/slog"
"net"
"os"
"path/filepath"
"github.com/abenz1267/elephant/v2/internal/comm/handlers"
⋮----
// connection id
var (
	cid    uint32
	Socket string
)
var registry []MessageHandler
type MessageHandler interface {
	Handle(format uint8, cid uint32, conn net.Conn, data []byte)
}
const (
	QueryRequestHandlerPos     = 0
	ActivateRequestHandlerPos  = 1
	SubscribeRequestHandlerPos = 2
	MenuRequestHandlerPos      = 3
	StateRequestHandlerPos     = 4
	Protobuf                   = 0
	JSON                       = 1
)
func init()
func StartListen()
func handle(conn net.Conn, cid uint32)
```

## File: internal/install/install.go

```go
// Package install provides the ability to install menus from elephant-community
package install
import (
	"errors"
	"fmt"
	"io/fs"
	"log/slog"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/adrg/xdg"
)
⋮----
"errors"
"fmt"
"io/fs"
"log/slog"
"os"
"os/exec"
"path/filepath"
"strings"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/adrg/xdg"
⋮----
var repo = filepath.Join(os.TempDir(), "elephant-community")
func Readme(menu string)
func Remove(menus []string)
func List()
func Install(menus []string)
func cloneOrPull() error
func pull(path string) error
func clone() error
```

## File: internal/providers/1password/1password.go

```go
package main
import (
	"encoding/json"
	"log/slog"
	"os/exec"
	"time"
)
⋮----
"encoding/json"
"log/slog"
"os/exec"
"time"
⋮----
type OpItem struct {
	ID                    string `json:"id"`
	Title                 string `json:"title"`
	Category              string `json:"category"`
	AdditionalInformation string `json:"additional_information"`
	Urls                  []struct {
		Href string `json:"href"`
	} `json:"urls"`
func checkAvailable()
func initItems()
⋮----
var items []OpItem
```

## File: internal/providers/1password/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = 1password.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/1password/README.md

````markdown
### Elephant 1Password

Access your 1Password Vaults.

#### Features

- copy password
- clears clipboard after 5 (default) seconds
- notification when copying has been successful

#### Requirements

- `1password`
- `op` (1password CLI)

#### Category icons example (case insensitive)

```toml
[category_icons]
login = "dialog-password-symbolic"
secure_note = "accessories-text-editor-symbolic"
ssh_key = "utilities-terminal-symbolic"
credit_card = "auth-smartcard-symbolic"
identity = "avatar-default-symbolic"
document = "folder-documents-symbolic
```
````

## File: internal/providers/1password/setup.go

```go
package main
import (
	"fmt"
	"log/slog"
	"net"
	"os/exec"
	"strings"
	"time"
	_ "embed"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
"fmt"
"log/slog"
"net"
"os/exec"
"strings"
"time"
_ "embed"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
var (
	Name        = "1password"
	NamePretty  = "1Password"
	config      *Config
	cachedItems []OpItem
)
//go:embed README.md
var readme string
type Config struct {
	common.Config `koanf:",squash"`
	Vaults        []string          `koanf:"vaults" desc:"vaults to index" default:"[\"personal\"]"`
	Notify        bool              `koanf:"notify" desc:"notify after copying" default:"true"`
	ClearAfter    int               `koanf:"clear_after" desc:"clearboard will be cleared after X seconds. 0 to disable." default:"5"`
	CategoryIcons map[string]string `koanf:"category_icons" desc:"icon mapping by category"`
}
func Setup()
func Available() bool
func PrintDoc()
const (
	ActionCopyPassword = "copy_password"
	ActionCopyUsername = "copy_username"
	ActionCopy2FA      = "copy_2fa"
)
func notifyAndClear()
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
func Query(conn net.Conn, query string, single bool, exact bool, _ uint8) []*pb.QueryResponse_Item
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
```

## File: internal/providers/archlinuxpkgs/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = archlinuxpkgs.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/archlinuxpkgs/package_gen_test.go

```go
// Code generated by github.com/tinylib/msgp DO NOT EDIT.
package main
import (
	"bytes"
	"testing"
	"github.com/tinylib/msgp/msgp"
)
⋮----
"bytes"
"testing"
"github.com/tinylib/msgp/msgp"
⋮----
func TestMarshalUnmarshalCachedData(t *testing.T)
func BenchmarkMarshalMsgCachedData(b *testing.B)
func BenchmarkAppendMsgCachedData(b *testing.B)
func BenchmarkUnmarshalCachedData(b *testing.B)
func TestEncodeDecodeCachedData(t *testing.T)
⋮----
var buf bytes.Buffer
⋮----
func BenchmarkEncodeCachedData(b *testing.B)
func BenchmarkDecodeCachedData(b *testing.B)
func TestMarshalUnmarshalPackage(t *testing.T)
func BenchmarkMarshalMsgPackage(b *testing.B)
func BenchmarkAppendMsgPackage(b *testing.B)
func BenchmarkUnmarshalPackage(b *testing.B)
func TestEncodeDecodePackage(t *testing.T)
func BenchmarkEncodePackage(b *testing.B)
func BenchmarkDecodePackage(b *testing.B)
```

## File: internal/providers/archlinuxpkgs/package_gen.go

```go
// Code generated by github.com/tinylib/msgp DO NOT EDIT.
package main
import (
	"github.com/tinylib/msgp/msgp"
)
⋮----
"github.com/tinylib/msgp/msgp"
⋮----
// DecodeMsg implements msgp.Decodable
func (z *CachedData) DecodeMsg(dc *msgp.Reader) (err error)
⋮----
var field []byte
⋮----
var zb0001 uint32
⋮----
var zb0002 uint32
⋮----
var za0001 string
⋮----
var za0002 Package
⋮----
// EncodeMsg implements msgp.Encodable
func (z *CachedData) EncodeMsg(en *msgp.Writer) (err error)
⋮----
// map header, size 1
// write "Packages"
⋮----
// MarshalMsg implements msgp.Marshaler
func (z *CachedData) MarshalMsg(b []byte) (o []byte, err error)
⋮----
// string "Packages"
⋮----
// UnmarshalMsg implements msgp.Unmarshaler
func (z *CachedData) UnmarshalMsg(bts []byte) (o []byte, err error)
// Msgsize returns an upper bound estimate of the number of bytes occupied by the serialized message
func (z *CachedData) Msgsize() (s int)
⋮----
// map header, size 14
// write "Name"
⋮----
// write "Description"
⋮----
// write "Repository"
⋮----
// write "Version"
⋮----
// write "Installed"
⋮----
// write "FullInfo"
⋮----
// write "URL"
⋮----
// write "URLPath"
⋮----
// write "Maintainer"
⋮----
// write "Submitter"
⋮----
// write "NumVotes"
⋮----
// write "Popularity"
⋮----
// write "FirstSubmitted"
⋮----
// write "LastModified"
⋮----
// string "Name"
⋮----
// string "Description"
⋮----
// string "Repository"
⋮----
// string "Version"
⋮----
// string "Installed"
⋮----
// string "FullInfo"
⋮----
// string "URL"
⋮----
// string "URLPath"
⋮----
// string "Maintainer"
⋮----
// string "Submitter"
⋮----
// string "NumVotes"
⋮----
// string "Popularity"
⋮----
// string "FirstSubmitted"
⋮----
// string "LastModified"
```

## File: internal/providers/archlinuxpkgs/package.go

```go
package main
//go:generate msgp
type CachedData struct {
	Packages map[string]Package
}
func newCachedData() CachedData
⋮----
type Package struct {
	Name           string
	Description    string
	Repository     string
	Version        string
	Installed      bool
	FullInfo       string
	URL            string
	URLPath        string
	Maintainer     string
	Submitter      string
	NumVotes       int
	Popularity     float64
	FirstSubmitted int64
	LastModified   int64
}
```

## File: internal/providers/archlinuxpkgs/README.md

```markdown
### Elephant Archlinux Packages

Find, install and delete packages. Including AUR.

#### Features

- find official packages
- find AUR packages
- install packages
- list all exclusively installed packages
- remove packages
- clear all done items

#### Requirements

- `yay` or `paru` for AUR
```

## File: internal/providers/archlinuxpkgs/setup.go

```go
package main
import (
	"bytes"
	"compress/gzip"
	_ "embed"
	"encoding/json"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/exec"
	"runtime/debug"
	"slices"
	"strings"
	"time"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
	"github.com/tinylib/msgp/msgp"
)
⋮----
"bytes"
"compress/gzip"
_ "embed"
"encoding/json"
"fmt"
"log/slog"
"net"
"net/http"
"os"
"os/exec"
"runtime/debug"
"slices"
"strings"
"time"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
"github.com/tinylib/msgp/msgp"
⋮----
var (
	Name          = "archlinuxpkgs"
	NamePretty    = "Arch Linux Packages"
	config        *Config
	installed     = []string{}
	installedOnly = false
	cacheFile     = common.CacheFile("archlinuxpkgs.json")
//go:embed README.md
var readme string
const (
	ActionInstall       = "install"
	ActionClearCache    = "clear_cache"
	ActionVisitURL      = "visit_url"
	ActionRefresh       = "refresh"
	ActionRemove        = "remove"
	ActionShowInstalled = "show_installed"
	ActionShowAll       = "show_all"
)
type Config struct {
	common.Config        `koanf:",squash"`
	CommandInstall       string `koanf:"command_install" desc:"default command for AUR packages to install. supports %VALUE%." default:"yay -S %VALUE%"`
	CommandRemove        string `koanf:"command_remove" desc:"default command to remove packages. supports %VALUE%." default:"sudo pacman -R %VALUE%"`
	AutoWrapWithTerminal bool   `koanf:"auto_wrap_with_terminal" desc:"automatically wraps the command with terminal" default:"true"`
}
type AURPackage struct {
	Name           string  `json:"name,omitempty"`
	Description    string  `json:"description,omitempty"`
	Version        string  `json:"version,omitempty"`
	URL            string  `json:"url,omitempty"`
	URLPath        string  `json:"url_path,omitempty"`
	Maintainer     string  `json:"maintainer,omitempty"`
	Submitter      string  `json:"submitter,omitempty"`
	NumVotes       int     `json:"num_votes,omitempty"`
	Popularity     float64 `json:"popularity,omitempty"`
	FirstSubmitted int64   `json:"first_submitted,omitempty"`
	LastModified   int64   `json:"last_modified,omitempty"`
}
func (a AURPackage) toFullInfo() string
⋮----
var b strings.Builder
⋮----
func detectHelper() string
var cacheChan = make(chan struct{})
func clearCache()
func Setup()
func setup()
⋮----
var b bytes.Buffer
⋮----
func freeMem()
func Available() bool
func PrintDoc()
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
⋮----
var pkgcmd string
⋮----
func Query(conn net.Conn, query string, single bool, exact bool, _ uint8) []*pb.QueryResponse_Item
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
func getOfficialPkgs()
⋮----
var data strings.Builder
⋮----
func setupAURPkgs()
⋮----
var aurPackages []AURPackage
⋮----
func getInstalled()
```

## File: internal/providers/bluetooth/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = bluetooth.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/bluetooth/README.md

```markdown
### Elephant Bluetooth

Simple bluetooth management. Connect/Disconnect. Pair/Remove. Trust/Untrust.

#### Requirements

- `bluetoothctl`
```

## File: internal/providers/bluetooth/setup.go

```go
// Package symbols provides symbols/emojis.
package main
import (
	"fmt"
	"log/slog"
	"net"
	"os/exec"
	"strings"
	"time"
	_ "embed"
	"github.com/abenz1267/elephant/v2/internal/comm/handlers"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
"fmt"
"log/slog"
"net"
"os/exec"
"strings"
"time"
_ "embed"
"github.com/abenz1267/elephant/v2/internal/comm/handlers"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
var (
	Name       = "bluetooth"
	NamePretty = "Bluetooth"
	find       = false
)
//go:embed README.md
var readme string
type Config struct {
	common.Config `koanf:",squash"`
}
type Device struct {
	Name      string
	Mac       string
	Icon      string
	Paired    bool
	Trusted   bool
	Connected bool
}
var devices []Device
var config *Config
func Setup()
func Available() bool
func PrintDoc()
const (
	ActionDisconnect = "disconnect"
	ActionConnect    = "connect"
	ActionRemove     = "remove"
	ActionPair       = "pair"
	ActionTrust      = "trust"
	ActionUntrust    = "untrust"
	ActionFind       = "find"
)
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
func Query(conn net.Conn, query string, _ bool, exact bool, _ uint8) []*pb.QueryResponse_Item
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
func getDevices()
```

## File: internal/providers/bookmarks/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = bookmarks.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/bookmarks/README.md

````markdown
### Elephant Bookmarks

URL bookmark manager

#### Features

- create / remove bookmarks
- import bookmarks from installed browsers
- cycle through categories
- customize browsers and set per-bookmark browser
- git integration (requires ssh access)

#### Requirements

- `jq` for importing from chromium based browsers
- `sqlite3` for importing from firefox based browsers

#### Git Integration

You can set

```toml
location = "https://github.com/abenz1267/elephantbookmarks"
```

This will automatically try to clone/pull the repo. It will also automatically comimt and push on changes.

#### Usage

##### Adding a new bookmark

By default, you can create a new bookmark whenever no items match the configured `min_score` threshold. If you want to, you can also configure `create_prefix`, f.e. `add`. In that case you can do `add:bookmark`.

URLs without `http://` or `https://` will automatically get `https://` prepended.

Examples:

```
example.com                       -> https://example.com
github.com GitHub                 -> https://github.com (with title "Github")
add reddit.com Reddit             -> https://reddit.com (with title "Reddit")
w:work-site.com                   -> https://work-site.com (in "work" category)
```

##### Categories

You can organize bookmarks into categories using prefixes:

```toml
[[categories]]
name = "work"
prefix = "w:"

[[categories]]
name = "personal"
prefix = "p:"
```

##### Browsers

You can customize browsers used for opening bookmarks like this:

```toml
[[browsers]]
name = "Zen"
command = "zen-browser"

[[browsers]]
name = "Chromium"
command = "chromium"

[[browsers]]
name = "Chromium App"
command = "chromium --app=%VALUE%"
```
````

## File: internal/providers/bookmarks/setup.go

```go
package main
import (
	_ "embed"
	"fmt"
	"log/slog"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"
	"al.essio.dev/pkg/shellescape"
	"github.com/abenz1267/elephant/v2/internal/comm/handlers"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/common/history"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
	"github.com/go-git/go-git/v6"
)
⋮----
_ "embed"
"fmt"
"log/slog"
"net"
"os"
"os/exec"
"path/filepath"
"strconv"
"strings"
"sync"
"time"
"al.essio.dev/pkg/shellescape"
"github.com/abenz1267/elephant/v2/internal/comm/handlers"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/common/history"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
"github.com/go-git/go-git/v6"
⋮----
var (
	Name              = "bookmarks"
	NamePretty        = "Bookmarks"
	config            *Config
	bookmarks         = []Bookmark{}
	availableBrowsers = make(map[string]string)
//go:embed README.md
var readme string
type Config struct {
	common.Config      `koanf:",squash"`
	Location           string     `koanf:"location" desc:"location of the CSV file" default:"elephant cache dir"`
	Categories         []Category `koanf:"categories" desc:"categories" default:""`
	Browsers           []Browser  `koanf:"browsers" desc:"browsers for opening bookmarks" default:""`
	SetBrowserOnImport bool       `koanf:"set_browser_on_import" desc:"set browser name on imported bookmarks" default:"false"`
	History            bool       `koanf:"history" desc:"make use of history for sorting" default:"true"`
	HistoryWhenEmpty   bool       `koanf:"history_when_empty" desc:"consider history when query is empty" default:"false"`
	w                  *git.Worktree
	r                  *git.Repository
}
func (config *Config) SetLocation(val string)
func (config *Config) URL() string
func (config *Config) SetWorktree(val *git.Worktree)
func (config *Config) SetRepository(val *git.Repository)
type Category struct {
	Name   string `koanf:"name" desc:"name for category" default:""`
	Prefix string `koanf:"prefix" desc:"prefix to store item in category" default:""`
}
type Browser struct {
	Name    string `koanf:"name" desc:"name of the browser" default:""`
	Command string `koanf:"command" desc:"command to launch the browser" default:""`
	Icon    string `koanf:"icon" desc:"icon to use" default:""`
}
const (
	StateCreating = "creating"
	StateNormal   = "normal"
)
const (
	ActionSave           = "save"
	ActionOpen           = "open"
	ActionDelete         = "delete"
	ActionChangeCategory = "change_category"
	ActionChangeBrowser  = "change_browser"
	ActionImport         = "import"
	ActionCreate         = "create"
	ActionSearch         = "search"
)
type Bookmark struct {
	URL         string
	Description string
	Category    string
	Browser     string
	CreatedAt   time.Time
	Imported    bool
}
func (b Bookmark) toCSVRow() string
func (b *Bookmark) fromCSVRow(row string) error
func (b *Bookmark) fromQuery(query string)
⋮----
// b.URL = strings.ReplaceAll(b.URL, "'", "%27")
⋮----
func saveBookmarks()
var (
	loadMu sync.Mutex
	loaded bool
)
func loadBookmarks()
func Setup()
func Available() bool
func PrintDoc()
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
func store(query string)
type browserInfo struct {
	name        string
	browserType string
	path        string
}
func normalizeURL(url string) string
func discoverBrowsers() []browserInfo
func readChromiumBookmarks(path string) map[string]Bookmark
func readFirefoxBookmarks(path string) map[string]Bookmark
func importBrowserBookmarks()
⋮----
var browserBookmarks map[string]Bookmark
⋮----
func Query(conn net.Conn, query string, single bool, exact bool, _ uint8) []*pb.QueryResponse_Item
⋮----
var highestScore int32
var category Category
⋮----
func bookmarkToEntry(i int, b Bookmark) *pb.QueryResponse_Item
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
func calcScore(q string, d Bookmark, exact bool) (string, int32, []int32, int32, bool)
⋮----
var scoreRes int32
var posRes []int32
var startRes int32
var match string
var modifier int32
```

## File: internal/providers/calc/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = calc.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/calc/README.md

```markdown
### Elephant Calc

Perform calculation and unit-conversions.

#### Features

- save results
- copy results

#### Requirements

- `libqalculate`
- `wl-clipboard`

#### Usage

Refer to the official [libqalculate docs](https://github.com/Qalculate/libqalculate).
```

## File: internal/providers/calc/setup.go

```go
package main
import (
	"bytes"
	"crypto/md5"
	"encoding/gob"
	"encoding/hex"
	"fmt"
	"log/slog"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strings"
	"time"
	"unicode"
	_ "embed"
	"github.com/abenz1267/elephant/v2/internal/comm/handlers"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
"bytes"
"crypto/md5"
"encoding/gob"
"encoding/hex"
"fmt"
"log/slog"
"net"
"os"
"os/exec"
"path/filepath"
"slices"
"strings"
"time"
"unicode"
_ "embed"
"github.com/abenz1267/elephant/v2/internal/comm/handlers"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
var (
	Name       = "calc"
	NamePretty = "Calculator/Unit-Conversion"
	config     *Config
)
//go:embed README.md
var readme string
const (
	ActionCopy   = "copy"
	ActionSave   = "save"
	ActionDelete = "delete"
)
type Config struct {
	common.Config `koanf:",squash"`
	MaxItems      int    `koanf:"max_items" desc:"max amount of calculation history items" default:"100"`
	Placeholder   string `koanf:"placeholder" desc:"placeholder to display for async update" default:"calculating..."`
	RequireNumber bool   `koanf:"require_number" desc:"don't perform if query does not contain a number" default:"true"`
	MinChars      int    `koanf:"min_chars" desc:"don't perform if query is shorter than min_chars" default:"3"`
	Command       string `koanf:"command" desc:"default command to be executed. supports %VALUE%." default:"wl-copy -n %VALUE%"`
	Async         bool   `koanf:"async" desc:"calculation will be send async" default:"true"`
	Autosave      bool   `koanf:"autosave" desc:"automatically save results" default:"false"`
}
type HistoryItem struct {
	Identifier string
	Input      string
	Result     string
}
var history = []HistoryItem{}
func Setup()
⋮----
// this is to update exchange rate data
⋮----
func Available() bool
func PrintDoc()
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
⋮----
var result string
⋮----
func saveToHistory(query, result string)
func Query(conn net.Conn, query string, single bool, _ bool, format uint8) []*pb.QueryResponse_Item
func loadHist()
func saveHist()
⋮----
var b bytes.Buffer
⋮----
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
```

## File: internal/providers/clipboard/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = clipboard.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/clipboard/README.md

```markdown
### Elephant Clipboard

Store clipboard history.

#### Features

- saves images and text history
- filter to show images only
- edit saved content
- localsend support

#### Requirements

- `wl-clipboard`
- `imagemagick`
```

## File: internal/providers/clipboard/setup.go

```go
// Package clipboard provides access to the clipboard history.
package main
import (
	"bufio"
	"bytes"
	"crypto/md5"
	_ "embed"
	"encoding/gob"
	"encoding/hex"
	"encoding/xml"
	"fmt"
	"io/fs"
	"log"
	"log/slog"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strconv"
	"strings"
	"sync"
	"syscall"
	"time"
	"unicode/utf8"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
"bufio"
"bytes"
"crypto/md5"
_ "embed"
"encoding/gob"
"encoding/hex"
"encoding/xml"
"fmt"
"io/fs"
"log"
"log/slog"
"net"
"os"
"os/exec"
"path/filepath"
"slices"
"strconv"
"strings"
"sync"
"syscall"
"time"
"unicode/utf8"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
var (
	Name             = "clipboard"
	NamePretty       = "Clipboard"
	file             = common.CacheFile("clipboard.gob")
//go:embed README.md
var readme string
//go:embed data/UnicodeData.txt
var unicodedata string
//go:embed data/symbols.xml
var symbolsdata string
var (
	paused       bool
	saveFileChan = make(chan struct{})
const StateEditable = "editable"
type Item struct {
	Content string
	Img     string
	Time    time.Time
	State   string
}
type Config struct {
	common.Config  `koanf:",squash"`
	MaxItems       int    `koanf:"max_items" desc:"max amount of clipboard history items" default:"100"`
	ImageEditorCmd string `koanf:"image_editor_cmd" desc:"editor to use for images. use '%FILE%' as placeholder for file path." default:""`
	TextEditorCmd  string `koanf:"text_editor_cmd" desc:"editor to use for text, otherwise default for mimetype. use '%FILE%' as placeholder for file path." default:""`
	Command        string `koanf:"command" desc:"default command to be executed" default:"wl-copy"`
	IgnoreSymbols  bool   `koanf:"ignore_symbols" desc:"ignores symbols/unicode" default:"true"`
	AutoCleanup    int    `koanf:"auto_cleanup" desc:"will automatically cleanup entries entries older than X minutes" default:"0"`
}
func Setup()
func Available() bool
func cleanup()
var symbols = make(map[string]struct{})
type LDML struct {
	XMLName     xml.Name    `xml:"ldml"`
	Identity    Identity    `xml:"identity"`
	Annotations Annotations `xml:"annotations"`
}
type Identity struct {
	Version  Version  `xml:"version"`
	Language Language `xml:"language"`
}
type Version struct {
	Number string `xml:"number,attr"`
}
type Language struct {
	Type string `xml:"type,attr"`
}
type Annotations struct {
	Annotation []Annotation `xml:"annotation"`
}
type Annotation struct {
	CP   string `xml:"cp,attr"`
	Type string `xml:"type,attr,omitempty"`
	Text string `xml:",chardata"`
}
type Symbol struct {
	CP         string
	Searchable []string
}
func setupUnicodeSymbols()
⋮----
// unicode
⋮----
// symbols
var ldml LDML
⋮----
func loadFromFile()
func cleanupImages()
func saveToFile()
⋮----
var b bytes.Buffer
⋮----
func handleChange()
func getClipboardImage() ([]byte, error)
func getClipboardText() (string, error)
var ignoreMimetypes = []string{"x-kde-passwordManagerHint", "text/uri-list"}
func handleSaveToFile()
func updateImage(out []byte)
⋮----
// special treatment for gimp
⋮----
func updateText(text string)
func trim()
func saveImg(b []byte, ext string) string
func PrintDoc()
const (
	ActionPause      = "pause"
	ActionLocalsend  = "localsend"
	ActionUnpause    = "unpause"
	ActionCopy       = "copy"
	ActionEdit       = "edit"
	ActionRemove     = "remove"
	ActionRemoveAll  = "remove_all"
	ActionImagesOnly = "show_images_only"
	ActionTextOnly   = "show_text_only"
	ActionCombined   = "show_combined"
	ImagesOnly = "images_only"
	TextOnly   = "text_only"
	Combined   = "combined"
)
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
⋮----
var path string
⋮----
var run string
⋮----
func Query(conn net.Conn, query string, _ bool, exact bool, _ uint8) []*pb.QueryResponse_Item
func getMimetypes() []string
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
```

## File: internal/providers/desktopapplications/activate.go

```go
package main
import (
	"bytes"
	"encoding/gob"
	"fmt"
	"log/slog"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strings"
	"syscall"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/common/history"
	"github.com/abenz1267/elephant/v2/pkg/common/wlr"
	"github.com/neurlang/wayland/wl"
)
⋮----
"bytes"
"encoding/gob"
"fmt"
"log/slog"
"net"
"os"
"os/exec"
"path/filepath"
"slices"
"strings"
"syscall"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/common/history"
"github.com/abenz1267/elephant/v2/pkg/common/wlr"
"github.com/neurlang/wayland/wl"
⋮----
const (
	ActionPin         = "pin"
	ActionPinUp       = "pinup"
	ActionPinDown     = "pindown"
	ActionUnpin       = "unpin"
	ActionStart       = "start"
	ActionNewInstance = "new_instance"
)
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
func movePin(identifier string, down bool)
⋮----
var newIndex int
⋮----
func pinItem(identifier string)
⋮----
var b bytes.Buffer
⋮----
func appHasWindow(f *DesktopFile) (wl.ProxyId, bool)
```

## File: internal/providers/desktopapplications/doc.go

```go
package main
import (
	"fmt"
	"github.com/abenz1267/elephant/v2/internal/util"
)
⋮----
"fmt"
"github.com/abenz1267/elephant/v2/internal/util"
⋮----
func PrintDoc()
```

## File: internal/providers/desktopapplications/files.go

```go
package main
import (
	"io/fs"
	"log/slog"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"
	"github.com/abenz1267/elephant/v2/internal/comm/handlers"
	"github.com/adrg/xdg"
	"github.com/charlievieth/fastwalk"
	"github.com/fsnotify/fsnotify"
)
⋮----
"io/fs"
"log/slog"
"os"
"path/filepath"
"strings"
"sync"
"time"
"github.com/abenz1267/elephant/v2/internal/comm/handlers"
"github.com/adrg/xdg"
"github.com/charlievieth/fastwalk"
"github.com/fsnotify/fsnotify"
⋮----
var (
	files         map[string]*DesktopFile
	watchedDirs   map[string]bool
	symlinkToReal map[string]string   // this should be [symlink]realfile
	realToSymlink map[string][]string // this should be [realfile][]symlink
	filesMu       sync.RWMutex
	watcherDirsMu sync.RWMutex
	watcher       *fsnotify.Watcher
	regionLocale  = ""
	langLocale    = ""
	dirs          []string
)
⋮----
symlinkToReal map[string]string   // this should be [symlink]realfile
realToSymlink map[string][]string // this should be [realfile][]symlink
⋮----
func loadFiles()
⋮----
var err error
⋮----
func setVars()
func walkFunction(path string, d fs.DirEntry, err error) error
func trackSymlinks(filename string)
⋮----
// for all intents and purposes, filename is the symlink
// targetPath is what it resolves to.
⋮----
// setup two-way tracking
⋮----
func addDirToWatcher(dir string, watchedDirs map[string]bool)
func watchFiles()
func checkSubdirOfXDG(subdir string) bool
func handleFileEvent(event fsnotify.Event)
⋮----
// Handle directory creation to watch new subdirectories
⋮----
// Don't track new subdirs of a dir we are only tracking for origin files
⋮----
func handleFileCreate(path string)
func handleFileUpdate(path string)
func handleFileRemove(path string)
func addNewEntry(path string)
⋮----
// check the file the symlink points to actually exists
// otherwise it'll panic if you point to a location that's invalid
⋮----
func getLocale()
func isSymlink(filename string) (string, bool)
⋮----
if targetPath == filename { // probably not needed, but maybe?
⋮----
func fileExists(path string) bool
```

## File: internal/providers/desktopapplications/hyprland.go

```go
package main
import (
	"bufio"
	"context"
	"fmt"
	"log/slog"
	"net"
	"os"
	"os/exec"
	"strings"
	"time"
)
⋮----
"bufio"
"context"
"fmt"
"log/slog"
"net"
"os"
"os/exec"
"strings"
"time"
⋮----
type Hyprland struct{}
func (Hyprland) GetCurrentWindows() []string
func (Hyprland) GetWorkspace() string
func (c Hyprland) MoveToWorkspace(workspace, initialWMClass string)
```

## File: internal/providers/desktopapplications/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = desktopapplications.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/desktopapplications/niri.go

```go
package main
import (
	"bufio"
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"os/exec"
	"strings"
	"time"
)
⋮----
"bufio"
"context"
"encoding/json"
"fmt"
"log/slog"
"os/exec"
"strings"
"time"
⋮----
type Niri struct{}
type NiriWindow struct {
	AppID string `json:"app_id"`
}
func (Niri) GetCurrentWindows() []string
⋮----
var windows []NiriWindow
⋮----
func (Niri) GetWorkspace() string
type OpenedOrChangedEvent struct {
	WindowOpenedOrChanged *struct {
		Window struct {
			ID     int    `json:"id"`
			AppID  string `json:"app_id"`
			Layout struct {
				PosInScrollingLayout []int `json:"pos_in_scrolling_layout"`
			} `json:"layout"`
func (c Niri) MoveToWorkspace(workspace, initialWMClass string)
⋮----
var e OpenedOrChangedEvent
```

## File: internal/providers/desktopapplications/parser.go

```go
package main
import (
	"bytes"
	"errors"
	"fmt"
	"log/slog"
	"os"
	"slices"
	"strings"
	"unicode"
)
⋮----
"bytes"
"errors"
"fmt"
"log/slog"
"os"
"slices"
"strings"
"unicode"
⋮----
type Data struct {
	NoDisplay      bool
	Hidden         bool
	Terminal       bool
	Action         string
	Exec           string
	Name           string
	Comment        string
	Path           string
	Parent         string
	GenericName    string
	StartupWMClass string
	Icon           string
	Categories     []string
	OnlyShowIn     []string
	NotShowIn      []string
	Keywords       []string
}
func parseFile(path, l, ll string) (*DesktopFile, error)
func parseData(in []byte, l, ll string) Data
var fieldCodes = []string{"%f", "%F", "%u", "%U", "%d", "%D", "%n", "%N", "%i", "%c", "%k", "%v", "%m"}
// parseExec converts an XDG desktop file Exec entry into a slice of strings
// suitable for exec.Command. It handles field codes and proper escaping according
// to the XDG Desktop Entry specification.
// See: https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s07.html
func parseExec(execLine string) (string, error)
⋮----
var (
		parts         []string
		current       strings.Builder
		inQuote       bool
		escaped       bool
		doubleEscaped bool
	)
// Helper to append current token and reset builder
⋮----
// Process each rune in the exec line
⋮----
// Handle double-escaped character
⋮----
// This is a double escape sequence
⋮----
// Handle escaped character
⋮----
// Keep the quotes in the output for shell interpretation
⋮----
// Space outside quotes marks token boundary
⋮----
// Append final token if any
⋮----
// Remove field codes
⋮----
func splitIntoParsebles(in []byte) [][]byte
```

## File: internal/providers/desktopapplications/query.go

```go
package main
import (
	"fmt"
	"log/slog"
	"net"
	"os"
	"slices"
	"strings"
	"time"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/common/history"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
"fmt"
"log/slog"
"net"
"os"
"slices"
"strings"
"time"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/common/history"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
var desktop = os.Getenv("XDG_CURRENT_DESKTOP")
func Query(conn net.Conn, query string, _ bool, exact bool, _ uint8) []*pb.QueryResponse_Item
⋮----
entries := make([]*pb.QueryResponse_Item, 0, len(files)*2) // Estimate for entries + action
⋮----
// check generic
⋮----
var match string
var ok bool
var score int32
var positions []int32
var fs int32
⋮----
var usageScore int32
⋮----
// check actions
⋮----
func calcScore(q string, d *Data, exact bool) (string, int32, []int32, int32, bool)
⋮----
var scoreRes int32
var posRes []int32
var startRes int32
⋮----
var modifier int32
```

## File: internal/providers/desktopapplications/README.md

```markdown
### Elephant Desktop Applications

Run installed desktop applications.

#### Features

- history
- pin items
- alias items
- auto-detect `uwsm`/`app2unit`
```

## File: internal/providers/desktopapplications/setup.go

```go
package main
import (
	"bytes"
	_ "embed"
	"encoding/gob"
	"fmt"
	"log"
	"log/slog"
	"os"
	"regexp"
	"sync"
	"time"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/common/history"
	"github.com/abenz1267/elephant/v2/pkg/common/wlr"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
"bytes"
_ "embed"
"encoding/gob"
"fmt"
"log"
"log/slog"
"os"
"regexp"
"sync"
"time"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/common/history"
"github.com/abenz1267/elephant/v2/pkg/common/wlr"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
type DesktopFile struct {
	Data
	Actions []Data
}
var (
	Name       = "desktopapplications"
	NamePretty = "Desktop Applications"
	h          = history.Load(Name)
type WMIntegration interface {
	GetWorkspace() string
	GetCurrentWindows() []string
	MoveToWorkspace(workspace, initialWMClass string)
}
//go:embed README.md
var readme string
type Config struct {
	common.Config                  `koanf:",squash"`
	LaunchPrefix                   string            `koanf:"launch_prefix" desc:"overrides the default app2unit or uwsm prefix, if set." default:""`
	Locale                         string            `koanf:"locale" desc:"to override systems locale" default:""`
	ActionMinScore                 int               `koanf:"action_min_score" desc:"min score for actions to be shown" default:"20"`
	ShowActions                    bool              `koanf:"show_actions" desc:"include application actions, f.e. 'New Private Window' for Firefox" default:"false"`
	ShowGeneric                    bool              `koanf:"show_generic" desc:"include generic info when show_actions is true" default:"true"`
	ShowActionsWithoutQuery        bool              `koanf:"show_actions_without_query" desc:"show application actions, if the search query is empty" default:"false"`
	History                        bool              `koanf:"history" desc:"make use of history for sorting" default:"true"`
	HistoryWhenEmpty               bool              `koanf:"history_when_empty" desc:"consider history when query is empty" default:"false"`
	OnlySearchTitle                bool              `koanf:"only_search_title" desc:"ignore keywords, comments etc from desktop file when searching" default:"false"`
	IconPlaceholder                string            `koanf:"icon_placeholder" desc:"placeholder icon for apps without icon" default:"applications-other"`
	Aliases                        map[string]string `koanf:"aliases" desc:"setup aliases for applications. Matched aliases will always be placed on top of the list. Example: 'ffp' => '<identifier>'. Check elephant log output when activating an item to get its identifier." default:""`
	Blacklist                      []string          `koanf:"blacklist" desc:"blacklist desktop files from being parsed. Regexp." default:"<empty>"`
	WindowIntegration              bool              `koanf:"window_integration" desc:"will enable window integration, meaning focusing an open app instead of opening a new instance" default:"false"`
	IgnorePinWithWindow            bool              `koanf:"ignore_pin_with_window" desc:"will ignore pinned apps that have an opened window" default:"true"`
	WindowIntegrationIgnoreActions bool              `koanf:"window_integration_ignore_actions" desc:"will ignore the window integration for actions" default:"true"`
	WMIntegration                  bool              `koanf:"wm_integration" desc:"Moves apps to the workspace where they were launched at automatically. Currently Niri only." default:"false"`
	ScoreOpenWindows               bool              `koanf:"score_open_windows" desc:"Apps that have open windows, get their score halved. Requires window_integration." default:"true"`
	SingleInstanceApps             []string          `koanf:"single_instance_apps" desc:"application IDs that don't ever spawn a new window. " default:"[\"discord\"]"`
}
func loadpinned() []string
func Setup()
func Available() bool
func parseRegexp()
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
```

## File: internal/providers/files/activate.go

```go
package main
import (
	"fmt"
	"log/slog"
	"net"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"github.com/abenz1267/elephant/v2/pkg/common"
)
⋮----
"fmt"
"log/slog"
"net"
"os/exec"
"path/filepath"
"strings"
"syscall"
"github.com/abenz1267/elephant/v2/pkg/common"
⋮----
const (
	ActionOpen      = "open"
	ActionOpenDir   = "opendir"
	ActionCopyPath  = "copypath"
	ActionCopyFile  = "copyfile"
	ActionLocalsend = "localsend"
	ActionReindex   = "refresh_index"
)
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
⋮----
var path string
```

## File: internal/providers/files/db.go

```go
package main
import (
	"database/sql"
	"fmt"
	"log/slog"
	"os"
	"path/filepath"
	"time"
	"github.com/abenz1267/elephant/v2/pkg/common"
	_ "github.com/mattn/go-sqlite3"
)
⋮----
"database/sql"
"fmt"
"log/slog"
"os"
"path/filepath"
"time"
"github.com/abenz1267/elephant/v2/pkg/common"
_ "github.com/mattn/go-sqlite3"
⋮----
var db *sql.DB
func openDB() error
⋮----
var err error
⋮----
// Create indexes for query performance
⋮----
func putFileBatch(files []File) error
func dropAll()
func putFile(f File)
func getFile(identifier string) *File
⋮----
var f File
var changedUnix int64
⋮----
func getFilesByQuery(query string, _ bool) []File
⋮----
var result []File
⋮----
var rows *sql.Rows
⋮----
func deleteFileByPath(path string)
```

## File: internal/providers/files/file.go

```go
package main
import "time"
//go:generate msgp
type File struct {
	Identifier string
	Path       string
	Changed    time.Time
}
```

## File: internal/providers/files/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = files.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/files/query.go

```go
package main
import (
	"log/slog"
	"net"
	"strings"
	"time"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
"log/slog"
"net"
"strings"
"time"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
func Query(conn net.Conn, query string, _ bool, exact bool, _ uint8) []*pb.QueryResponse_Item
```

## File: internal/providers/files/README.md

````markdown
### Elephant Files

Find files/folders.

#### Features

- preview text/images/pdf
- open files, folders
- drag&drop files into other programs
- copy file/path
- support for localsend

#### Example `ignored_dirs`

```toml
ignored_dirs = ["/home/andrej/Documents/", "/home/andrej/Videos"]
```

#### Requirements

- `fd`
````

## File: internal/providers/files/setup.go

```go
package main
import (
	"bufio"
	"crypto/md5"
	_ "embed"
	"encoding/hex"
	"fmt"
	"log"
	"log/slog"
	"os"
	"os/exec"
	"regexp"
	"slices"
	"strings"
	"time"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
	"github.com/djherbis/times"
	"github.com/fsnotify/fsnotify"
)
⋮----
"bufio"
"crypto/md5"
_ "embed"
"encoding/hex"
"fmt"
"log"
"log/slog"
"os"
"os/exec"
"regexp"
"slices"
"strings"
"time"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
"github.com/djherbis/times"
"github.com/fsnotify/fsnotify"
⋮----
//go:embed README.md
var readme string
var (
	Name         = "files"
	NamePretty   = "Files"
	config       *Config
	watcher      *fsnotify.Watcher
	ignoreRegexp []*regexp.Regexp
	hasLocalsend bool
)
type IgnoredPreview struct {
	Path        string `koanf:"path" desc:"path to ignore preview for" default:""`
	Placeholder string `koanf:"placeholder" desc:"text to display instead" default:""`
}
type Config struct {
	common.Config  `koanf:",squash"`
	LaunchPrefix   string           `koanf:"launch_prefix" desc:"overrides the default app2unit or uwsm prefix, if set." default:""`
	IgnoredDirs    []string         `koanf:"ignored_dirs" desc:"ignore these directories. regexp based." default:""`
	IgnorePreviews []IgnoredPreview `koanf:"ignore_previews" desc:"paths will not have a preview" default:""`
	IgnoreWatching []string         `koanf:"ignore_watching" desc:"paths will not be watched" default:""`
	SearchDirs     []string         `koanf:"search_dirs" desc:"directories to search for files" default:"$HOME"`
	FdFlags        []string         `koanf:"fd_flags" desc:"flags for fd" default:"['--ignore-vcs', '--type,' ,'file', '--type,' 'directory']"`
	WatchBuffer    int              `koanf:"watch_buffer" desc:"time in millisecnds elephant will gather changed paths before processing them" default:"2000"`
	WatchDirs      []string         `koanf:"watch_dirs" desc:"watch these dirs, even if watch = false" default:"[]"`
	Watch          bool             `koanf:"watch" desc:"watch indexed directories" default:"true"`
}
func Setup()
func index()
func Available() bool
func handleDelete(deleteChan chan string)
func handleRegular(regularChan chan string)
func PrintDoc()
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
func shouldWatch(path string) bool
```

## File: internal/providers/menus/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = menus.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/menus/README.md

````markdown
### Elephant Menus

Create custom menus.

#### Features

- seamless menus
- create submenus
- define multiple actions per entry
- dynamic menus with Lua

#### How to create a menu

Default location for menu definitions is `~/.config/elephant/menus/`. Simply place a file in there, see examples below.

#### Actions for submenus/dmenus

Submenus/Dmenus will automatically get an action `open`.

#### Examples

```toml
name = "other"
name_pretty = "Other"
icon = "applications-other"

[[entries]]
text = "Color Picker"
keywords = ["color", "picker", "hypr"]
actions = { "cp_use" = "wl-copy $(hyprpicker)" }
icon = "color-picker"

[[entries]]
icon = "zoom-in"
text = "Zoom Toggle"
actions = { "zoom_use" = "hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float) | if . > 1 then 1 else 1.5 end')" }

[[entries]]
text = "Volume"
async = "echo $(wpctl get-volume @DEFAULT_AUDIO_SINK@)"
icon = "audio-volume-high"

[entries.actions]
"volume_raise" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+"
"volume_lower" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"
"volume_mute" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0"
"volume_unmute" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1"
"volume_set" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ %VALUE%"

[[entries]]
keywords = ["disk", "drive", "space"]
text = "Disk"
actions = { "disk_copy" = "wl-copy '%VALUE%'" }
async = """echo $(df -h / | tail -1 | awk '{print "Used: " $3 " - Available: " $4 " - Total: " $2}')"""
icon = "drive-harddisk"

[[entries]]
text = "Mic"
async = "echo $(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)"
icon = "audio-input-microphone"
actions = { "mic_set" = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ %VALUE%" }

[[entries]]
text = "System"
async = """echo $(echo "Memory: $(free -h | awk '/^Mem:/ {printf "%s/%s", $3, $2}') | CPU: $(top -bn1 | grep 'Cpu(s)' | awk '{printf "%.1f%%", 100 - $8}')")"""
icon = "computer"

[[entries]]
text = "Today"
keywords = ["date", "today", "calendar"]
async = """echo $(date "+%H:%M - %d.%m. %A - KW %V")"""
icon = "clock"
actions = { "open_cal" = "xdg-open https://calendar.google.com" }

[[entries]]
text = "uuctl"
keywords = ["uuctl"]
icon = "applications-system"
submenu = "dmenu:uuctl"
```

```toml
name = "screenshots"
name_pretty = "Screenshots"
icon = "camera-photo"

[[entries]]
text = "View"
actions = { "view" = "vimiv ~/Pictures/" }

[[entries]]
text = "Annotate"
actions = { "annotate" = "wl-paste | satty -f -" }

[[entries]]
text = "Toggle Record"
actions = { "record" = "record" }

[[entries]]
text = "OCR"
keywords = ["ocr", "text recognition", "OCR"]
actions = { "ocr" = "wayfreeze --hide-cursor --after-freeze-cmd 'grim -g \"$(slurp)\" - | tesseract stdin stdout -l deu+eng | wl-copy; killall wayfreeze'" }

[[entries]]
text = "Screenshot Region"
actions = { "region" = "wayfreeze --hide-cursor --after-freeze-cmd 'IMG=~/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png && grim -g \"$(slurp)\" $IMG && wl-copy < $IMG; killall wayfreeze'" }

[[entries]]
text = "Screenshot Window"
actions = { "window" = "wayfreeze --after-freeze-cmd 'IMG=~/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png && grim $IMG && wl-copy < $IMG; killall wayfreeze'" }

[[entries]]
text = "other menu"
submenu = "other"
```

```toml
name = "bookmarks"
name_pretty = "Bookmarks"
icon = "bookmark"
action = "xdg-open %VALUE%"

[[entries]]
text = "Walker"
value = "https://github.com/abenz1267/walker"

[[entries]]
text = "Elephant"
value = "https://github.com/abenz1267/elephant"

[[entries]]
text = "Drive"
value = "https://drive.google.com"

[[entries]]
text = "Prime"
value = "https://www.amazon.de/gp/video/storefront/"
```

#### Lua Example

By default, the Lua script will be called on every empty query. If you don't want this behaviour, but instead want to cache the query once, you can set `Cache=true` in the menu's config.

Following global functions will be set:

- `lastMenuValue(<menuname>)` => gets the last used value of a menu
- `state()` => retrieves the state for this menu (string array/table)
- `setState(state)` => sets the state for this menu (string array/table)
- `jsonEncode` => encodes to json
- `jsonDecodes` => decodes from json

```lua
Name = "luatest"
NamePretty = "Lua Test"
Icon = "applications-other"
Cache = true
Action = "notify-send %VALUE%"
HideFromProviderlist = false
Description = "lua test menu"
SearchName = true

function GetEntries()
    local entries = {}
    local wallpaper_dir = "/home/andrej/Documents/ArchInstall/wallpapers"

    local handle = io.popen("find '" ..
        wallpaper_dir ..
        "' -maxdepth 1 -type f -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' -o -name '*.gif' -o -name '*.bmp' -o -name '*.webp' 2>/dev/null")
    if handle then
        for line in handle:lines() do
            local filename = line:match("([^/]+)$")
            if filename then
                table.insert(entries, {
                    Text = filename,
                    Subtext = "wallpaper",
                    Value = line,
                    Actions = {
                        up = "notify-send up",
                        down = "notify-send down",
                    },
                    -- Preview = line,
                    -- PreviewType = "file",
                    -- Icon = line
                })
            end
        end
        handle:close()
    end

    return entries
end
```

You can call Lua functions as actions as well:

```Lua
Actions = {
    test = "lua:Test",
}

function Test(value, args, query)
    os.execute("notify-send '" .. value .. "'")
    os.execute("notify-send '" .. args .. "'")
    os.execute("notify-send '" .. query .. "'")
end
```
````

## File: internal/providers/menus/setup.go

```go
package main
import (
	_ "embed"
	"fmt"
	"log/slog"
	"net"
	"os"
	"os/exec"
	"slices"
	"strings"
	"syscall"
	"time"
	"github.com/abenz1267/elephant/v2/internal/comm/handlers"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/common/history"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
	lua "github.com/yuin/gopher-lua"
)
⋮----
_ "embed"
"fmt"
"log/slog"
"net"
"os"
"os/exec"
"slices"
"strings"
"syscall"
"time"
"github.com/abenz1267/elephant/v2/internal/comm/handlers"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/common/history"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
lua "github.com/yuin/gopher-lua"
⋮----
var (
	Name       = "menus"
	NamePretty = "Menus"
	h          = history.Load(Name)
//go:embed README.md
var readme string
func PrintDoc()
func Setup()
func Available() bool
const (
	ActionGoParent = "menus:parent"
	ActionOpen     = "menus:open"
	ActionDefault  = "menus:default"
)
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
⋮----
var e common.Entry
var menu *common.Menu
⋮----
func Query(conn net.Conn, query string, single bool, exact bool, format uint8) []*pb.QueryResponse_Item
⋮----
var usageScore int32
⋮----
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
func calcScore(q string, d common.Entry, exact bool) (string, int32, []int32, int32, bool)
⋮----
var scoreRes int32
var posRes []int32
var startRes int32
var match string
var modifier int32
⋮----
func itemToEntry(format uint8, query string, conn net.Conn, menuActions map[string]string, namePretty string, single bool, icon string, me *common.Entry) *pb.QueryResponse_Item
⋮----
var actions []string
```

## File: internal/providers/nirisessions/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = nirisessions.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/nirisessions/README.md

````markdown
### Elephant Niri Sessions

Create predefined session layouts and open them.

#### Features

- run custom commands to open windows
- position windows according to definition

#### Requirements

- `niri`

#### Example Sessions

```toml
[[sessions]]
name = "Work"

[[sessions.workspaces]]
windows = [
  { command = "uwsm-app -- footclient", app_id = "footclient" },
  { command = "uwsm-app -- firefox-developer-edition", app_id = "firefox-developer-edition" },
]

[[sessions.workspaces]]
windows = [
  { command = "uwsm-app -- teams-for-linux", app_id = "teams-for-linux" },
  { command = "uwsm-app -- discord", app_id = "discord" },
]

[[sessions.workspaces]]
windows = [{ command = "uwsm-app -- tidal-hifi", app_id = "tidal-hifi" }]

[[sessions]]
name = "Private"

[[sessions.workspaces]]
windows = [
  { command = "uwsm-app -- firefox-developer-edition", app_id = "firefox-developer-edition" },
  { command = "uwsm-app -- discord", app_id = "discord" },
]

[[sessions.workspaces]]
windows = [{ command = "uwsm-app -- tidal-hifi", app_id = "tidal-hifi" }]

[[sessions]]
name = "Walker"

[[sessions.workspaces]]
windows = [
  { command = "uwsm-app -- footclient -D /home/andrej/Documents/walker -e nvim", app_id = "footclient" },
  { command = "uwsm-app -- footclient -D /home/andrej/Documents/walker", app_id = "footclient" },
]

[[sessions]]
name = "Elephant"

[[sessions.workspaces]]
windows = [
  { command = "uwsm-app -- footclient -D /home/andrej/Documents/elephant -e nvim", app_id = "footclient", after = [
    "niri msg action focus-window --id %ID%",
    "niri msg action fullscreen-window",
  ] },
  { command = "uwsm-app -- footclient -D /home/andrej/Documents/elephant", app_id = "footclient" },
]
```
````

## File: internal/providers/nirisessions/setup.go

```go
package main
import (
	"bufio"
	"encoding/json"
	"fmt"
	"log/slog"
	"net"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"
	_ "embed"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
"bufio"
"encoding/json"
"fmt"
"log/slog"
"net"
"os"
"os/exec"
"strconv"
"strings"
"time"
_ "embed"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
var (
	Name       = "nirisessions"
	NamePretty = "Niri Sessions"
	config     *Config
)
//go:embed README.md
var readme string
const (
	ActionStart    = "start"
	ActionStartNew = "start_new"
)
type Config struct {
	common.Config `koanf:",squash"`
	Sessions      []Session `koanf:"sessions" desc:"define the sessions" default:""`
}
type Session struct {
	Name       string      `koanf:"name" desc:"name for the session" default:""`
	Workspaces []Workspace `koanf:"workspaces" desc:"set of workspaces" default:""`
}
type Workspace struct {
	Windows []Window `koanf:"windows" desc:"windows in this workspace group" default:""`
	After   []string `koanf:"after" desc:"commands to run after the workspace has been processed" default:""`
}
type Window struct {
	Command string   `koanf:"command" desc:"command to run" default:""`
	AppID   string   `koanf:"app_id" desc:"app_id to identify the window" default:""`
	After   []string `koanf:"after" desc:"commands to run after the window has been spawned" default:""`
}
func Setup()
func Available() bool
func PrintDoc()
type OpenedOrChangedEvent struct {
	WindowOpenedOrChanged *struct {
		Window struct {
			ID     int    `json:"id"`
			AppID  string `json:"app_id"`
			Layout struct {
				PosInScrollingLayout []int `json:"pos_in_scrolling_layout"`
			} `json:"layout"`
func monitor(appid string, res chan int)
⋮----
var e OpenedOrChangedEvent
⋮----
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
func goWorkspaceDown()
func Query(conn net.Conn, query string, single bool, exact bool, _ uint8) []*pb.QueryResponse_Item
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
```

## File: internal/providers/providerlist/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = providerlist.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/providerlist/README.md

```markdown
### Elephant Providerlist

Lists all installed providers and configured menus.
```

## File: internal/providers/providerlist/setup.go

```go
package main
import (
	_ "embed"
	"fmt"
	"log/slog"
	"net"
	"slices"
	"strings"
	"time"
	"github.com/abenz1267/elephant/v2/internal/providers"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
_ "embed"
"fmt"
"log/slog"
"net"
"slices"
"strings"
"time"
"github.com/abenz1267/elephant/v2/internal/providers"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
var (
	Name       = "providerlist"
	NamePretty = "Providerlist"
	config     *Config
)
//go:embed README.md
var readme string
type Config struct {
	common.Config `koanf:",squash"`
	Hidden        []string `koanf:"hidden" desc:"hidden providers" default:"<empty>"`
}
func Setup()
func Available() bool
func PrintDoc()
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
func Query(conn net.Conn, query string, single bool, exact bool, _ uint8) []*pb.QueryResponse_Item
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
```

## File: internal/providers/runner/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = runner.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/runner/README.md

```markdown
### Elephant Runner

Execute everything installed in your $PATH.

#### Features

- finds all executables items in $PATH
- ... or define an explicit list yourself
```

## File: internal/providers/runner/setup.go

```go
// Package runner provides access to binaries in $PATH.
package main
import (
	"crypto/md5"
	_ "embed"
	"encoding/hex"
	"fmt"
	"io/fs"
	"log/slog"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strings"
	"syscall"
	"time"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/common/history"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
	"github.com/charlievieth/fastwalk"
)
⋮----
"crypto/md5"
_ "embed"
"encoding/hex"
"fmt"
"io/fs"
"log/slog"
"net"
"os"
"os/exec"
"path/filepath"
"slices"
"strings"
"syscall"
"time"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/common/history"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
"github.com/charlievieth/fastwalk"
⋮----
var (
	Name       = "runner"
	NamePretty = "Runner"
)
//go:embed README.md
var readme string
type ExplicitItem struct {
	Exec  string `koanf:"exec" desc:"executable/command to run" default:""`
	Alias string `koanf:"alias" desc:"alias" default:""`
}
type Config struct {
	common.Config    `koanf:",squash"`
	History          bool           `koanf:"history" desc:"make use of history for sorting" default:"true"`
	HistoryWhenEmpty bool           `koanf:"history_when_empty" desc:"consider history when query is empty" default:"false"`
	GenericText      string         `koanf:"generic_text" desc:"text prefix for generic run-anything entry" default:"run: "`
	Explicits        []ExplicitItem `koanf:"explicits" desc:"use this explicit list, instead of searching $PATH" default:""`
}
var (
	config *Config
	items  = []Item{}
	h      = history.Load(Name)
type Item struct {
	Identifier string
	Bin        string
	Alias      string
}
func Setup()
func Available() bool
func PrintDoc()
const (
	ActionRun           = "run"
	ActionRunInTerminal = "runterminal"
)
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
func Query(conn net.Conn, query string, single bool, exact bool, _ uint8) []*pb.QueryResponse_Item
⋮----
var score int32
var positions []int32
var start int32
⋮----
var usageScore int32
⋮----
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
```

## File: internal/providers/snippets/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = snippets.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/snippets/README.md

````markdown
### Elephant Snippets

Create and access text snippets.

#### Features

- multiple keywords per snippet
- define command for pasting yourself

#### Requirements

- `wtype`

#### Example snippets

```toml
[[snippets]]
keywords = ["search", "this"]
name = "example snippet"
content = "this will be pasted"
```
````

## File: internal/providers/snippets/setup.go

```go
package main
import (
	"fmt"
	"log/slog"
	"net"
	"os/exec"
	"strconv"
	"strings"
	"time"
	_ "embed"
	"al.essio.dev/pkg/shellescape"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
"fmt"
"log/slog"
"net"
"os/exec"
"strconv"
"strings"
"time"
_ "embed"
"al.essio.dev/pkg/shellescape"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
var (
	Name       = "snippets"
	NamePretty = "Snippets"
	config     *Config
)
//go:embed README.md
var readme string
const (
	ActionPaste = "paste"
)
type Config struct {
	common.Config `koanf:",squash"`
	Command       string    `koanf:"command" desc:"default command to be executed. supports %VALUE%." default:"wtype %CONTENT%"`
	Snippets      []Snippet `koanf:"snippets" desc:"available snippets" default:""`
	Delay         int       `koanf:"delay" desc:"delay in ms before executing command to avoid potential focus issues" default:"100"`
}
type Snippet struct {
	Keywords []string `koanf:"keywords" desc:"searchable keywords" default:""`
	Name     string   `koanf:"name" desc:"displayed name" default:""`
	Content  string   `koanf:"content" desc:"content to paste" default:""`
}
func Setup()
func Available() bool
func PrintDoc()
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
func Query(conn net.Conn, query string, single bool, exact bool, _ uint8) []*pb.QueryResponse_Item
func calcScore(q string, d Snippet, exact bool) (int32, []int32, int32, bool)
⋮----
var scoreRes int32
var posRes []int32
var startRes int32
⋮----
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
```

## File: internal/providers/symbols/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = symbols.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/symbols/parse.go

```go
package main
import (
	"crypto/md5"
	"embed"
	"encoding/hex"
	"encoding/xml"
	"fmt"
	"log/slog"
	"strings"
)
⋮----
"crypto/md5"
"embed"
"encoding/hex"
"encoding/xml"
"fmt"
"log/slog"
"strings"
⋮----
//go:embed data/*
var files embed.FS
type LDML struct {
	XMLName     xml.Name    `xml:"ldml"`
	Identity    Identity    `xml:"identity"`
	Annotations Annotations `xml:"annotations"`
}
type Identity struct {
	Version  Version  `xml:"version"`
	Language Language `xml:"language"`
}
type Version struct {
	Number string `xml:"number,attr"`
}
type Language struct {
	Type string `xml:"type,attr"`
}
type Annotations struct {
	Annotation []Annotation `xml:"annotation"`
}
type Annotation struct {
	CP   string `xml:"cp,attr"`
	Type string `xml:"type,attr,omitempty"`
	Text string `xml:",chardata"`
}
type Symbol struct {
	CP         string
	Searchable []string
}
var symbols = make(map[string]*Symbol)
func parse()
⋮----
var ldml LDML
```

## File: internal/providers/symbols/README.md

```markdown
### Elephant Symbols

Search for emojis and symbols

#### Requirements

- `wl-clipboard`
```

## File: internal/providers/symbols/setup.go

```go
// Package symbols provides symbols/emojis.
package main
import (
	_ "embed"
	"fmt"
	"log"
	"log/slog"
	"net"
	"path/filepath"
	"strings"
	"time"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/common/history"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
_ "embed"
"fmt"
"log"
"log/slog"
"net"
"path/filepath"
"strings"
"time"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/common/history"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
var (
	Name       = "symbols"
	NamePretty = "Symbols/Emojis"
	h          = history.Load(Name)
//go:embed README.md
var readme string
type Config struct {
	common.Config    `koanf:",squash"`
	Locale           string `koanf:"locale" desc:"locale to use for symbols" default:"en"`
	History          bool   `koanf:"history" desc:"make use of history for sorting" default:"true"`
	HistoryWhenEmpty bool   `koanf:"history_when_empty" desc:"consider history when query is empty" default:"false"`
	Command          string `koanf:"command" desc:"default command to be executed. supports %VALUE%." default:"wl-copy"`
}
var config *Config
func Setup()
func Available() bool
func PrintDoc()
const ActionRunCmd = "run_cmd"
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
func Query(conn net.Conn, query string, _ bool, exact bool, _ uint8) []*pb.QueryResponse_Item
⋮----
var positions []int32
var fs int32
var score int32
⋮----
var bestScore int32
var bestPos []int32
var bestStart int32
⋮----
var usageScore int32
⋮----
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
```

## File: internal/providers/todo/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = todo.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/todo/README.md

````markdown
### Elephant Todo

Basic Todolist

#### Features

- basic time tracking
- create new scheduled items
- notifications for scheduled items
- mark items as: done, active
- urgent items
- clear all done items
- git integration (requires ssh access)

#### Requirements

- `notify-send` for notifications

#### Git Integration

You can set

```toml
location = "https://github.com/abenz1267/elephanttodo"
```

This will automatically try to clone/pull the repo. It will also automatically comimt and push on changes.

#### Usage

##### Creating a new item

If you want to create a scheduled task, you can prefix your item with f.e.:

```
+5d > my task
in 10m > my task
in 5d at 15:00 > my task
jan 1 at 13:00 > my task
january 1 at 13:00 > my task
1 jan at 13:00 > my task
```

Adding a `!` suffix will mark an item as urgent.

##### Time-based searching

Similar to creating, you can simply search for like `today` to get all items for today.
````

## File: internal/providers/todo/setup.go

```go
package main
import (
	"bytes"
	_ "embed"
	"encoding/gob"
	"fmt"
	"log/slog"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strconv"
	"strings"
	"sync"
	"time"
	"github.com/abenz1267/elephant/v2/internal/comm/handlers"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
	"github.com/go-git/go-git/v6"
	"github.com/sho0pi/naturaltime"
)
⋮----
"bytes"
_ "embed"
"encoding/gob"
"fmt"
"log/slog"
"net"
"os"
"os/exec"
"path/filepath"
"slices"
"strconv"
"strings"
"sync"
"time"
"github.com/abenz1267/elephant/v2/internal/comm/handlers"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
"github.com/go-git/go-git/v6"
"github.com/sho0pi/naturaltime"
⋮----
var (
	Name       = "todo"
	NamePretty = "Todo List"
	config     *Config
	items      = []Item{}
	parser     *naturaltime.Parser
	isGit      bool
	creating   bool
)
//go:embed README.md
var readme string
type Config struct {
	common.Config     `koanf:",squash"`
	UrgentTimeFrame   int        `koanf:"urgent_time_frame" desc:"items that have a due time within this period will be marked as urgent" default:"10"`
	DuckPlayerVolumes bool       `koanf:"duck_player_volumes" desc:"lowers volume of players when notifying, slowly raises volumes again" default:"true"`
	Categories        []Category `koanf:"categories" desc:"categories" default:""`
	Location          string     `koanf:"location" desc:"location of the CSV file" default:"elephant cache dir"`
	TimeFormat        string     `koanf:"time_format" desc:"format of the time. Look at https://go.dev/src/time/format.go for the layout." default:"02-Jan 15:04"`
	Notification      `koanf:",squash"`
	w                 *git.Worktree
	r                 *git.Repository
}
func (config *Config) SetLocation(val string)
func (config *Config) URL() string
func (config *Config) SetWorktree(val *git.Worktree)
func (config *Config) SetRepository(val *git.Repository)
type Category struct {
	Name   string `koanf:"name" desc:"name for category" default:""`
	Prefix string `koanf:"prefix" desc:"prefix to store item in category" default:""`
}
type Notification struct {
	Title string `koanf:"title" desc:"title of the notification" default:"Task Due"`
	Body  string `koanf:"body" desc:"body of the notification" default:"%TASK%"`
}
const (
	StatePending  = "pending"
	StateActive   = "active"
	StateDone     = "done"
	StateCreating = "creating"
	StateUrgent   = "urgent"
)
const (
	ActionSave           = "save"
	ActionSaveNext       = "save_next"
	ActionChangeCategory = "change_category"
	ActionDelete         = "delete"
	ActionMarkDone       = "done"
	ActionMarkActive     = "active"
	ActionMarkInactive   = "inactive"
	ActionClear          = "clear"
	ActionCreate         = "create"
	ActionSearch         = "search"
)
const (
	UrgencyNormal   = "normal"
	UrgencyCritical = "critical"
)
type Item struct {
	Text      string
	Scheduled time.Time
	Started   time.Time
	Finished  time.Time
	Created   time.Time
	Category  string
	State     string
	Urgency   string
	Notified  bool
}
func (i Item) toCSVRow() string
func saveItems()
func (i *Item) fromQuery(query string)
func Setup()
⋮----
var err error
⋮----
func Available() bool
func notify()
func duckPlayers()
func PrintDoc()
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
func createNew(identifier string)
func store(query string)
func migrateGOBtoCSV() bool
var (
	loadMu sync.Mutex
	loaded bool
)
func loadItems()
func Query(conn net.Conn, query string, single bool, exact bool, _ uint8) []*pb.QueryResponse_Item
⋮----
var highestScore int32
var category Category
⋮----
var date *time.Time
⋮----
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
func itemToEntry(urgent time.Time, i int, v Item) *pb.QueryResponse_Item
func isSameDay(t1, t2 *time.Time) bool
func endOfDay(t time.Time) time.Time
```

## File: internal/providers/unicode/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = unicode.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/unicode/README.md

```markdown
### Elephant Unicode

Search for unicode symbols

#### Requirements

- `wl-clipboard`
```

## File: internal/providers/unicode/setup.go

```go
// Package symbols provides symbols/emojis.
package main
import (
	"fmt"
	"log/slog"
	"net"
	"strconv"
	"strings"
	"time"
	_ "embed"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/common/history"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
"fmt"
"log/slog"
"net"
"strconv"
"strings"
"time"
_ "embed"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/common/history"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
var (
	Name       = "unicode"
	NamePretty = "Unicode"
	h          = history.Load(Name)
//go:embed README.md
var readme string
//go:embed data/UnicodeData.txt
var data string
type Config struct {
	common.Config    `koanf:",squash"`
	Locale           string `koanf:"locale" desc:"locale to use for symbols" default:"en"`
	History          bool   `koanf:"history" desc:"make use of history for sorting" default:"true"`
	HistoryWhenEmpty bool   `koanf:"history_when_empty" desc:"consider history when query is empty" default:"false"`
	Command          string `koanf:"command" desc:"default command to be executed. supports %VALUE%." default:"wl-copy"`
}
var (
	config  *Config
	symbols = make(map[string]string)
func Setup()
func Available() bool
func PrintDoc()
const ActionRunCmd = "run_cmd"
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
func Query(conn net.Conn, query string, _ bool, exact bool, _ uint8) []*pb.QueryResponse_Item
⋮----
var usageScore int32
⋮----
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
```

## File: internal/providers/websearch/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = websearch.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/websearch/README.md

````markdown
### Elephant Websearch

Search the web with custom defined search engines.

#### Example entry

```toml
[[entries]]
default = true
name = "Google"
url = "https://www.google.com/search?q=%TERM%"
```
````

## File: internal/providers/websearch/setup.go

```go
package main
import (
	_ "embed"
	"fmt"
	"log/slog"
	"net"
	"net/url"
	"os"
	"os/exec"
	"slices"
	"strconv"
	"strings"
	"syscall"
	"al.essio.dev/pkg/shellescape"
	"github.com/abenz1267/elephant/v2/internal/comm/handlers"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/common/history"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
)
⋮----
_ "embed"
"fmt"
"log/slog"
"net"
"net/url"
"os"
"os/exec"
"slices"
"strconv"
"strings"
"syscall"
"al.essio.dev/pkg/shellescape"
"github.com/abenz1267/elephant/v2/internal/comm/handlers"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/common/history"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
⋮----
var (
	Name       = "websearch"
	NamePretty = "Websearch"
	config     *Config
	prefixes   = make(map[string]int)
//go:embed README.md
var readme string
type Config struct {
	common.Config     `koanf:",squash"`
	Engines           []Engine `koanf:"entries" desc:"entries" default:"google"`
	History           bool     `koanf:"history" desc:"make use of history for sorting" default:"true"`
	HistoryWhenEmpty  bool     `koanf:"history_when_empty" desc:"consider history when query is empty" default:"false"`
	EnginesAsActions  bool     `koanf:"engines_as_actions" desc:"run engines as actions" default:"true"`
	AlwaysShowDefault bool     `koanf:"always_show_default" desc:"always show the default search engine when queried" default:"true"`
	TextPrefix        string   `koanf:"text_prefix" desc:"prefix for the entry text" default:"Search: "`
	Command           string   `koanf:"command" desc:"default command to be executed. supports %VALUE%." default:"xdg-open"`
}
type Engine struct {
	Name    string `koanf:"name" desc:"name of the entry" default:""`
	Default bool   `koanf:"default" desc:"entry to display when querying multiple providers" default:""`
	Prefix  string `koanf:"prefix" desc:"prefix to actively trigger this entry" default:""`
	URL     string `koanf:"url" desc:"url, example: 'https://www.google.com/search?q=%TERM%'" default:""`
	Icon    string `koanf:"icon" desc:"icon to display, fallsback to global" default:""`
}
func Setup()
func Available() bool
func PrintDoc()
const (
	ActionSearch  = "search"
	ActionOpenURL = "open_url"
)
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
func run(query, identifier, q string)
func Query(conn net.Conn, query string, single bool, exact bool, _ uint8) []*pb.QueryResponse_Item
⋮----
var usageScore int32
⋮----
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
```

## File: internal/providers/windows/makefile

```
DESTDIR ?=
CONFIGDIR = $(DESTDIR)/etc/xdg/elephant/providers

GO_BUILD_FLAGS = -buildvcs=false -buildmode=plugin -trimpath
PLUGIN_NAME = windows.so

.PHONY: all build install uninstall clean

all: build

build:
	go build $(GO_BUILD_FLAGS)

install: build
	# Install plugin
	install -Dm 755 $(PLUGIN_NAME) $(CONFIGDIR)/$(PLUGIN_NAME)

uninstall:
	rm -f $(CONFIGDIR)/$(PLUGIN_NAME)

clean:
	go clean
	rm -f $(PLUGIN_NAME)

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the plugin (default)"
	@echo "  build     - Build the plugin"
	@echo "  install   - Install the plugin"
	@echo "  uninstall - Remove installed plugin"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo ""
	@echo "Note: This builds a Go plugin (.so file) for elephant"
```

## File: internal/providers/windows/README.md

```markdown
### Elephant Windows

Find and focus opened windows.
```

## File: internal/providers/windows/setup.go

```go
// Package windows provides window focusing.
package main
import (
	"fmt"
	"io/fs"
	"log/slog"
	"net"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"
	_ "embed"
	"github.com/abenz1267/elephant/v2/internal/util"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/common/wlr"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
	"github.com/adrg/xdg"
	"github.com/charlievieth/fastwalk"
	"github.com/neurlang/wayland/wl"
)
⋮----
"fmt"
"io/fs"
"log/slog"
"net"
"os"
"path/filepath"
"strconv"
"strings"
"sync"
"time"
_ "embed"
"github.com/abenz1267/elephant/v2/internal/util"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/common/wlr"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
"github.com/adrg/xdg"
"github.com/charlievieth/fastwalk"
"github.com/neurlang/wayland/wl"
⋮----
var (
	Name       = "windows"
	NamePretty = "Windows"
)
var (
	icons = make(map[string]string)
//go:embed README.md
var readme string
type Config struct {
	common.Config `koanf:",squash"`
	Delay         int `koanf:"delay" desc:"delay in ms before focusing to avoid potential focus issues" default:"100"`
}
var config *Config
func Setup()
func Available() bool
func PrintDoc()
const (
	ActionFocus = "focus"
)
func Activate(single bool, identifier, action string, query string, args string, format uint8, conn net.Conn)
func Query(conn net.Conn, query string, _ bool, exact bool, _ uint8) []*pb.QueryResponse_Item
func Icon() string
func HideFromProviderlist() bool
func State(provider string) *pb.ProviderStateResponse
func calcScore(q string, d *wlr.Window, exact bool) (string, int32, []int32, int32, bool)
⋮----
var scoreRes int32
var posRes []int32
var startRes int32
var match string
⋮----
func findIcons()
func walkFunction(path string, d fs.DirEntry, err error) error
```

## File: internal/providers/load.go

```go
// Package providers provides common provider functions.
package providers
import (
	"io/fs"
	"log/slog"
	"net"
	"os"
	"path/filepath"
	"plugin"
	"slices"
	"strings"
	"sync"
	"github.com/abenz1267/elephant/v2/pkg/common"
	"github.com/abenz1267/elephant/v2/pkg/pb/pb"
	"github.com/charlievieth/fastwalk"
)
⋮----
"io/fs"
"log/slog"
"net"
"os"
"path/filepath"
"plugin"
"slices"
"strings"
"sync"
"github.com/abenz1267/elephant/v2/pkg/common"
"github.com/abenz1267/elephant/v2/pkg/pb/pb"
"github.com/charlievieth/fastwalk"
⋮----
type ProviderStateResponse struct {
	Actions []string
	States  []string
}
type Provider struct {
	Name                 *string
	Available            func() bool
	PrintDoc             func()
	NamePretty           *string
	State                func(string) *pb.ProviderStateResponse
	Setup                func()
	HideFromProviderlist func() bool
	Icon                 func() string
	Activate             func(single bool, identifier, action, query, args string, format uint8, conn net.Conn)
	Query                func(conn net.Conn, query string, single bool, exact bool, format uint8) []*pb.QueryResponse_Item
}
var (
	Providers      map[string]Provider
	QueryProviders map[uint32][]string
	libDirs        = []string{
		"/usr/lib/elephant",
		"/usr/local/lib/elephant",
		"/lib/elephant",
	}
)
func Load(setup bool)
⋮----
var mut sync.Mutex
```

## File: internal/util/doc.go

```go
// Package util provides general utility.
package util
import (
	"fmt"
	"reflect"
	"slices"
	"strings"
	"github.com/abenz1267/elephant/v2/internal/providers"
	"github.com/abenz1267/elephant/v2/pkg/common"
)
⋮----
"fmt"
"reflect"
"slices"
"strings"
"github.com/abenz1267/elephant/v2/internal/providers"
"github.com/abenz1267/elephant/v2/pkg/common"
⋮----
func GenerateDoc(provider string)
func PrintConfig(c any, name string)
func getStructName(c any) string
func printStructTable(c any, structName string)
func printStructDesc(c any)
⋮----
var nestedStructs []reflect.Type
```

## File: internal/util/preview.go

```go
package util
var (
	PreviewTypeText    = "text"
	PreviewTypePango   = "pango"
	PreviewTypeCommand = "command"
	PreviewTypeFile    = "file"
)
```

## File: nix/modules/home-manager.nix

```nix
flake: {
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.elephant;
  settingsFormat = pkgs.formats.toml {};

  # Available providers
  providerOptions = {
    desktopapplications = "Desktop application launcher";
    files = "File search and management";
    clipboard = "Clipboard history management";
    runner = "Command runner";
    symbols = "Symbols and emojis";
    calc = "Calculator and unit conversion";
    menus = "Custom menu system";
    providerlist = "Provider listing and management";
    websearch = "Web search integration";
    todo = "Todo list";
    bookmarks = "Bookmarks management";
    unicode = "Unicode symbol search";
    bluetooth = "Basic Bluetooth management";
    windows = "Find and focus windows";
    snippets = "Find and paste text snippets";
    nirisessions = "Define sets of apps to open and run them";
    "1password" = "Access your 1Password Vaults";
  };
in {
  imports = [
    # Deprecated: delete with v3.0.0 release
    (lib.mkRenamedOptionModule ["programs" "elephant" "config"] ["programs" "elephant" "settings"])
  ];

  options.programs.elephant = {
    enable = mkEnableOption "Elephant launcher backend";

    package = mkOption {
      type = types.package;
      default = flake.packages.${pkgs.stdenv.system}.elephant-with-providers;
      defaultText = literalExpression "flake.packages.\${pkgs.stdenv.system}.elephant-with-providers";
      description = "The elephant package to use.";
    };

    providers = mkOption {
      type = types.listOf (types.enum (attrNames providerOptions));
      default = attrNames providerOptions;
      example = [
        "files"
        "desktopapplications"
        "calc"
      ];
      description = ''
        List of built-in providers to enable (install). Available providers:
        ${concatStringsSep "\n" (mapAttrsToList (name: desc: "  - ${name}: ${desc}") providerOptions)}
      '';
    };

    installService = mkOption {
      type = types.bool;
      default = true;
      description = "Create a systemd service for elephant.";
    };

    debug = mkOption {
      type = types.bool;
      default = false;
      description = "Enable debug logging for elephant service.";
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = settingsFormat.type;
      };
      default = {};
      example = literalExpression ''
        {
          auto_detect_launch_prefix = false;
        }
      '';
      description = ''
        elephant/elephant.toml run `elephant generatedoc` to view available options.
      '';
    };

    provider = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          # Generic Options
          settings = mkOption {
            type = types.submodule {
              freeformType = settingsFormat.type;
            };
            default = {};
            description = ''
              Provider specific toml configuration as Nix attributes. Run `elephant generatedoc` to view available options.
            '';
          };

          # Menus Provider Settings
          # provider.menus.toml
          toml = mkOption {
            type = types.attrsOf (types.submodule {
              freeformType = settingsFormat.type;
            });
            example =
              literalExpression
              ''
                {
                  "bookmarks" = {
                    name = "bookmarks";
                    name_pretty = "Bookmarks";
                    icon = "bookmark";
                    action = "xdg-open %VALUE%";

                    entries = [
                      {
                        text = "Walker";
                        value = "https://github.com/abenz1267/walker";
                      }
                      {
                        text = "Elephant";
                        value = "https://github.com/abenz1267/elephant";
                      }
                      {
                        text = "Drive";
                        value = "https://drive.google.com";
                      }
                      {
                        text = "Prime";
                        value = "https://www.amazon.de/gp/video/storefront/";
                      }
                    ];
                  };
                }
              '';
            default = {};
            description = "Define menus using nix TOML.";
          };

          # provider.menus.lua
          lua = mkOption {
            type = types.attrsOf types.lines;
            default = {};
            example = literalExpression ''
              {
                "luatest" = \'\'
                  Name = "luatest"
                  NamePretty = "Lua Test"
                  Icon = "applications-other"
                  Cache = true
                  Action = "notify-send %VALUE%"
                  HideFromProviderlist = false
                  Description = "lua test menu"
                  SearchName = true

                  function GetEntries()
                      local entries = {}
                      local wallpaper_dir = "/home/andrej/Documents/ArchInstall/wallpapers"

                      local handle = io.popen("find '" ..
                          wallpaper_dir ..
                          "' -maxdepth 1 -type f -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' -o -name '*.gif' -o -name '*.bmp' -o -name '*.webp' 2>/dev/null")
                      if handle then
                          for line in handle:lines() do
                              local filename = line:match("([^/]+)$")
                              if filename then
                                  table.insert(entries, {
                                      Text = filename,
                                      Subtext = "wallpaper",
                                      Value = line,
                                      Actions = {
                                          up = "notify-send up",
                                          down = "notify-send down",
                                      },
                                      -- Preview = line,
                                      -- PreviewType = "file",
                                      -- Icon = line
                                  })
                              end
                          end
                          handle:close()
                      end

                      return entries
                  end
                \'\'
            '';
            description = "Define menus using Lua.";
          };
        };
      });
      default = {};
      example = literalExpression ''
        {
          websearch.settings = {
            entries = [
              {
                name = "NixOS Options";
                url = "https://search.nixos.org/options?query=%TERM%";
              }
            ];
          };
        }
      '';
      description = "Provider specific settings";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    xdg.configFile =
      mkMerge
      [
        # Generate elephant config
        {
          "elephant/elephant.toml" = mkIf (cfg.settings != {}) {
            source = settingsFormat.generate "elephant.toml" cfg.settings;
          };
        }

        # Generate provider files
        (builtins.listToAttrs
          (map
            (
              provider:
                lib.nameValuePair
                "elephant/providers/${provider}.so"
                {
                  source = "${cfg.package}/lib/elephant/providers/${provider}.so";
                  force = true; # Required since previous version used activation script
                }
            )
            cfg.providers))

        # Generate provider configs
        (mapAttrs'
          (
            name: {settings, ...}:
              lib.nameValuePair
              "elephant/${name}.toml"
              {
                source = settingsFormat.generate "${name}.toml" settings;
              }
          )
          (lib.filterAttrs (n: v: v.settings != {}) cfg.provider))

        (lib.mkIf (cfg.provider ? "menus")
          # Generate TOML menu files
          (mapAttrs'
            (
              name: value:
                lib.nameValuePair
                "elephant/menus/${name}.toml"
                {
                  source = settingsFormat.generate "${name}.toml" value;
                }
            )
            cfg.provider.menus.toml))

        # Generate Lua menu files
        (lib.mkIf (cfg.provider ? "menus")
          (mapAttrs'
            (
              name: value:
                lib.nameValuePair
                "elephant/menus/${name}.lua"
                {
                  text = value;
                }
            )
            cfg.provider.menus.lua))
      ];

    systemd.user.services.elephant = mkIf cfg.installService {
      Unit = {
        Description = "Elephant launcher backend";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };

      Service = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/elephant ${optionalString cfg.debug "--debug"}";
        Restart = "on-failure";
        RestartSec = 1;

        X-Restart-Triggers = [
          (builtins.hashString "sha256" (builtins.toJSON {
            inherit (cfg) settings providers provider debug;
          }))
        ];

        # Clean up socket on stop
        ExecStopPost = "${pkgs.coreutils}/bin/rm -f /tmp/elephant.sock";
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
```

## File: nix/modules/nixos.nix

```nix
flake: {
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.elephant;
  settingsFormat = pkgs.formats.toml {};

  # Available providers
  providerOptions = {
    desktopapplications = "Desktop application launcher";
    files = "File search and management";
    clipboard = "Clipboard history management";
    runner = "Command runner";
    symbols = "Symbols and emojis";
    calc = "Calculator and unit conversion";
    menus = "Custom menu system";
    providerlist = "Provider listing and management";
    websearch = "Web search integration";
    todo = "Todo list";
    bookmarks = "Bookmarks management";
    unicode = "Unicode symbol search";
    bluetooth = "Basic Bluetooth management";
    windows = "Find and focus windows";
    snippets = "Find and paste text snippets";
    nirisessions = "Define sets of apps to open and run them";
  };
in {
  imports = [
    # Deprecated: delete with v3.0.0 release
    (lib.mkRenamedOptionModule ["services" "elephant" "config"] ["services" "elephant" "settings"])
  ];

  options.services.elephant = {
    enable = mkEnableOption "Elephant launcher backend system service";

    package = mkOption {
      type = types.package;
      default = flake.packages.${pkgs.stdenv.system}.elephant-with-providers;
      defaultText = literalExpression "flake.packages.\${pkgs.stdenv.system}.elephant-with-providers";
      description = "The elephant package to use.";
    };

    user = mkOption {
      type = types.str;
      default = "elephant";
      description = "User under which elephant runs.";
    };

    group = mkOption {
      type = types.str;
      default = "elephant";
      description = "Group under which elephant runs.";
    };

    providers = mkOption {
      type = types.listOf (types.enum (attrNames providerOptions));
      default = attrNames providerOptions;
      example = [
        "files"
        "desktopapplications"
        "calc"
      ];
      description = ''
        List of built-in providers to enable (install). Available providers:
        ${concatStringsSep "\n" (mapAttrsToList (name: desc: "  - ${name}: ${desc}") providerOptions)}
      '';
    };

    installService = mkOption {
      type = types.bool;
      default = true;
      description = "Create a systemd service for elephant.";
    };

    debug = mkOption {
      type = types.bool;
      default = false;
      description = "Enable debug logging for elephant service.";
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = settingsFormat.type;
      };
      default = {};
      example = literalExpression ''
        {
          auto_detect_launch_prefix = false;
        }
      '';
      description = ''
        elephant/elephant.toml run `elephant generatedoc` to view available options.
      '';
    };

    provider = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          # Generic Options
          settings = mkOption {
            type = types.submodule {
              freeformType = settingsFormat.type;
            };
            default = {};
            description = ''
              Provider specific toml configuration as Nix attributes. Run `elephant generatedoc` to view available options.
            '';
          };

          # Menus Provider Settings
          # provider.menus.toml
          toml = mkOption {
            type = types.attrsOf (types.submodule {
              freeformType = settingsFormat.type;
            });
            example =
              literalExpression
              ''
                {
                  "bookmarks" = {
                    name = "bookmarks";
                    name_pretty = "Bookmarks";
                    icon = "bookmark";
                    action = "xdg-open %VALUE%";

                    entries = [
                      {
                        text = "Walker";
                        value = "https://github.com/abenz1267/walker";
                      }
                      {
                        text = "Elephant";
                        value = "https://github.com/abenz1267/elephant";
                      }
                      {
                        text = "Drive";
                        value = "https://drive.google.com";
                      }
                      {
                        text = "Prime";
                        value = "https://www.amazon.de/gp/video/storefront/";
                      }
                    ];
                  };
                }
              '';
            default = {};
            description = "Declaratively define menus using TOML.";
          };

          # provider.menus.lua
          lua = mkOption {
            type = types.attrsOf types.lines;
            default = {};
            example = literalExpression ''
              {
                "luatest" = \'\'
                  Name = "luatest"
                  NamePretty = "Lua Test"
                  Icon = "applications-other"
                  Cache = true
                  Action = "notify-send %VALUE%"
                  HideFromProviderlist = false
                  Description = "lua test menu"
                  SearchName = true

                  function GetEntries()
                      local entries = {}
                      local wallpaper_dir = "/home/andrej/Documents/ArchInstall/wallpapers"

                      local handle = io.popen("find '" ..
                          wallpaper_dir ..
                          "' -maxdepth 1 -type f -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' -o -name '*.gif' -o -name '*.bmp' -o -name '*.webp' 2>/dev/null")
                      if handle then
                          for line in handle:lines() do
                              local filename = line:match("([^/]+)$")
                              if filename then
                                  table.insert(entries, {
                                      Text = filename,
                                      Subtext = "wallpaper",
                                      Value = line,
                                      Actions = {
                                          up = "notify-send up",
                                          down = "notify-send down",
                                      },
                                      -- Preview = line,
                                      -- PreviewType = "file",
                                      -- Icon = line
                                  })
                              end
                          end
                          handle:close()
                      end

                      return entries
                  end
                \'\';
            '';
            description = "Declaratively define menus using Lua.";
          };
        };
      });
      default = {};
      example = literalExpression ''
        {
          websearch.settings = {
            entries = [
              {
                name = "NixOS Options";
                url = "https://search.nixos.org/options?query=%TERM%";
              }
            ];
          };
        }
      '';
      description = "Provider specific settings";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package];

    environment.etc =
      mkMerge
      [
        # Generate elephant config
        {
          "xdg/elephant/elephant.toml" = mkIf (cfg.settings != {}) {
            source = settingsFormat.generate "elephant.toml" cfg.settings;
          };
        }

        # Generate provider files
        (builtins.listToAttrs
          (map
            (
              provider:
                lib.nameValuePair
                "xdg/elephant/providers/${provider}.so"
                {
                  source = "${cfg.package}/lib/elephant/providers/${provider}.so";
                }
            )
            cfg.providers))

        # Generate provider configs
        (mapAttrs'
          (
            name: {settings, ...}:
              lib.nameValuePair
              "xdg/elephant/${name}.toml"
              {
                source = settingsFormat.generate "${name}.toml" settings;
              }
          )
          (lib.filterAttrs (n: v: v.settings != {}) cfg.provider))

        (lib.mkIf (cfg.provider ? "menus")
          # Generate TOML menu files
          (mapAttrs'
            (
              name: value:
                lib.nameValuePair
                "xdg/elephant/menus/${name}.toml"
                {
                  source = settingsFormat.generate "${name}.toml" value;
                }
            )
            cfg.provider.menus.toml))

        # Generate Lua menu files
        (lib.mkIf (cfg.provider ? "menus")
          (mapAttrs'
            (
              name: value:
                lib.nameValuePair
                "xdg/elephant/menus/${name}.lua"
                {
                  text = value;
                }
            )
            cfg.provider.menus.lua))
      ];

    systemd.services.elephant = mkIf cfg.installService {
      description = "Elephant launcher backend";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${cfg.package}/bin/elephant ${optionalString cfg.debug "--debug"}";
        Restart = "on-failure";
        RestartSec = 1;

        # Security settings
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [
          "/var/lib/elephant"
          "/tmp"
        ];

        # Clean up socket on stop
        ExecStopPost = "${pkgs.coreutils}/bin/rm -f /tmp/elephant.sock";
      };

      environment = {
        HOME = "/var/lib/elephant";
      };
    };
  };
}
```

## File: pkg/common/history/history.go

```go
// Package history provides functions to save and load history in a streamlined way.
package history
import (
	"bytes"
	"encoding/gob"
	"fmt"
	"log/slog"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"
	"github.com/abenz1267/elephant/v2/pkg/common"
)
⋮----
"bytes"
"encoding/gob"
"fmt"
"log/slog"
"os"
"path/filepath"
"strings"
"sync"
"time"
"github.com/abenz1267/elephant/v2/pkg/common"
⋮----
type HistoryData struct {
	LastUsed time.Time
	Amount   int
}
const ActionDelete = "erase_history"
// TODO: this is global for every history ... should not be the case. Just a crutch because of gob encoding.
var mut sync.Mutex
type History struct {
	Provider string
	Data     map[string]map[string]*HistoryData
}
func (h *History) Remove(identifier string)
func (h *History) Save(query, identifier string)
func (h *History) writeFile()
⋮----
var b bytes.Buffer
⋮----
func (h *History) FindUsage(query, identifier string) (int, time.Time, int)
⋮----
var usage int
var lastUsed time.Time
⋮----
func (h *History) CalcUsageScore(query, identifier string) int32
func Load(provider string) *History
```

## File: pkg/common/wlr/tracker.go

```go
package wlr
var (
	addChan     chan string
	deleteChan  chan string
	OpenWindows = make(map[string]uint)
func init()
```

## File: pkg/common/wlr/wlr-foreign-toplevel-management-unstable-v1.go

```go
// This file is autogenerated from: wlr-foreign-toplevel-management-unstable-v1.xml
// Do not edit
// Package wlr implements the wlr_foreign_toplevel_management_unstable_v1 protocol
package wlr
import (
	"sync"
	"github.com/neurlang/wayland/wl"
)
⋮----
"sync"
"github.com/neurlang/wayland/wl"
⋮----
// ZwlrForeignToplevelHandleV1StateMaximized means the toplevel is maximized
const ZwlrForeignToplevelHandleV1StateMaximized = 0
// ZwlrForeignToplevelHandleV1StateMinimized means the toplevel is minimized
const ZwlrForeignToplevelHandleV1StateMinimized = 1
// ZwlrForeignToplevelHandleV1StateActivated means the toplevel is active
const ZwlrForeignToplevelHandleV1StateActivated = 2
// ZwlrForeignToplevelHandleV1StateFullscreen means the toplevel is fullscreen
const ZwlrForeignToplevelHandleV1StateFullscreen = 3
// ZwlrForeignToplevelHandleV1ErrorInvalidRectangle means the provided rectangle is invalid
const ZwlrForeignToplevelHandleV1ErrorInvalidRectangle = 0
// ZwlrForeignToplevelManagerV1 list and control opened apps
type ZwlrForeignToplevelManagerV1 struct {
	wl.BaseProxy
	mu                                           sync.RWMutex
	privateZwlrForeignToplevelManagerV1Toplevels []ZwlrForeignToplevelManagerV1ToplevelHandler
	privateZwlrForeignToplevelManagerV1Finisheds []ZwlrForeignToplevelManagerV1FinishedHandler
}
// NewZwlrForeignToplevelManagerV1 is a constructor for the ZwlrForeignToplevelManagerV1 object
func NewZwlrForeignToplevelManagerV1(ctx *wl.Context) *ZwlrForeignToplevelManagerV1
// Stop stop sending events
func (p *ZwlrForeignToplevelManagerV1) Stop() error
// Dispatch dispatches event for object ZwlrForeignToplevelManagerV1
func (p *ZwlrForeignToplevelManagerV1) Dispatch(event *wl.Event)
// ZwlrForeignToplevelManagerV1ToplevelEvent is the a toplevel has been created
type ZwlrForeignToplevelManagerV1ToplevelEvent struct {
	// Toplevel is the
	Toplevel *ZwlrForeignToplevelHandleV1
}
⋮----
// Toplevel is the
⋮----
// ZwlrForeignToplevelManagerV1FinishedEvent is the the compositor has finished with the toplevel manager
type ZwlrForeignToplevelManagerV1FinishedEvent struct{}
// ZwlrForeignToplevelManagerV1ToplevelHandler is the handler interface for ZwlrForeignToplevelManagerV1ToplevelEvent
type ZwlrForeignToplevelManagerV1ToplevelHandler interface {
	HandleZwlrForeignToplevelManagerV1Toplevel(ZwlrForeignToplevelManagerV1ToplevelEvent)
}
// AddToplevelHandler removes the Toplevel handler
func (p *ZwlrForeignToplevelManagerV1) AddToplevelHandler(h ZwlrForeignToplevelManagerV1ToplevelHandler)
// RemoveToplevelHandler adds the Toplevel handler
func (p *ZwlrForeignToplevelManagerV1) RemoveToplevelHandler(h ZwlrForeignToplevelManagerV1ToplevelHandler)
// ZwlrForeignToplevelManagerV1FinishedHandler is the handler interface for ZwlrForeignToplevelManagerV1FinishedEvent
type ZwlrForeignToplevelManagerV1FinishedHandler interface {
	HandleZwlrForeignToplevelManagerV1Finished(ZwlrForeignToplevelManagerV1FinishedEvent)
}
// AddFinishedHandler removes the Finished handler
func (p *ZwlrForeignToplevelManagerV1) AddFinishedHandler(h ZwlrForeignToplevelManagerV1FinishedHandler)
// RemoveFinishedHandler adds the Finished handler
func (p *ZwlrForeignToplevelManagerV1) RemoveFinishedHandler(h ZwlrForeignToplevelManagerV1FinishedHandler)
// ZwlrForeignToplevelHandleV1 an opened toplevel
type ZwlrForeignToplevelHandleV1 struct {
	wl.BaseProxy
	mu                                             sync.RWMutex
	privateZwlrForeignToplevelHandleV1Titles       []ZwlrForeignToplevelHandleV1TitleHandler
	privateZwlrForeignToplevelHandleV1AppIds       []ZwlrForeignToplevelHandleV1AppIdHandler
	privateZwlrForeignToplevelHandleV1OutputEnters []ZwlrForeignToplevelHandleV1OutputEnterHandler
	privateZwlrForeignToplevelHandleV1OutputLeaves []ZwlrForeignToplevelHandleV1OutputLeaveHandler
	privateZwlrForeignToplevelHandleV1States       []ZwlrForeignToplevelHandleV1StateHandler
	privateZwlrForeignToplevelHandleV1Dones        []ZwlrForeignToplevelHandleV1DoneHandler
	privateZwlrForeignToplevelHandleV1Closeds      []ZwlrForeignToplevelHandleV1ClosedHandler
	privateZwlrForeignToplevelHandleV1Parents      []ZwlrForeignToplevelHandleV1ParentHandler
}
// NewZwlrForeignToplevelHandleV1 is a constructor for the ZwlrForeignToplevelHandleV1 object
func NewZwlrForeignToplevelHandleV1(ctx *wl.Context) *ZwlrForeignToplevelHandleV1
// SetMaximized requests that the toplevel be maximized
func (p *ZwlrForeignToplevelHandleV1) SetMaximized() error
// UnsetMaximized requests that the toplevel be unmaximized
func (p *ZwlrForeignToplevelHandleV1) UnsetMaximized() error
// SetMinimized requests that the toplevel be minimized
func (p *ZwlrForeignToplevelHandleV1) SetMinimized() error
// UnsetMinimized requests that the toplevel be unminimized
func (p *ZwlrForeignToplevelHandleV1) UnsetMinimized() error
// Activate activate the toplevel
func (p *ZwlrForeignToplevelHandleV1) Activate(Seat *wl.Seat) error
// Close request that the toplevel be closed
func (p *ZwlrForeignToplevelHandleV1) Close() error
// SetRectangle the rectangle which represents the toplevel
func (p *ZwlrForeignToplevelHandleV1) SetRectangle(Surface *wl.Surface, X int32, Y int32, Width int32, Height int32) error
// Destroy destroy the zwlr_foreign_toplevel_handle_v1 object
func (p *ZwlrForeignToplevelHandleV1) Destroy() error
// SetFullscreen request that the toplevel be fullscreened
func (p *ZwlrForeignToplevelHandleV1) SetFullscreen(Output *wl.Output) error
// UnsetFullscreen request that the toplevel be unfullscreened
func (p *ZwlrForeignToplevelHandleV1) UnsetFullscreen() error
// Dispatch dispatches event for object ZwlrForeignToplevelHandleV1
⋮----
// ZwlrForeignToplevelHandleV1TitleEvent is the title change
type ZwlrForeignToplevelHandleV1TitleEvent struct {
	// Title is the
	Title string
}
⋮----
// Title is the
⋮----
// ZwlrForeignToplevelHandleV1AppIdEvent is the app-id change
type ZwlrForeignToplevelHandleV1AppIdEvent struct {
	// AppId is the
	AppId string
}
⋮----
// AppId is the
⋮----
// ZwlrForeignToplevelHandleV1OutputEnterEvent is the toplevel entered an output
type ZwlrForeignToplevelHandleV1OutputEnterEvent struct {
	// Output is the
	Output *wl.Output
}
⋮----
// Output is the
⋮----
// ZwlrForeignToplevelHandleV1OutputLeaveEvent is the toplevel left an output
type ZwlrForeignToplevelHandleV1OutputLeaveEvent struct {
	// Output is the
	Output *wl.Output
}
// ZwlrForeignToplevelHandleV1StateEvent is the the toplevel state changed
type ZwlrForeignToplevelHandleV1StateEvent struct {
	// State is the
	State []int32
}
⋮----
// State is the
⋮----
// ZwlrForeignToplevelHandleV1DoneEvent is the all information about the toplevel has been sent
type ZwlrForeignToplevelHandleV1DoneEvent struct{}
// ZwlrForeignToplevelHandleV1ClosedEvent is the this toplevel has been destroyed
type ZwlrForeignToplevelHandleV1ClosedEvent struct{}
// ZwlrForeignToplevelHandleV1ParentEvent is the parent change
type ZwlrForeignToplevelHandleV1ParentEvent struct {
	// Parent is the
	Parent *ZwlrForeignToplevelHandleV1
}
⋮----
// Parent is the
⋮----
// ZwlrForeignToplevelHandleV1TitleHandler is the handler interface for ZwlrForeignToplevelHandleV1TitleEvent
type ZwlrForeignToplevelHandleV1TitleHandler interface {
	HandleZwlrForeignToplevelHandleV1Title(ZwlrForeignToplevelHandleV1TitleEvent)
}
// AddTitleHandler removes the Title handler
func (p *ZwlrForeignToplevelHandleV1) AddTitleHandler(h ZwlrForeignToplevelHandleV1TitleHandler)
// RemoveTitleHandler adds the Title handler
func (p *ZwlrForeignToplevelHandleV1) RemoveTitleHandler(h ZwlrForeignToplevelHandleV1TitleHandler)
// ZwlrForeignToplevelHandleV1AppIdHandler is the handler interface for ZwlrForeignToplevelHandleV1AppIdEvent
type ZwlrForeignToplevelHandleV1AppIdHandler interface {
	HandleZwlrForeignToplevelHandleV1AppId(ZwlrForeignToplevelHandleV1AppIdEvent)
}
// AddAppIdHandler removes the AppId handler
func (p *ZwlrForeignToplevelHandleV1) AddAppIdHandler(h ZwlrForeignToplevelHandleV1AppIdHandler)
// RemoveAppIdHandler adds the AppId handler
func (p *ZwlrForeignToplevelHandleV1) RemoveAppIdHandler(h ZwlrForeignToplevelHandleV1AppIdHandler)
// ZwlrForeignToplevelHandleV1OutputEnterHandler is the handler interface for ZwlrForeignToplevelHandleV1OutputEnterEvent
type ZwlrForeignToplevelHandleV1OutputEnterHandler interface {
	HandleZwlrForeignToplevelHandleV1OutputEnter(ZwlrForeignToplevelHandleV1OutputEnterEvent)
}
// AddOutputEnterHandler removes the OutputEnter handler
func (p *ZwlrForeignToplevelHandleV1) AddOutputEnterHandler(h ZwlrForeignToplevelHandleV1OutputEnterHandler)
// RemoveOutputEnterHandler adds the OutputEnter handler
func (p *ZwlrForeignToplevelHandleV1) RemoveOutputEnterHandler(h ZwlrForeignToplevelHandleV1OutputEnterHandler)
// ZwlrForeignToplevelHandleV1OutputLeaveHandler is the handler interface for ZwlrForeignToplevelHandleV1OutputLeaveEvent
type ZwlrForeignToplevelHandleV1OutputLeaveHandler interface {
	HandleZwlrForeignToplevelHandleV1OutputLeave(ZwlrForeignToplevelHandleV1OutputLeaveEvent)
}
// AddOutputLeaveHandler removes the OutputLeave handler
func (p *ZwlrForeignToplevelHandleV1) AddOutputLeaveHandler(h ZwlrForeignToplevelHandleV1OutputLeaveHandler)
// RemoveOutputLeaveHandler adds the OutputLeave handler
func (p *ZwlrForeignToplevelHandleV1) RemoveOutputLeaveHandler(h ZwlrForeignToplevelHandleV1OutputLeaveHandler)
// ZwlrForeignToplevelHandleV1StateHandler is the handler interface for ZwlrForeignToplevelHandleV1StateEvent
type ZwlrForeignToplevelHandleV1StateHandler interface {
	HandleZwlrForeignToplevelHandleV1State(ZwlrForeignToplevelHandleV1StateEvent)
}
// AddStateHandler removes the State handler
func (p *ZwlrForeignToplevelHandleV1) AddStateHandler(h ZwlrForeignToplevelHandleV1StateHandler)
// RemoveStateHandler adds the State handler
func (p *ZwlrForeignToplevelHandleV1) RemoveStateHandler(h ZwlrForeignToplevelHandleV1StateHandler)
// ZwlrForeignToplevelHandleV1DoneHandler is the handler interface for ZwlrForeignToplevelHandleV1DoneEvent
type ZwlrForeignToplevelHandleV1DoneHandler interface {
	HandleZwlrForeignToplevelHandleV1Done(ZwlrForeignToplevelHandleV1DoneEvent)
}
// AddDoneHandler removes the Done handler
func (p *ZwlrForeignToplevelHandleV1) AddDoneHandler(h ZwlrForeignToplevelHandleV1DoneHandler)
// RemoveDoneHandler adds the Done handler
func (p *ZwlrForeignToplevelHandleV1) RemoveDoneHandler(h ZwlrForeignToplevelHandleV1DoneHandler)
// ZwlrForeignToplevelHandleV1ClosedHandler is the handler interface for ZwlrForeignToplevelHandleV1ClosedEvent
type ZwlrForeignToplevelHandleV1ClosedHandler interface {
	HandleZwlrForeignToplevelHandleV1Closed(ZwlrForeignToplevelHandleV1ClosedEvent)
}
// AddClosedHandler removes the Closed handler
func (p *ZwlrForeignToplevelHandleV1) AddClosedHandler(h ZwlrForeignToplevelHandleV1ClosedHandler)
// RemoveClosedHandler adds the Closed handler
func (p *ZwlrForeignToplevelHandleV1) RemoveClosedHandler(h ZwlrForeignToplevelHandleV1ClosedHandler)
// ZwlrForeignToplevelHandleV1ParentHandler is the handler interface for ZwlrForeignToplevelHandleV1ParentEvent
type ZwlrForeignToplevelHandleV1ParentHandler interface {
	HandleZwlrForeignToplevelHandleV1Parent(ZwlrForeignToplevelHandleV1ParentEvent)
}
// AddParentHandler removes the Parent handler
func (p *ZwlrForeignToplevelHandleV1) AddParentHandler(h ZwlrForeignToplevelHandleV1ParentHandler)
// RemoveParentHandler adds the Parent handler
func (p *ZwlrForeignToplevelHandleV1) RemoveParentHandler(h ZwlrForeignToplevelHandleV1ParentHandler)
```

## File: pkg/common/wlr/wm.go

```go
package wlr
import (
	"log/slog"
	"sync"
	"time"
	"github.com/neurlang/wayland/wl"
	"github.com/neurlang/wayland/wlclient"
)
⋮----
"log/slog"
"sync"
"time"
"github.com/neurlang/wayland/wl"
"github.com/neurlang/wayland/wlclient"
⋮----
var (
	registry *wl.Registry
	display  *wl.Display
	seat     []*wl.Seat
)
type windowmap map[wl.ProxyId]*Window
var windows = make(windowmap)
var IsRunning = false
func Windows() windowmap
func Activate(id wl.ProxyId) error
var (
	IsSetup bool
	mu      sync.Mutex
)
func Init()
func start() error
⋮----
var err error
⋮----
type displayErrorHandler struct{}
func (displayErrorHandler) HandleDisplayError(e wl.DisplayErrorEvent)
type registryGlobalHandler struct{}
func (registryGlobalHandler) HandleRegistryGlobal(e wl.RegistryGlobalEvent)
type Window struct {
	mutex      sync.Mutex
	Toplevel   *ZwlrForeignToplevelHandleV1
	AppID      string
	Title      string
	AddChan    chan string
	DeleteChan chan string
}
func (*Window) HandleZwlrForeignToplevelManagerV1Toplevel(e ZwlrForeignToplevelManagerV1ToplevelEvent)
func (h *Window) HandleZwlrForeignToplevelHandleV1Closed(e ZwlrForeignToplevelHandleV1ClosedEvent)
func (h *Window) HandleZwlrForeignToplevelHandleV1AppId(e ZwlrForeignToplevelHandleV1AppIdEvent)
func (h *Window) HandleZwlrForeignToplevelHandleV1Title(e ZwlrForeignToplevelHandleV1TitleEvent)
```

## File: pkg/common/config.go

```go
// Package common provides common functions used by all providers.
package common
import (
	"log/slog"
	"os"
	"path/filepath"
	"github.com/joho/godotenv"
	"github.com/knadh/koanf/parsers/toml/v2"
	"github.com/knadh/koanf/providers/file"
	"github.com/knadh/koanf/providers/structs"
	"github.com/knadh/koanf/v2"
)
⋮----
"log/slog"
"os"
"path/filepath"
"github.com/joho/godotenv"
"github.com/knadh/koanf/parsers/toml/v2"
"github.com/knadh/koanf/providers/file"
"github.com/knadh/koanf/providers/structs"
"github.com/knadh/koanf/v2"
⋮----
type Config struct {
	Icon                 string `koanf:"icon" desc:"icon for provider" default:"depends on provider"`
	NamePretty           string `koanf:"name_pretty" desc:"displayed name for the provider" default:"depends on provider"`
	MinScore             int32  `koanf:"min_score" desc:"minimum score for items to be displayed" default:"depends on provider"`
	HideFromProviderlist bool   `koanf:"hide_from_providerlist" desc:"hides a provider from the providerlist provider. provider provider." default:"false"`
}
type Command struct {
	MustSucceed bool   `koanf:"must_succeed" desc:"will try running this command until it completes successfully" default:"false"`
	Command     string `koanf:"command" desc:"command to execute" default:""`
}
type ElephantConfig struct {
	AutoDetectLaunchPrefix bool      `koanf:"auto_detect_launch_prefix" desc:"automatically detects uwsm, app2unit or systemd-run" default:"true"`
	OverloadLocalEnv       bool      `koanf:"overload_local_env" desc:"overloads the local env" default:"false"`
	IgnoredProviders       []string  `koanf:"ignored_providers" desc:"providers to ignore" default:"<empty>"`
	GitOnDemand            bool      `koanf:"git_on_demand" desc:"sets up git repositories on first query instead of on start" default:"true"`
	BeforeLoad             []Command `koanf:"before_load" desc:"commands to run before starting to load the providers" default:""`
}
var elephantConfig *ElephantConfig
func LoadGlobalConfig()
⋮----
var err error
⋮----
func GetElephantConfig() *ElephantConfig
func LoadConfig(provider string, config any)
```

## File: pkg/common/files.go

```go
package common
import (
	"errors"
	"fmt"
	"log/slog"
	"os"
	"path/filepath"
	"github.com/adrg/xdg"
)
⋮----
"errors"
"fmt"
"log/slog"
"os"
"path/filepath"
"github.com/adrg/xdg"
⋮----
var explicitDir string
func SetExplicitDir(dir string)
func TmpDir() string
func ConfigDirs() []string
func CacheFile(file string) string
var ErrConfigNotExists = errors.New("provider config doesn't exist")
func ProviderConfig(provider string) (string, error)
func FileExists(filename string) bool
```

## File: pkg/common/fzf.go

```go
package common
import (
	"slices"
	"unicode"
	"github.com/junegunn/fzf/src/algo"
	"github.com/junegunn/fzf/src/util"
)
⋮----
"slices"
"unicode"
"github.com/junegunn/fzf/src/algo"
"github.com/junegunn/fzf/src/util"
⋮----
func init()
func FuzzyScore(input, target string, exact bool) (int32, []int32, int32)
⋮----
var res algo.Result
var pos *[]int
⋮----
var int32Slice []int32
```

## File: pkg/common/git.go

```go
package common
import (
	"fmt"
	"log/slog"
	"path/filepath"
	"strings"
	"sync"
	"time"
	"github.com/abenz1267/elephant/pkg/common"
	"github.com/go-git/go-git/v6"
)
⋮----
"fmt"
"log/slog"
"path/filepath"
"strings"
"sync"
"time"
"github.com/abenz1267/elephant/pkg/common"
"github.com/go-git/go-git/v6"
⋮----
var (
	gitMu      sync.Mutex
	setupRepos = make(map[string]Repo)
type Repo struct {
	w *git.Worktree
	r *git.Repository
}
type Gittable interface {
	SetLocation(string)
	URL() string
	SetWorktree(*git.Worktree)
	SetRepository(*git.Repository)
}
func SetupGit(provider string, cfg Gittable)
⋮----
var w *git.Worktree
var r *git.Repository
var pull bool
⋮----
// clone
⋮----
var err error
⋮----
type PushData struct {
	provider string
	file     string
	w        *git.Worktree
	r        *git.Repository
}
var pushChan chan PushData
func init()
⋮----
var mu sync.Mutex
⋮----
// TODO: this needs better commit messages somehow...
func GitPush(provider, file string, w *git.Worktree, r *git.Repository)
```

## File: pkg/common/menucfg.go

```go
package common
import (
	"crypto/md5"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io/fs"
	"log/slog"
	"os"
	"path/filepath"
	"sync"
	"time"
	"github.com/adrg/xdg"
	"github.com/charlievieth/fastwalk"
	"github.com/fsnotify/fsnotify"
	"github.com/pelletier/go-toml/v2"
	lua "github.com/yuin/gopher-lua"
)
⋮----
"crypto/md5"
"encoding/hex"
"encoding/json"
"fmt"
"io/fs"
"log/slog"
"os"
"path/filepath"
"sync"
"time"
"github.com/adrg/xdg"
"github.com/charlievieth/fastwalk"
"github.com/fsnotify/fsnotify"
"github.com/pelletier/go-toml/v2"
lua "github.com/yuin/gopher-lua"
⋮----
var (
	states  = make(map[string][]string)
type MenuConfig struct {
	Config `koanf:",squash"`
	Paths  []string `koanf:"paths" desc:"additional paths to check for menu definitions." default:""`
}
type Menu struct {
	HideFromProviderlist bool              `toml:"hide_from_providerlist" desc:"hides a provider from the providerlist provider. provider provider." default:"false"`
	Name                 string            `toml:"name" desc:"name of the menu"`
	NamePretty           string            `toml:"name_pretty" desc:"prettier name you usually want to display to the user."`
	Description          string            `toml:"description" desc:"used as a subtext"`
	Icon                 string            `toml:"icon" desc:"default icon"`
	Action               string            `toml:"action" desc:"default menu action to use"`
	Actions              map[string]string `toml:"actions" desc:"global actions"`
	AsyncActions         []string          `toml:"async_actions" desc:"set which actions should update the item on the client asynchronously"`
	SearchName           bool              `toml:"search_name" desc:"wether to search for the menu name as well when searching globally" default:"false"`
	Cache                bool              `toml:"cache" desc:"will cache the results of the lua script on startup"`
	RefreshOnChange      []string          `toml:"refresh_on_change" desc:"will enable cache and auto-refresh the cache if there's file changes on the specified files/folders"`
	Entries              []Entry           `toml:"entries" desc:"menu items"`
	Terminal             bool              `toml:"terminal" desc:"execute action in terminal or not"`
	Keywords             []string          `toml:"keywords" desc:"searchable keywords"`
	FixedOrder           bool              `toml:"fixed_order" desc:"don't sort entries alphabetically"`
	History              bool              `toml:"history" desc:"make use of history for sorting"`
	HistoryWhenEmpty     bool              `toml:"history_when_empty" desc:"consider history when query is empty"`
	MinScore             int32             `toml:"min_score" desc:"minimum score for items to be displayed" default:"depends on provider"`
	Parent               string            `toml:"parent" desc:"defines the parent menu" default:""`
	SubMenu              string            `toml:"submenu" desc:"defines submenu to trigger on activation" default:""`
	// internal
	LuaString string
	IsLua     bool `toml:"-"`
}
⋮----
// internal
⋮----
func (m *Menu) NewLuaState() *lua.LState
func (m *Menu) watch()
var (
	LastMenuValue    = make(map[string]string)
func GetLastMenuValue(L *lua.LState) int
func (m *Menu) SetState(L *lua.LState) int
func (m *Menu) GetState(L *lua.LState) int
func JSONEncode(L *lua.LState) int
func JSONDecode(L *lua.LState) int
⋮----
var result any
⋮----
func luaValueToGo(val lua.LValue) any
⋮----
// Check if it's an array or object
⋮----
// It's an array
⋮----
// It's an object
⋮----
func goValueToLua(L *lua.LState, val any) lua.LValue
func (m *Menu) CreateLuaEntries(query string)
type Entry struct {
	Text        string            `toml:"text" desc:"text for entry"`
	Async       string            `toml:"async" desc:"if the text should be updated asynchronously based on the action"`
	Subtext     string            `toml:"subtext" desc:"sub text for entry"`
	Value       string            `toml:"value" desc:"value to be used for the action."`
	Actions     map[string]string `toml:"actions" desc:"actions items can use"`
	Terminal    bool              `toml:"terminal" desc:"runs action in terminal if true"`
	Icon        string            `toml:"icon" desc:"icon for entry"`
	SubMenu     string            `toml:"submenu" desc:"submenu to open, if has prefix 'dmenu:' it'll launch that dmenu"`
	Preview     string            `toml:"preview" desc:"filepath for the preview"`
	PreviewType string            `toml:"preview_type" desc:"type of the preview: text, file [default], command"`
	Keywords    []string          `toml:"keywords" desc:"searchable keywords"`
	State       []string          `toml:"state" desc:"state of an item, can be used to f.e. mark it as current"`
	Identifier string `toml:"-"`
	Menu       string `toml:"-"`
}
func (e Entry) CreateIdentifier() string
var (
	MenuConfigLoaded MenuConfig
	menuname         = "menus"
	Menus            = make(map[string]*Menu)
func LoadMenus()
func createLuaMenu(path string)
func createTomlMenu(path string)
```

## File: pkg/common/runprefix.go

```go
package common
import (
	"log/slog"
	"os"
	"os/exec"
)
⋮----
"log/slog"
"os"
"os/exec"
⋮----
var runPrefix = ""
func InitRunPrefix()
func LaunchPrefix(override string) string
```

## File: pkg/common/terminal.go

```go
package common
import (
	"bytes"
	"fmt"
	"io/fs"
	"log"
	"log/slog"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"github.com/adrg/xdg"
	"github.com/charlievieth/fastwalk"
)
⋮----
"bytes"
"fmt"
"io/fs"
"log"
"log/slog"
"os"
"os/exec"
"path/filepath"
"strings"
"syscall"
"github.com/adrg/xdg"
"github.com/charlievieth/fastwalk"
⋮----
var terminal = ""
var terminalApps = make(map[string]struct{})
func init()
func GetTerminal() string
func WrapWithTerminal(in string) string
func findTerminalApps()
func ForceTerminalForFile(file string) bool
```

## File: pkg/common/util.go

```go
package common
import (
	"log/slog"
	"os/exec"
	"strings"
)
⋮----
"log/slog"
"os/exec"
"strings"
⋮----
func ReplaceResultOrStdinCmd(replace, result string) *exec.Cmd
func ClipboardText() string
```

## File: pkg/pb/pb/activate.pb.go

```go
// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.36.7
// 	protoc        v6.32.1
// source: activate.proto
package pb
import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
	unsafe "unsafe"
)
⋮----
protoreflect "google.golang.org/protobuf/reflect/protoreflect"
protoimpl "google.golang.org/protobuf/runtime/protoimpl"
reflect "reflect"
sync "sync"
unsafe "unsafe"
⋮----
const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
⋮----
// Verify that this generated code is sufficiently up-to-date.
⋮----
// Verify that runtime/protoimpl is sufficiently up-to-date.
⋮----
type ActivateRequest struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Provider      string                 `protobuf:"bytes,1,opt,name=provider,proto3" json:"provider,omitempty"`
	Identifier    string                 `protobuf:"bytes,2,opt,name=identifier,proto3" json:"identifier,omitempty"`
	Action        string                 `protobuf:"bytes,3,opt,name=action,proto3" json:"action,omitempty"`
	Query         string                 `protobuf:"bytes,4,opt,name=query,proto3" json:"query,omitempty"`
	Arguments     string                 `protobuf:"bytes,5,opt,name=arguments,proto3" json:"arguments,omitempty"`
	Single        bool                   `protobuf:"varint,6,opt,name=single,proto3" json:"single,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}
func (x *ActivateRequest) Reset()
func (x *ActivateRequest) String() string
func (*ActivateRequest) ProtoMessage()
func (x *ActivateRequest) ProtoReflect() protoreflect.Message
// Deprecated: Use ActivateRequest.ProtoReflect.Descriptor instead.
func (*ActivateRequest) Descriptor() ([]byte, []int)
func (x *ActivateRequest) GetProvider() string
func (x *ActivateRequest) GetIdentifier() string
func (x *ActivateRequest) GetAction() string
func (x *ActivateRequest) GetQuery() string
func (x *ActivateRequest) GetArguments() string
func (x *ActivateRequest) GetSingle() bool
var File_activate_proto protoreflect.FileDescriptor
const file_activate_proto_rawDesc = "" +
	"\n" +
	"\x0eactivate.proto\x12\x02pb\"\xb1\x01\n" +
	"\x0fActivateRequest\x12\x1a\n" +
	"\bprovider\x18\x01 \x01(\tR\bprovider\x12\x1e\n" +
	"\n" +
	"identifier\x18\x02 \x01(\tR\n" +
	"identifier\x12\x16\n" +
	"\x06action\x18\x03 \x01(\tR\x06action\x12\x14\n" +
	"\x05query\x18\x04 \x01(\tR\x05query\x12\x1c\n" +
	"\targuments\x18\x05 \x01(\tR\targuments\x12\x16\n" +
	"\x06single\x18\x06 \x01(\bR\x06singleB\x06Z\x04./pbb\x06proto3"
var (
	file_activate_proto_rawDescOnce sync.Once
	file_activate_proto_rawDescData []byte
)
func file_activate_proto_rawDescGZIP() []byte
var file_activate_proto_msgTypes = make([]protoimpl.MessageInfo, 1)
var file_activate_proto_goTypes = []any{
	(*ActivateRequest)(nil), // 0: pb.ActivateRequest
}
⋮----
(*ActivateRequest)(nil), // 0: pb.ActivateRequest
⋮----
var file_activate_proto_depIdxs = []int32{
	0, // [0:0] is the sub-list for method output_type
	0, // [0:0] is the sub-list for method input_type
	0, // [0:0] is the sub-list for extension type_name
	0, // [0:0] is the sub-list for extension extendee
	0, // [0:0] is the sub-list for field type_name
}
⋮----
0, // [0:0] is the sub-list for method output_type
0, // [0:0] is the sub-list for method input_type
0, // [0:0] is the sub-list for extension type_name
0, // [0:0] is the sub-list for extension extendee
0, // [0:0] is the sub-list for field type_name
⋮----
func init()
func file_activate_proto_init()
⋮----
type x struct{}
```

## File: pkg/pb/pb/menu.pb.go

```go
// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.36.7
// 	protoc        v6.32.1
// source: menu.proto
package pb
import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
	unsafe "unsafe"
)
⋮----
protoreflect "google.golang.org/protobuf/reflect/protoreflect"
protoimpl "google.golang.org/protobuf/runtime/protoimpl"
reflect "reflect"
sync "sync"
unsafe "unsafe"
⋮----
const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
⋮----
// Verify that this generated code is sufficiently up-to-date.
⋮----
// Verify that runtime/protoimpl is sufficiently up-to-date.
⋮----
type MenuRequest struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Menu          string                 `protobuf:"bytes,1,opt,name=menu,proto3" json:"menu,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}
func (x *MenuRequest) Reset()
func (x *MenuRequest) String() string
func (*MenuRequest) ProtoMessage()
func (x *MenuRequest) ProtoReflect() protoreflect.Message
// Deprecated: Use MenuRequest.ProtoReflect.Descriptor instead.
func (*MenuRequest) Descriptor() ([]byte, []int)
func (x *MenuRequest) GetMenu() string
var File_menu_proto protoreflect.FileDescriptor
const file_menu_proto_rawDesc = "" +
	"\n" +
	"\n" +
	"menu.proto\x12\x02pb\"!\n" +
	"\vMenuRequest\x12\x12\n" +
	"\x04menu\x18\x01 \x01(\tR\x04menuB\x06Z\x04./pbb\x06proto3"
var (
	file_menu_proto_rawDescOnce sync.Once
	file_menu_proto_rawDescData []byte
)
func file_menu_proto_rawDescGZIP() []byte
var file_menu_proto_msgTypes = make([]protoimpl.MessageInfo, 1)
var file_menu_proto_goTypes = []any{
	(*MenuRequest)(nil), // 0: pb.MenuRequest
}
⋮----
(*MenuRequest)(nil), // 0: pb.MenuRequest
⋮----
var file_menu_proto_depIdxs = []int32{
	0, // [0:0] is the sub-list for method output_type
	0, // [0:0] is the sub-list for method input_type
	0, // [0:0] is the sub-list for extension type_name
	0, // [0:0] is the sub-list for extension extendee
	0, // [0:0] is the sub-list for field type_name
}
⋮----
0, // [0:0] is the sub-list for method output_type
0, // [0:0] is the sub-list for method input_type
0, // [0:0] is the sub-list for extension type_name
0, // [0:0] is the sub-list for extension extendee
0, // [0:0] is the sub-list for field type_name
⋮----
func init()
func file_menu_proto_init()
⋮----
type x struct{}
```

## File: pkg/pb/pb/providerstate.pb.go

```go
// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.36.7
// 	protoc        v6.32.1
// source: providerstate.proto
package pb
import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
	unsafe "unsafe"
)
⋮----
protoreflect "google.golang.org/protobuf/reflect/protoreflect"
protoimpl "google.golang.org/protobuf/runtime/protoimpl"
reflect "reflect"
sync "sync"
unsafe "unsafe"
⋮----
const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
⋮----
// Verify that this generated code is sufficiently up-to-date.
⋮----
// Verify that runtime/protoimpl is sufficiently up-to-date.
⋮----
type ProviderStateRequest struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Provider      string                 `protobuf:"bytes,1,opt,name=provider,proto3" json:"provider,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}
func (x *ProviderStateRequest) Reset()
func (x *ProviderStateRequest) String() string
func (*ProviderStateRequest) ProtoMessage()
func (x *ProviderStateRequest) ProtoReflect() protoreflect.Message
// Deprecated: Use ProviderStateRequest.ProtoReflect.Descriptor instead.
func (*ProviderStateRequest) Descriptor() ([]byte, []int)
func (x *ProviderStateRequest) GetProvider() string
type ProviderStateResponse struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	States        []string               `protobuf:"bytes,1,rep,name=states,proto3" json:"states,omitempty"`
	Actions       []string               `protobuf:"bytes,2,rep,name=actions,proto3" json:"actions,omitempty"`
	Provider      string                 `protobuf:"bytes,3,opt,name=provider,proto3" json:"provider,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}
⋮----
// Deprecated: Use ProviderStateResponse.ProtoReflect.Descriptor instead.
⋮----
func (x *ProviderStateResponse) GetStates() []string
func (x *ProviderStateResponse) GetActions() []string
⋮----
var File_providerstate_proto protoreflect.FileDescriptor
const file_providerstate_proto_rawDesc = "" +
	"\n" +
	"\x13providerstate.proto\x12\x02pb\"2\n" +
	"\x14ProviderStateRequest\x12\x1a\n" +
	"\bprovider\x18\x01 \x01(\tR\bprovider\"e\n" +
	"\x15ProviderStateResponse\x12\x16\n" +
	"\x06states\x18\x01 \x03(\tR\x06states\x12\x18\n" +
	"\aactions\x18\x02 \x03(\tR\aactions\x12\x1a\n" +
	"\bprovider\x18\x03 \x01(\tR\bproviderB\x06Z\x04./pbb\x06proto3"
var (
	file_providerstate_proto_rawDescOnce sync.Once
	file_providerstate_proto_rawDescData []byte
)
func file_providerstate_proto_rawDescGZIP() []byte
var file_providerstate_proto_msgTypes = make([]protoimpl.MessageInfo, 2)
var file_providerstate_proto_goTypes = []any{
	(*ProviderStateRequest)(nil),  // 0: pb.ProviderStateRequest
	(*ProviderStateResponse)(nil), // 1: pb.ProviderStateResponse
}
⋮----
(*ProviderStateRequest)(nil),  // 0: pb.ProviderStateRequest
(*ProviderStateResponse)(nil), // 1: pb.ProviderStateResponse
⋮----
var file_providerstate_proto_depIdxs = []int32{
	0, // [0:0] is the sub-list for method output_type
	0, // [0:0] is the sub-list for method input_type
	0, // [0:0] is the sub-list for extension type_name
	0, // [0:0] is the sub-list for extension extendee
	0, // [0:0] is the sub-list for field type_name
}
⋮----
0, // [0:0] is the sub-list for method output_type
0, // [0:0] is the sub-list for method input_type
0, // [0:0] is the sub-list for extension type_name
0, // [0:0] is the sub-list for extension extendee
0, // [0:0] is the sub-list for field type_name
⋮----
func init()
func file_providerstate_proto_init()
⋮----
type x struct{}
```

## File: pkg/pb/pb/query.pb.go

```go
// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.36.7
// 	protoc        v6.32.1
// source: query.proto
package pb
import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
	unsafe "unsafe"
)
⋮----
protoreflect "google.golang.org/protobuf/reflect/protoreflect"
protoimpl "google.golang.org/protobuf/runtime/protoimpl"
reflect "reflect"
sync "sync"
unsafe "unsafe"
⋮----
const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
⋮----
// Verify that this generated code is sufficiently up-to-date.
⋮----
// Verify that runtime/protoimpl is sufficiently up-to-date.
⋮----
type QueryResponse_Type int32
const (
	QueryResponse_REGULAR QueryResponse_Type = 0
	QueryResponse_FILE    QueryResponse_Type = 1
)
// Enum value maps for QueryResponse_Type.
var (
	QueryResponse_Type_name = map[int32]string{
		0: "REGULAR",
		1: "FILE",
	}
	QueryResponse_Type_value = map[string]int32{
		"REGULAR": 0,
		"FILE":    1,
	}
)
func (x QueryResponse_Type) Enum() *QueryResponse_Type
func (x QueryResponse_Type) String() string
func (QueryResponse_Type) Descriptor() protoreflect.EnumDescriptor
func (QueryResponse_Type) Type() protoreflect.EnumType
func (x QueryResponse_Type) Number() protoreflect.EnumNumber
// Deprecated: Use QueryResponse_Type.Descriptor instead.
func (QueryResponse_Type) EnumDescriptor() ([]byte, []int)
type QueryRequest struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Providers     []string               `protobuf:"bytes,1,rep,name=providers,proto3" json:"providers,omitempty"`
	Query         string                 `protobuf:"bytes,2,opt,name=query,proto3" json:"query,omitempty"`
	Maxresults    int32                  `protobuf:"varint,3,opt,name=maxresults,proto3" json:"maxresults,omitempty"`
	Exactsearch   bool                   `protobuf:"varint,4,opt,name=exactsearch,proto3" json:"exactsearch,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}
func (x *QueryRequest) Reset()
⋮----
func (*QueryRequest) ProtoMessage()
func (x *QueryRequest) ProtoReflect() protoreflect.Message
// Deprecated: Use QueryRequest.ProtoReflect.Descriptor instead.
⋮----
func (x *QueryRequest) GetProviders() []string
func (x *QueryRequest) GetQuery() string
func (x *QueryRequest) GetMaxresults() int32
func (x *QueryRequest) GetExactsearch() bool
type QueryResponse struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Query         string                 `protobuf:"bytes,1,opt,name=query,proto3" json:"query,omitempty"`
	Item          *QueryResponse_Item    `protobuf:"bytes,2,opt,name=item,proto3" json:"item,omitempty"`
	Qid           int32                  `protobuf:"varint,3,opt,name=qid,proto3" json:"qid,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}
⋮----
// Deprecated: Use QueryResponse.ProtoReflect.Descriptor instead.
⋮----
func (x *QueryResponse) GetItem() *QueryResponse_Item
func (x *QueryResponse) GetQid() int32
type QueryResponse_Item struct {
	state         protoimpl.MessageState        `protogen:"open.v1"`
	Identifier    string                        `protobuf:"bytes,1,opt,name=identifier,proto3" json:"identifier,omitempty"`
	Text          string                        `protobuf:"bytes,2,opt,name=text,proto3" json:"text,omitempty"`
	Subtext       string                        `protobuf:"bytes,3,opt,name=subtext,proto3" json:"subtext,omitempty"`
	Icon          string                        `protobuf:"bytes,4,opt,name=icon,proto3" json:"icon,omitempty"`
	Provider      string                        `protobuf:"bytes,5,opt,name=provider,proto3" json:"provider,omitempty"`
	Score         int32                         `protobuf:"varint,6,opt,name=score,proto3" json:"score,omitempty"`
	Fuzzyinfo     *QueryResponse_Item_FuzzyInfo `protobuf:"bytes,7,opt,name=fuzzyinfo,proto3" json:"fuzzyinfo,omitempty"`
	Type          QueryResponse_Type            `protobuf:"varint,8,opt,name=type,proto3,enum=pb.QueryResponse_Type" json:"type,omitempty"`
	Mimetype      string                        `protobuf:"bytes,9,opt,name=mimetype,proto3" json:"mimetype,omitempty"`
	Preview       string                        `protobuf:"bytes,10,opt,name=preview,proto3" json:"preview,omitempty"`
	PreviewType   string                        `protobuf:"bytes,11,opt,name=preview_type,json=previewType,proto3" json:"preview_type,omitempty"`
	State         []string                      `protobuf:"bytes,12,rep,name=state,proto3" json:"state,omitempty"`
	Actions       []string                      `protobuf:"bytes,13,rep,name=actions,proto3" json:"actions,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}
⋮----
// Deprecated: Use QueryResponse_Item.ProtoReflect.Descriptor instead.
⋮----
func (x *QueryResponse_Item) GetIdentifier() string
func (x *QueryResponse_Item) GetText() string
func (x *QueryResponse_Item) GetSubtext() string
func (x *QueryResponse_Item) GetIcon() string
func (x *QueryResponse_Item) GetProvider() string
func (x *QueryResponse_Item) GetScore() int32
func (x *QueryResponse_Item) GetFuzzyinfo() *QueryResponse_Item_FuzzyInfo
func (x *QueryResponse_Item) GetType() QueryResponse_Type
func (x *QueryResponse_Item) GetMimetype() string
func (x *QueryResponse_Item) GetPreview() string
func (x *QueryResponse_Item) GetPreviewType() string
func (x *QueryResponse_Item) GetState() []string
func (x *QueryResponse_Item) GetActions() []string
type QueryResponse_Item_FuzzyInfo struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Start         int32                  `protobuf:"varint,1,opt,name=start,proto3" json:"start,omitempty"`
	Field         string                 `protobuf:"bytes,2,opt,name=field,proto3" json:"field,omitempty"`
	Positions     []int32                `protobuf:"varint,3,rep,packed,name=positions,proto3" json:"positions,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}
⋮----
// Deprecated: Use QueryResponse_Item_FuzzyInfo.ProtoReflect.Descriptor instead.
⋮----
func (x *QueryResponse_Item_FuzzyInfo) GetStart() int32
func (x *QueryResponse_Item_FuzzyInfo) GetField() string
func (x *QueryResponse_Item_FuzzyInfo) GetPositions() []int32
var File_query_proto protoreflect.FileDescriptor
const file_query_proto_rawDesc = "" +
	"\n" +
	"\vquery.proto\x12\x02pb\"\x84\x01\n" +
	"\fQueryRequest\x12\x1c\n" +
	"\tproviders\x18\x01 \x03(\tR\tproviders\x12\x14\n" +
	"\x05query\x18\x02 \x01(\tR\x05query\x12\x1e\n" +
	"\n" +
	"maxresults\x18\x03 \x01(\x05R\n" +
	"maxresults\x12 \n" +
	"\vexactsearch\x18\x04 \x01(\bR\vexactsearch\"\xeb\x04\n" +
	"\rQueryResponse\x12\x14\n" +
	"\x05query\x18\x01 \x01(\tR\x05query\x12*\n" +
	"\x04item\x18\x02 \x01(\v2\x16.pb.QueryResponse.ItemR\x04item\x12\x10\n" +
	"\x03qid\x18\x03 \x01(\x05R\x03qid\x1a\xe6\x03\n" +
	"\x04Item\x12\x1e\n" +
	"\n" +
	"identifier\x18\x01 \x01(\tR\n" +
	"identifier\x12\x12\n" +
	"\x04text\x18\x02 \x01(\tR\x04text\x12\x18\n" +
	"\asubtext\x18\x03 \x01(\tR\asubtext\x12\x12\n" +
	"\x04icon\x18\x04 \x01(\tR\x04icon\x12\x1a\n" +
	"\bprovider\x18\x05 \x01(\tR\bprovider\x12\x14\n" +
	"\x05score\x18\x06 \x01(\x05R\x05score\x12>\n" +
	"\tfuzzyinfo\x18\a \x01(\v2 .pb.QueryResponse.Item.FuzzyInfoR\tfuzzyinfo\x12*\n" +
	"\x04type\x18\b \x01(\x0e2\x16.pb.QueryResponse.TypeR\x04type\x12\x1a\n" +
	"\bmimetype\x18\t \x01(\tR\bmimetype\x12\x18\n" +
	"\apreview\x18\n" +
	" \x01(\tR\apreview\x12!\n" +
	"\fpreview_type\x18\v \x01(\tR\vpreviewType\x12\x14\n" +
	"\x05state\x18\f \x03(\tR\x05state\x12\x18\n" +
	"\aactions\x18\r \x03(\tR\aactions\x1aU\n" +
	"\tFuzzyInfo\x12\x14\n" +
	"\x05start\x18\x01 \x01(\x05R\x05start\x12\x14\n" +
	"\x05field\x18\x02 \x01(\tR\x05field\x12\x1c\n" +
	"\tpositions\x18\x03 \x03(\x05R\tpositions\"\x1d\n" +
	"\x04Type\x12\v\n" +
	"\aREGULAR\x10\x00\x12\b\n" +
	"\x04FILE\x10\x01B\x06Z\x04./pbb\x06proto3"
var (
	file_query_proto_rawDescOnce sync.Once
	file_query_proto_rawDescData []byte
)
func file_query_proto_rawDescGZIP() []byte
var file_query_proto_enumTypes = make([]protoimpl.EnumInfo, 1)
var file_query_proto_msgTypes = make([]protoimpl.MessageInfo, 4)
var file_query_proto_goTypes = []any{
	(QueryResponse_Type)(0),              // 0: pb.QueryResponse.Type
	(*QueryRequest)(nil),                 // 1: pb.QueryRequest
	(*QueryResponse)(nil),                // 2: pb.QueryResponse
	(*QueryResponse_Item)(nil),           // 3: pb.QueryResponse.Item
	(*QueryResponse_Item_FuzzyInfo)(nil), // 4: pb.QueryResponse.Item.FuzzyInfo
}
⋮----
(QueryResponse_Type)(0),              // 0: pb.QueryResponse.Type
(*QueryRequest)(nil),                 // 1: pb.QueryRequest
(*QueryResponse)(nil),                // 2: pb.QueryResponse
(*QueryResponse_Item)(nil),           // 3: pb.QueryResponse.Item
(*QueryResponse_Item_FuzzyInfo)(nil), // 4: pb.QueryResponse.Item.FuzzyInfo
⋮----
var file_query_proto_depIdxs = []int32{
	3, // 0: pb.QueryResponse.item:type_name -> pb.QueryResponse.Item
	4, // 1: pb.QueryResponse.Item.fuzzyinfo:type_name -> pb.QueryResponse.Item.FuzzyInfo
	0, // 2: pb.QueryResponse.Item.type:type_name -> pb.QueryResponse.Type
	3, // [3:3] is the sub-list for method output_type
	3, // [3:3] is the sub-list for method input_type
	3, // [3:3] is the sub-list for extension type_name
	3, // [3:3] is the sub-list for extension extendee
	0, // [0:3] is the sub-list for field type_name
}
⋮----
3, // 0: pb.QueryResponse.item:type_name -> pb.QueryResponse.Item
4, // 1: pb.QueryResponse.Item.fuzzyinfo:type_name -> pb.QueryResponse.Item.FuzzyInfo
0, // 2: pb.QueryResponse.Item.type:type_name -> pb.QueryResponse.Type
3, // [3:3] is the sub-list for method output_type
3, // [3:3] is the sub-list for method input_type
3, // [3:3] is the sub-list for extension type_name
3, // [3:3] is the sub-list for extension extendee
0, // [0:3] is the sub-list for field type_name
⋮----
func init()
func file_query_proto_init()
⋮----
type x struct{}
```

## File: pkg/pb/pb/subscribe.pb.go

```go
// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.36.7
// 	protoc        v6.32.1
// source: subscribe.proto
package pb
import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
	unsafe "unsafe"
)
⋮----
protoreflect "google.golang.org/protobuf/reflect/protoreflect"
protoimpl "google.golang.org/protobuf/runtime/protoimpl"
reflect "reflect"
sync "sync"
unsafe "unsafe"
⋮----
const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
⋮----
// Verify that this generated code is sufficiently up-to-date.
⋮----
// Verify that runtime/protoimpl is sufficiently up-to-date.
⋮----
type SubscribeRequest struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Interval      int32                  `protobuf:"varint,1,opt,name=interval,proto3" json:"interval,omitempty"`
	Provider      string                 `protobuf:"bytes,2,opt,name=provider,proto3" json:"provider,omitempty"`
	Query         string                 `protobuf:"bytes,3,opt,name=query,proto3" json:"query,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}
func (x *SubscribeRequest) Reset()
func (x *SubscribeRequest) String() string
func (*SubscribeRequest) ProtoMessage()
func (x *SubscribeRequest) ProtoReflect() protoreflect.Message
// Deprecated: Use SubscribeRequest.ProtoReflect.Descriptor instead.
func (*SubscribeRequest) Descriptor() ([]byte, []int)
func (x *SubscribeRequest) GetInterval() int32
func (x *SubscribeRequest) GetProvider() string
func (x *SubscribeRequest) GetQuery() string
type SubscribeResponse struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Value         string                 `protobuf:"bytes,2,opt,name=value,proto3" json:"value,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}
⋮----
// Deprecated: Use SubscribeResponse.ProtoReflect.Descriptor instead.
⋮----
func (x *SubscribeResponse) GetValue() string
var File_subscribe_proto protoreflect.FileDescriptor
const file_subscribe_proto_rawDesc = "" +
	"\n" +
	"\x0fsubscribe.proto\x12\x02pb\"`\n" +
	"\x10SubscribeRequest\x12\x1a\n" +
	"\binterval\x18\x01 \x01(\x05R\binterval\x12\x1a\n" +
	"\bprovider\x18\x02 \x01(\tR\bprovider\x12\x14\n" +
	"\x05query\x18\x03 \x01(\tR\x05query\")\n" +
	"\x11SubscribeResponse\x12\x14\n" +
	"\x05value\x18\x02 \x01(\tR\x05valueB\x06Z\x04./pbb\x06proto3"
var (
	file_subscribe_proto_rawDescOnce sync.Once
	file_subscribe_proto_rawDescData []byte
)
func file_subscribe_proto_rawDescGZIP() []byte
var file_subscribe_proto_msgTypes = make([]protoimpl.MessageInfo, 2)
var file_subscribe_proto_goTypes = []any{
	(*SubscribeRequest)(nil),  // 0: pb.SubscribeRequest
	(*SubscribeResponse)(nil), // 1: pb.SubscribeResponse
}
⋮----
(*SubscribeRequest)(nil),  // 0: pb.SubscribeRequest
(*SubscribeResponse)(nil), // 1: pb.SubscribeResponse
⋮----
var file_subscribe_proto_depIdxs = []int32{
	0, // [0:0] is the sub-list for method output_type
	0, // [0:0] is the sub-list for method input_type
	0, // [0:0] is the sub-list for extension type_name
	0, // [0:0] is the sub-list for extension extendee
	0, // [0:0] is the sub-list for field type_name
}
⋮----
0, // [0:0] is the sub-list for method output_type
0, // [0:0] is the sub-list for method input_type
0, // [0:0] is the sub-list for extension type_name
0, // [0:0] is the sub-list for extension extendee
0, // [0:0] is the sub-list for field type_name
⋮----
func init()
func file_subscribe_proto_init()
⋮----
type x struct{}
```

## File: pkg/pb/activate.proto

```protobuf
syntax = "proto3";

package pb;

option go_package = "./pb";

message ActivateRequest {
  string provider = 1;
  string identifier = 2;
  string action = 3;
  string query = 4;
  string arguments = 5;
  bool single = 6;
}
```

## File: pkg/pb/makefile

```
.PHONY: proto clean

proto:
	@echo "Generating protobuf files..."
	@mkdir -p pb
	protoc --go_out=pb --go_opt=paths=source_relative *.proto
	@echo "Done!"

clean:
	rm -rf pb/

rebuild: clean proto
```

## File: pkg/pb/menu.proto

```protobuf
syntax = "proto3";

package pb;

option go_package = "./pb";

message MenuRequest {
   string menu = 1;
}
```

## File: pkg/pb/providerstate.proto

```protobuf
syntax = "proto3";

package pb;

option go_package = "./pb";

message ProviderStateRequest {
   string provider = 1;
}

message ProviderStateResponse {
  repeated string states = 1;
  repeated string actions = 2;
  string provider = 3;
}
```

## File: pkg/pb/query.proto

```protobuf
syntax = "proto3";

package pb;

option go_package = "./pb";

message QueryRequest {
  repeated string providers = 1;
  string query = 2;
  int32 maxresults = 3;
  bool exactsearch = 4;
}

message QueryResponse {
  string query = 1;

  enum Type {
      REGULAR = 0;
      FILE = 1;
  }

  message Item {
    message FuzzyInfo {
      int32 start = 1;
      string field = 2;
      repeated int32 positions = 3;
    }

	string identifier = 1;
	string text = 2;
	string subtext = 3;
	string icon = 4;
	string provider = 5;
	int32 score = 6;
	FuzzyInfo fuzzyinfo = 7;
    Type type = 8;
    string mimetype = 9;
    string preview = 10;
    string preview_type = 11;
    repeated string state = 12;
    repeated string actions = 13;
  }

   Item item = 2;
   int32 qid =3;
}
```

## File: pkg/pb/subscribe.proto

```protobuf
syntax = "proto3";

package pb;

option go_package = "./pb";

message SubscribeRequest {
  int32 interval = 1;
  string provider = 2;
  string query = 3;
}

message SubscribeResponse {
  string value = 2;
}
```

## File: .air.toml

```toml
root = "."
tmp_dir = "tmp"

[build]
# Just plain old shell command. You could use `make` as well.
cmd = "cd cmd/elephant && go build -o /tmp/elephant-air ."
full_bin = "ELEPHANT_DEV=true /tmp/elephant-air"
pre_cmd = [
  "mkdir -p /tmp/elephant/providers",
  "cd internal/providers/files && go build -buildmode=plugin && cp files.so /tmp/elephant/providers/",
  "cd internal/providers/desktopapplications && go build -buildmode=plugin && cp desktopapplications.so /tmp/elephant/providers/",
  "cd internal/providers/clipboard && go build -buildmode=plugin && cp clipboard.so /tmp/elephant/providers/",
  "cd internal/providers/runner && go build -buildmode=plugin && cp runner.so /tmp/elephant/providers/",
  "cd internal/providers/symbols && go build -buildmode=plugin && cp symbols.so /tmp/elephant/providers/",
  "cd internal/providers/calc && go build -buildmode=plugin && cp calc.so /tmp/elephant/providers/",
  "cd internal/providers/providerlist && go build -buildmode=plugin && cp providerlist.so /tmp/elephant/providers/",
  "cd internal/providers/menus && go build -buildmode=plugin && cp menus.so /tmp/elephant/providers/",
  "cd internal/providers/websearch && go build -buildmode=plugin && cp websearch.so /tmp/elephant/providers/",
  "cd internal/providers/archlinuxpkgs && go build -buildmode=plugin && cp archlinuxpkgs.so /tmp/elephant/providers/",
  "cd internal/providers/todo && go build -buildmode=plugin && cp todo.so /tmp/elephant/providers/",
  "cd internal/providers/bookmarks && go build -buildmode=plugin && cp bookmarks.so /tmp/elephant/providers/",
  "cd internal/providers/unicode && go build -buildmode=plugin && cp unicode.so /tmp/elephant/providers/",
  "cd internal/providers/bluetooth && go build -buildmode=plugin && cp bluetooth.so /tmp/elephant/providers/",
  "cd internal/providers/windows && go build -buildmode=plugin && cp windows.so /tmp/elephant/providers/",
  "cd internal/providers/snippets && go build -buildmode=plugin && cp snippets.so /tmp/elephant/providers/",
  "cd internal/providers/nirisessions && go build -buildmode=plugin && cp nirisessions.so /tmp/elephant/providers/",
  "cd internal/providers/1password && go build -buildmode=plugin && cp 1password.so /tmp/elephant/providers/",
]
# Binary file yields from `cmd`.
bin = "/tmp/elephant-air"
# Watch these filename extensions.
include_ext = ["go"]
# Ignore these filename extensions or directories.
exclude_dir = []
# Watch these directories if you specified.
include_dir = []
# Watch these files.
include_file = []
# Exclude files.
exclude_file = []
# Exclude specific regular expressions.
exclude_regex = ["_test\\.go"]
# Exclude unchanged files.
exclude_unchanged = false
# Follow symlink for directories
follow_symlink = true
# This log file is placed in your tmp_dir.
log = "air.log"
# It's not necessary to trigger build each time file changes if it's too frequent.
delay = 0 # ms
# Stop running old binary when build errors occur.
stop_on_error = true
# Send Interrupt signal before killing process (windows does not support this feature)
send_interrupt = false
# Delay after sending Interrupt signal
kill_delay = 500 # nanosecond
# Rerun binary or not
rerun = true
# Delay after each execution
rerun_delay = 500

[misc]
# Delete tmp directory on exit
clean_on_exit = true

[screen]
clear_on_rebuild = true
keep_scroll = true
```

## File: .gitignore

```
*.so
cmd/elephant/elephant
tmp
```

## File: BREAKING.md

```markdown
## Files

`fd_flags` is now a string array to avoid incorrect parsing.
```

## File: flake.nix

```nix
{
  description = ''
    Elephant - a powerful data provider service and backend for building custom application launchers and desktop utilities.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      eachSystem = f: lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
    in
    {
      formatter = eachSystem (pkgs: pkgs.alejandra);

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          name = "elephant-dev-shell";
          inputsFrom = [ self.packages.${pkgs.stdenv.system}.elephant ];
          buildInputs = with pkgs; [
            go
            gcc
            protobuf
            protoc-gen-go
          ];
        };
      });

      packages = eachSystem (pkgs: {
        default = self.packages.${pkgs.stdenv.system}.elephant-with-providers;

        # Main elephant binary
        elephant = pkgs.buildGo125Module {
          pname = "elephant";
          version = lib.trim (builtins.readFile ./cmd/elephant/version.txt);

          src = ./.;

          vendorHash = "sha256-XYGh4ZXRly3MCPWse51eUMyjXqtHzKbPEyD0J8S/MDk=";

          buildInputs = with pkgs; [
            protobuf
          ];

          nativeBuildInputs = with pkgs; [
            protoc-gen-go
            makeWrapper
          ];

          # Build from cmd/elephant/elephant.go
          subPackages = [
            "cmd/elephant"
          ];

          postFixup = ''
             wrapProgram $out/bin/elephant \
            	    --prefix PATH : ${lib.makeBinPath (with pkgs; [ fd ])}
          '';

          meta = with lib; {
            description = "Powerful data provider service and backend for building custom application launchers";
            homepage = "https://github.com/abenz1267/elephant";
            license = licenses.gpl3Only;
            maintainers = [ ];
            platforms = platforms.linux;
          };
        };

        # Providers package - builds all providers with same Go toolchain
        elephant-providers = pkgs.buildGo125Module rec {
          pname = "elephant-providers";
          version = lib.trim (builtins.readFile ./cmd/elephant/version.txt);

          src = ./.;

          vendorHash = "sha256-XYGh4ZXRly3MCPWse51eUMyjXqtHzKbPEyD0J8S/MDk=";

          buildInputs = with pkgs; [
            wayland
          ];

          nativeBuildInputs = with pkgs; [
            protobuf
            protoc-gen-go
          ];

          excludedProviders = [
            "archlinuxpkgs"
          ];

          buildPhase = ''
            runHook preBuild

            echo "Building elephant providers..."

            EXCLUDE_LIST="${lib.concatStringsSep " " excludedProviders}"

            is_excluded() {
              target="$1"
              for e in $EXCLUDE_LIST; do
                [ -z "$e" ] && continue
                if [ "$e" = "$target" ]; then
                  return 0
                fi
              done
              return 1
            }

            if [ -d ./internal/providers ]; then
              for dir in ./internal/providers/*; do
                [ -d "$dir" ] || continue
                provider=$(basename "$dir")
                if is_excluded "$provider"; then
                  echo "Skipping excluded provider: $provider"
                  continue
                fi
                set -- "$dir"/*.go
                if [ -e "$1" ]; then
                  echo "Building provider: $provider"
                  if ! go build -buildmode=plugin -o "$provider.so" ./internal/providers/"$provider"; then
                    echo "⚠ Failed to build provider: $provider"
                    exit 1
                  fi
                  echo "Built $provider.so"
                else
                  echo "Skipping $provider: no .go files found"
                fi
              done
            else
              echo "No providers directory found at ./internal/providers"
            fi

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out/lib/elephant/providers

            # Copy all built .so files
            for so_file in *.so; do
              if [[ -f "$so_file" ]]; then
                cp "$so_file" "$out/lib/elephant/providers/"
                echo "Installed provider: $so_file"
              fi
            done

            runHook postInstall
          '';

          meta = with lib; {
            description = "Elephant providers (Go plugins)";
            homepage = "https://github.com/abenz1267/elephant";
            license = licenses.gpl3Only;
            platforms = platforms.linux;
          };
        };

        # Combined package with elephant + providers
        elephant-with-providers = pkgs.stdenv.mkDerivation {
          pname = "elephant-with-providers";
          version = lib.trim (builtins.readFile ./cmd/elephant/version.txt);

          dontUnpack = true;

          buildInputs = [
            self.packages.${pkgs.stdenv.system}.elephant
            self.packages.${pkgs.stdenv.system}.elephant-providers
          ];

          nativeBuildInputs = with pkgs; [
            makeWrapper
          ];

          installPhase = ''
            mkdir -p $out/bin $out/lib/elephant
            cp ${self.packages.${pkgs.stdenv.system}.elephant}/bin/elephant $out/bin/
            cp -r ${
              self.packages.${pkgs.stdenv.system}.elephant-providers
            }/lib/elephant/providers $out/lib/elephant/
          '';

          postFixup = ''
            wrapProgram $out/bin/elephant \
                  --prefix PATH : ${
                    lib.makeBinPath (
                      with pkgs;
                      [
                        wl-clipboard
                        libqalculate
                        imagemagick
                        bluez
                      ]
                    )
                  }
          '';

          meta = with lib; {
            description = "Elephant with all providers (complete installation)";
            homepage = "https://github.com/abenz1267/elephant";
            license = licenses.gpl3Only;
            platforms = platforms.linux;
          };
        };
      });

      homeManagerModules = {
        default = self.homeManagerModules.elephant;
        elephant = import ./nix/modules/home-manager.nix self;
      };

      nixosModules = {
        default = self.nixosModules.elephant;
        elephant = import ./nix/modules/nixos.nix self;
      };
    };
}
```

## File: go.mod

```
module github.com/abenz1267/elephant/v2

go 1.25.0

require (
	al.essio.dev/pkg/shellescape v1.6.0
	github.com/abenz1267/elephant v1.3.3
	github.com/adrg/xdg v0.5.3
	github.com/djherbis/times v1.6.0
	github.com/fsnotify/fsnotify v1.9.0
	github.com/mattn/go-sqlite3 v1.14.32
	github.com/pelletier/go-toml/v2 v2.2.4
	github.com/tinylib/msgp v1.4.0
	google.golang.org/protobuf v1.36.8
)

require (
	github.com/Microsoft/go-winio v0.6.2 // indirect
	github.com/ProtonMail/go-crypto v1.3.0 // indirect
	github.com/cloudflare/circl v1.6.1 // indirect
	github.com/cyphar/filepath-securejoin v0.5.0 // indirect
	github.com/dlclark/regexp2 v1.11.4 // indirect
	github.com/dop251/goja v0.0.0-20250307175808-203961f822d6 // indirect
	github.com/emirpasic/gods v1.18.1 // indirect
	github.com/fatih/structs v1.1.0 // indirect
	github.com/go-git/gcfg/v2 v2.0.2 // indirect
	github.com/go-git/go-billy/v6 v6.0.0-20251022185412-61e52df296a5 // indirect
	github.com/go-sourcemap/sourcemap v2.1.3+incompatible // indirect
	github.com/go-viper/mapstructure/v2 v2.4.0 // indirect
	github.com/golang/groupcache v0.0.0-20241129210726-2c02b8208cf8 // indirect
	github.com/google/go-cmp v0.6.0 // indirect
	github.com/google/pprof v0.0.0-20230207041349-798e818bf904 // indirect
	github.com/kevinburke/ssh_config v1.4.0 // indirect
	github.com/klauspost/cpuid/v2 v2.3.0 // indirect
	github.com/knadh/koanf/maps v0.1.2 // indirect
	github.com/mattn/go-isatty v0.0.20 // indirect
	github.com/mitchellh/copystructure v1.2.0 // indirect
	github.com/mitchellh/reflectwalk v1.0.2 // indirect
	github.com/philhofer/fwd v1.2.0 // indirect
	github.com/pjbgf/sha1cd v0.5.0 // indirect
	github.com/rivo/uniseg v0.4.7 // indirect
	github.com/sergi/go-diff v1.4.0 // indirect
	github.com/yalue/native_endian v1.0.2 // indirect
	golang.org/x/crypto v0.44.0 // indirect
	golang.org/x/text v0.31.0 // indirect
)

require (
	github.com/charlievieth/fastwalk v1.0.13
	github.com/go-git/go-git/v6 v6.0.0-20251029213217-0bbfc0875edd
	github.com/joho/godotenv v1.5.1
	github.com/junegunn/fzf v0.65.2
	github.com/knadh/koanf/parsers/toml/v2 v2.2.0
	github.com/knadh/koanf/providers/file v1.2.0
	github.com/knadh/koanf/providers/structs v1.0.0
	github.com/knadh/koanf/v2 v2.2.2
	github.com/neurlang/wayland v0.3.0
	github.com/sho0pi/naturaltime v0.0.2
	github.com/urfave/cli/v3 v3.4.1
	github.com/yuin/gopher-lua v1.1.1
	golang.org/x/net v0.47.0 // indirect
	golang.org/x/sys v0.38.0 // indirect
)
```

## File: makefile

```makefile
PREFIX ?= /usr/local
DESTDIR ?=
BINDIR = $(DESTDIR)$(PREFIX)/bin
LICENSEDIR = $(DESTDIR)$(PREFIX)/share/licenses/elephant

# Build configuration
GO_BUILD_FLAGS = -buildvcs=false -trimpath
BUILD_DIR = cmd/elephant

.PHONY: all build install uninstall clean

all: build

build:
	cd $(BUILD_DIR) && go build $(GO_BUILD_FLAGS) -o elephant

install: build
	install -Dm 755 $(BUILD_DIR)/elephant $(BINDIR)/elephant

uninstall:
	rm -f $(BINDIR)/elephant

clean:
	cd $(BUILD_DIR) && go clean
	rm -f $(BUILD_DIR)/elephant

dev-install: PREFIX = /usr/local
dev-install: install

help:
	@echo "Available targets:"
	@echo "  all       - Build the application (default)"
	@echo "  build     - Build the application"
	@echo "  install   - Install the application"
	@echo "  uninstall - Remove installed files"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  PREFIX    - Installation prefix (default: /usr/local)"
	@echo "  DESTDIR   - Destination directory for staged installs"
```

## File: README.md

````markdown
# Elephant 🐘

**Elephant** - _cuz it's phat_ - is a powerful data provider service and backend for building custom application launchers and desktop utilities. It provides various data sources and actions through a plugin-based architecture, communicating via Unix sockets and Protocol Buffers.

[![Discord](https://img.shields.io/discord/1402235361463242964?logo=discord)](https://discord.gg/mGQWBQHASt)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Overview

Elephant acts as a unified backend service that aggregates data from various sources (desktop applications, files, clipboard history, etc.) and provides a consistent interface for frontend applications like custom launchers, productivity tools, or desktop widgets.

## Features

### Current Providers

- **Desktop Applications**
  - Auto-detection of `uwsm` or `app2unit`
  - Application launch history
  - Desktop entry parsing

- **Files**
  - File preview (text/image)
  - File operations: open, copy path, copy content
  - Directory navigation

- **Bluetooth**
  - basic bluetooth management
  - connect/disconnect
  - trust/untrust
  - pair/remove

- **Clipboard**
  - Text and image clipboard history
  - Clipboard content management
  - post-edit text content

- **Runner**
  - Command execution from explicit lists
  - `$PATH` scanning for executables

- **Symbols/Emojis**
  - Multi-locale emoji and symbol support
  - Unicode character database

- **Calculator/Unit Conversion**
  - Mathematical calculations with history
  - Unit conversion using `qalc`

- **Custom Menus**
  - User-defined menu creation
  - Custom action definitions

- **Provider List**
  - Dynamic listing of all loaded providers and menus

- **Websearch**
  - ... define custom search engines

- **Archlinux Packages**
  - list all packages: official and AUR
  - list all explicitly installed packages `i:`
  - remove / install packages (pacman, yay/paru)

- **Todo List**
  - add items, mark as active/done, clear done items
  - create items with due times
  - notifications

- **Bookmarks**
  - add and remove bookmarks
  - configure and assign categories, f.e. "work" or "personal"

- **Unicodes**
  - find unicode symbols

- **Windows**
  - find and focus windows

- **Snippets**
  - find and paste text snippets

- **Niri Sessions**
  - define sets of apps to open and run them

- **1Password**
  - access your 1Password vaults

## Installation

### Installing on Arch

```
yay -S elephant

# Providers, f.e.

yay -S elephant-desktopapplications
```

### Building from Source

```bash
# Clone the repository
git clone https://github.com/abenz1267/elephant
cd elephant

# Build and install the main binary
cd cmd/elephant
go install elephant.go

# Create configuration directories
mkdir -p ~/.config/elephant/providers

# Build and install a provider (example: desktop applications)
cd ../../internal/providers/desktopapplications
go build -buildmode=plugin
cp desktopapplications.so ~/.config/elephant/providers/
```

## Usage

### Important

It is utterly important that `elephant` runs in the appropriate environment. Starting a system-level systemd service f.e. will lead to missing environment variables. It needs to run with the users environment.

### Starting the Service

On a `systemd` based system, you can use `elephant service enable/disable` to manage a service.

The service file will be placed in `~/.config/systemd/user/elephant.service`.

Feel free to create your own service file/adjust the one created.

```bash
# Start elephant with default configuration
elephant

# Start with debug logging
elephant --debug

# Use custom configuration directory
elephant --config /path/to/config
```

### Command Line Interface

Elephant includes a built-in client for testing and basic operations:

#### Querying Data

```bash
# Query provider (providers;query;limit;exactsearch)
elephant query "files;documents;10;false"
```

#### Activating Items

```bash
# activate item (provider;identifier;action;query;arguments)
elephant activate "files;<identifier>;open;;"
```

#### Other Commands

```bash
# List all installed providers
elephant listproviders

# Open a custom menu, requires a subscribed frontend.
elephant menu "screenshots"

# Show version
elephant version

# Generate configuration documentation
elephant generatedoc

# Systemd service management
elephant service enable/disable
```

### Configuration

Elephant uses a configuration directory structure:

```
~/.config/elephant/
├── elephant.toml        # Main configuration
├── .env                 # Environment variables
└── <provider>.toml      # Provider config
```

Markdown documentation for configuring Elephant and its providers can be obtained using `elephant generatedoc`.

Markdown documentation for configuring a specific provider can be obtained using `elephant generatedoc <provider>`, e.g. `elephant generatedoc unicode`.

## API & Integration

### Communication Protocol

Elephant uses Unix domain sockets for IPC and Protocol Buffers for message serialization. The main message types are:

- **Query Messages**: Request data from providers
- **Activation Messages**: Execute actions
- **Menu Messages**: Request custom menu data
- **Subscribe Messages**: Listen for real-time updates

### Building Client Applications

To integrate with Elephant, your application needs to:

1. Connect to the Unix socket (typically at `/tmp/elephant.sock`)
2. Send Protocol Buffer messages
3. Handle responses and updates

See the `pkg/pb/` directory for Protocol Buffer definitions.

## Development

### Project Structure

```
elephant/
├── cmd/                 # Main application entry point
├── internal/
│   ├── comm/           # Communication layer (Unix sockets, protobuf)
│   ├── common/         # Shared utilities and configuration
│   ├── providers/      # Data provider plugins
│   └── util/          # Helper utilities
├── pkg/pb/            # Protocol Buffer definitions
└── flake.nix          # Nix development environment
```

### Creating Custom Providers

Providers are Go plugins that implement the provider interface. See existing providers in `internal/providers/` for examples.

### Building from Source

```bash
# Clone repository
git clone https://github.com/abenz1267/elephant
cd elephant

# Install dependencies
go mod download

# Build main binary
go build -o elephant cmd/elephant.go

# Run tests
go test ./...
```

### Development Environment

A Nix flake is provided for reproducible development:

```bash
nix develop
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

Please ensure your code follows Go best practices and includes appropriate documentation.

## License

This project is licensed under the GNU General Public License v3.0. See [LICENSE](LICENSE) for details.

## Support

- 💬 [Discord Community](https://discord.gg/mGQWBQHASt)
- 🐛 [Issue Tracker](https://github.com/abenz1267/elephant/issues)
````
