.PHONY: all build generate binary test image release setup report

REGISTRY_REPO = "requaos/qorfun"

OK_COLOR=\033[32;01m
NO_COLOR=\033[0m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m

# Build Flags
BUILD_HASH = $(shell git rev-parse --short HEAD)
BUILD_TIMESTAMP = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_NUMBER ?= $(BUILD_NUMBER:)

# If we don't set the build number it defaults to dev
ifeq ($(BUILD_NUMBER),)
	BUILD_NUMBER := dev
endif

NOW = $(shell date -u '+%Y%m%d%I%M%S')

# If we don't set the environment it defaults to dev
ifeq ($(ENV),)
	ENV := dev
endif

DOCKER := docker
GO := go
GO_ENV := $(shell $(GO) env GOOS GOARCH)
GOOS ?= $(word 1,$(GO_ENV))
GOARCH ?= $(word 2,$(GO_ENV))
GOFLAGS ?= $(GOFLAGS:)
ROOT_DIR := $(realpath .)

# GOOS/GOARCH of the build host, used to determine if we are cross-compiling or not
BUILDER_GOOS_GOARCH="$(GOOS)_$(GOARCH)"

# check for windows
ifeq ($(GOOS),windows)
    BINARY_NAME := qorfun.exe
else
    BINARY_NAME := qorfun
endif

# EXTLDFLAGS = -extldflags "-lm -lstdc++ -static"
EXTLDFLAGS =

GO_LINKER_FLAGS ?= --ldflags \
	'$(EXTLDFLAGS) -s -w -X "github.com/requaos/qorfun/internal/version.BuildNumber=$(BUILD_NUMBER)" \
	-X "github.com/requaos/qorfun/internal/version.Timestamp=$(BUILD_TIMESTAMP)" \
	-X "github.com/requaos/qorfun/internal/version.BuildHash=$(BUILD_HASH)"'

all: build

build: generate binary

generate:
	@echo "$(OK_COLOR)*** Running go generate... ***$(NO_COLOR)"
	$(GO) generate $(GOFLAGS) ./...

binary:
	@echo "$(OK_COLOR)*** Running go build... ***$(NO_COLOR)"
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) $(GO) build -a -tags netgo $(GOFLAGS) $(GO_LINKER_FLAGS) -o bin/$(GOOS)_$(GOARCH)/$(BINARY_NAME)

test: generate
	@echo "$(OK_COLOR)*** Running go test... ***$(NO_COLOR)"
	$(GO) test $(GOFLAGS) -race ./...

image:
	@echo "$(OK_COLOR)*** Building Docker Image... ***$(NO_COLOR)"
	$(DOCKER) build . -t $(REGISTRY_REPO):$(ENV)-$(BUILD_HASH)

release:
	@echo "$(OK_COLOR)*** Building Docker Image... ***$(NO_COLOR)"
	$(DOCKER) push $(REGISTRY_REPO):$(ENV)-$(BUILD_HASH)

setup:
	@echo "$(OK_COLOR)*** Installing required components... ***$(NO_COLOR)"
	@$(GO) get -u $(GOFLAGS) github.com/360EntSecGroup-Skylar/goreporter
	@$(GO) get -u $(GOFLAGS) honnef.co/go/tools/...
	@$(GO) get -u $(GOFLAGS) github.com/jgautheron/goconst/cmd/goconst
	@$(GO) get -u $(GOFLAGS) github.com/alexkohler/prealloc
	@$(GO) get -u $(GOFLAGS) github.com/mdempsky/unconvert
	@$(GO) get -u $(GOFLAGS) github.com/go-critic/go-critic/...
	@$(GO) get -u $(GOFLAGS) github.com/kisielk/errcheck

report:
	@cd .. && goreporter -p ./qorfun -e ./qorfun/vendor -r ./qorfun && cd qorfun
	@echo "$(OK_COLOR)*** Running megacheck... ***$(NO_COLOR)"
	@megacheck bitbucket.org/knowbe4/phisher-ingester/... > static-analysis.txt || :
	@echo "$(OK_COLOR)*** Running goconst... ***$(NO_COLOR)"
	@goconst -ignore "vendor" ./... >> static-analysis.txt
	@echo "$(OK_COLOR)*** Running prealloc... ***$(NO_COLOR)"
	@$(GO) list ./... | grep -v schema | xargs -I {} prealloc -forloops {} 2>> static-analysis.txt
	@echo "$(OK_COLOR)*** Running unconvert... ***$(NO_COLOR)"
	@unconvert ./... >> static-analysis.txt || :
	@echo "$(OK_COLOR)*** Running gocritic... ***$(NO_COLOR)"
	@gocritic check-project -enable=appendCombine,builtinShadow,flagDeref,ifElseChain,rangeExprCopy,rangeValCopy,singleCaseSwitch,switchTrue,typeSwitchVar,typeUnparen,underef,unslice,appendAssign,assignOp,boolExprSimplify,boolFuncPrefix,busySelect,captLocal,caseOrder,commentedOutCode,deadCodeAfterLogFatal,defaultCaseOrder,deferInLoop,docStub,dupBranchBody,dupCase,dupSubExpr,elseif,emptyFmt,evalOrder,floatCompare,hugeParam,importShadow,indexOnlyLoop,initClause,longChain,namedConst,nestingReduce,nilValReturn,ptrToRefParam,regexpMust,sloppyLen,sqlRowsClose,stdExpr,unexportedCall,unlambda,unnamedResult,unnecessaryBlock,yodaStyleExpr . 2>> static-analysis.txt || :
	@echo "$(OK_COLOR)*** Running errcheck... ***$(NO_COLOR)"
	@echo "" >> static-analysis.txt
	@echo "Missing check for error:" >> static-analysis.txt
	@$(GO) list ./... | grep -v schema | xargs -I {} errcheck {} >> static-analysis.txt || :
	@echo "$(OK_COLOR)*** Results:$(NO_COLOR)"
	@cat ./static-analysis.txt
