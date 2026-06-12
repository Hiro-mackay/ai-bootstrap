# Go DDD Reference Architecture

> Mandatory rules. Deviations require an ADR in docs/decisions/.

## Directory Structure

```
cmd/{service}/main.go               # Entry + wiring + mux + graceful shutdown (ALL in one)
internal/
  gen/                               # (gitignored) protobuf generated code
  domain/
    entity/             # Aggregate roots, domain entities
    valueobject/        # Value objects (immutable, self-validating)
    repository/         # Repository interfaces + TransactionManager
    service/            # Domain service interfaces
  usecase/
    {feature}/
      command/          # Write operations (one file per command)
      query/            # Read operations (one file per query)
  infrastructure/
    database/           # DB client, migrations, SQLC queries + generated code
    repository/         # Repository implementations
    cache/              # Redis, in-memory cache
    ...                 # Other adapters (email, storage, oauth, etc.)
  interface/
    handler/            # Connect RPC service implementations
    interceptor/        # All interceptors in ONE file
pkg/
  config/               # Configuration loading
  logger/               # Structured logging
```

### Layer Mapping

| Generic (docs/architecture.md) | Go Directory | Go Name |
|-------------------------------|-------------|---------|
| Domain | `internal/domain/` | Domain |
| Application | `internal/usecase/` | UseCase |
| Infrastructure | `internal/infrastructure/` | Infrastructure |
| Presentation | `internal/interface/` | Interface |

### Key Differences from Traditional HTTP

- No `router/`, `server/`, `di/` directories -- all inlined in `main.go`
- No `dto/`, `presenter/`, `validator/` -- protobuf handles serialization, protovalidate handles validation
- No `middleware/` -- Connect uses interceptors
- No `pkg/apperror/` -- `connect.NewError(code, err)` replaces custom error types

## Layer Rules

### Domain Layer (`internal/domain/`)

- All business logic lives here
- MUST NOT import from usecase, infrastructure, or interface
- No JSON/DB/ORM tags on domain types
- Entities use **exported fields** (Go idiomatic -- no getter ceremony)
- Entities MUST have behavior methods that enforce invariants
- Value Objects: private fields, validate on creation, immutable
- Repository interfaces in `domain/repository/`
- TransactionManager interface in `domain/repository/`
- Domain service interfaces in `domain/service/`

### UseCase Layer (`internal/usecase/`)

- Orchestrates domain objects only (no business logic)
- Organized by feature, then by command/ and query/
- Command structs for writes, Query structs for reads
- Method signature: `Execute(ctx context.Context, input Input) (*Output, error)`
- Input/Output are plain structs (no JSON tags, no HTTP knowledge)
- Transaction boundaries managed here via TransactionManager
- Side effects (email, notifications) execute OUTSIDE the transaction

### Infrastructure Layer (`internal/infrastructure/`)

- Implements domain repository and service interfaces
- One file per concern (never mix DB + HTTP client + cache)
- Repository implementations use BaseRepository composition
- Converts infrastructure errors to domain errors (pgx.ErrNoRows -> domain.ErrNotFound, etc.)

### Interface Layer (`internal/interface/`)

- Calls UseCase layer only (never domain or infrastructure directly)
- Connect RPC handlers in `handler/` implement generated service interfaces
- All interceptors in a single `interceptor/interceptor.go` file
- Handlers return `connect.NewError()` -- no manual status code mapping

## Patterns

### Context annotations

Capability anchors carry their **product context** in the declaration's doc comment, so it moves
with the code and is enforced (`scripts/check-context.sh` via `task arch`, #34). Tags:

- `@context <Name>` -- the bounded context; **must** match a `### <Name>` under `## Bounded Contexts` in `docs/domain-definitions.md`.
- `@business <one line>` -- what it is / the outcome it produces (the why a human or agent needs at change-time).
- `@invariant <Subject MUST/MUST NOT …>` -- the domain invariant it enforces (same format as `docs/domain-definitions.md`).

**Anchors** (where `@context` + `@business` are required): the aggregate-root entity
(`internal/domain/entity/*.go`) and each usecase command/query
(`internal/usecase/*/command|query/*.go`). Use an ordinary doc comment -- never a `//go:` directive
(those are compiler-reserved). `task context` surfaces these (plus the matching `docs/domain-definitions.md` block)
when the code is touched.

### Entity (Aggregate Root)

```go
// internal/domain/entity/file.go
type FileStatus string

const (
    FileStatusUploading FileStatus = "uploading"
    FileStatusActive    FileStatus = "active"
)

var (
    ErrFileNotActive    = errors.New("file is not active")
    ErrFileNameConflict = errors.New("file name already exists in folder")
)

// File is the Storage aggregate root: an uploaded file tracked through its lifecycle.
//
// @context Storage
// @business Lets a user upload, activate, rename, and move files within folders.
// @invariant File MUST be in Uploading status to be Activated.
type File struct {
    ID        uuid.UUID
    FolderID  uuid.UUID
    OwnerID   uuid.UUID
    Name      valueobject.FileName
    Size      int64
    Status    FileStatus
    CreatedAt time.Time
    UpdatedAt time.Time
}

func NewFile(ownerID, folderID uuid.UUID, name valueobject.FileName, size int64) *File {
    now := time.Now()
    return &File{
        ID: uuid.New(), FolderID: folderID, OwnerID: ownerID,
        Name: name, Size: size, Status: FileStatusUploading,
        CreatedAt: now, UpdatedAt: now,
    }
}

func (f *File) Activate() error {
    if f.Status != FileStatusUploading {
        return fmt.Errorf("%w: current status is %s", ErrFileNotActive, f.Status)
    }
    f.Status = FileStatusActive
    f.UpdatedAt = time.Now()
    return nil
}

func (f *File) Rename(name valueobject.FileName) {
    f.Name = name
    f.UpdatedAt = time.Now()
}

func (f *File) MoveTo(folderID uuid.UUID) {
    f.FolderID = folderID
    f.UpdatedAt = time.Now()
}
```

### Value Object

```go
// internal/domain/valueobject/filename.go
type FileName struct {
    value string
}

func NewFileName(v string) (FileName, error) {
    v = strings.TrimSpace(v)
    if v == "" {
        return FileName{}, errors.New("file name must not be empty")
    }
    if len(v) > 255 {
        return FileName{}, fmt.Errorf("file name must not exceed 255 characters, got %d", len(v))
    }
    return FileName{value: v}, nil
}

func (n FileName) String() string         { return n.value }
func (n FileName) Equals(other FileName) bool { return n.value == other.value }
```

### Repository Interface & TransactionManager

```go
// internal/domain/repository/file_repository.go
type FileRepository interface {
    Create(ctx context.Context, file *entity.File) error
    FindByID(ctx context.Context, id uuid.UUID) (*entity.File, error)
    FindByFolderID(ctx context.Context, folderID uuid.UUID) ([]*entity.File, error)
    Update(ctx context.Context, file *entity.File) error
    Delete(ctx context.Context, id uuid.UUID) error
}

// internal/domain/repository/transaction.go
type TransactionManager interface {
    WithTransaction(ctx context.Context, fn func(ctx context.Context) error) error
}
```

### Command & Query (UseCase)

```go
// internal/usecase/storage/command/create_file.go
type CreateFileInput struct {
    UserID   uuid.UUID
    FolderID uuid.UUID
    FileName string
    Size     int64
}

type CreateFileOutput struct {
    File *entity.File
}

// @context Storage
// @business Creates a file in a folder so the user can store content.
type CreateFileCommand struct {
    fileRepo  repository.FileRepository
    txManager repository.TransactionManager
}

func NewCreateFileCommand(
    fileRepo repository.FileRepository, txManager repository.TransactionManager,
) *CreateFileCommand {
    return &CreateFileCommand{fileRepo: fileRepo, txManager: txManager}
}

func (c *CreateFileCommand) Execute(ctx context.Context, input CreateFileInput) (*CreateFileOutput, error) {
    name, err := valueobject.NewFileName(input.FileName)
    if err != nil {
        return nil, fmt.Errorf("invalid file name: %w", err)
    }

    file := entity.NewFile(input.UserID, input.FolderID, name, input.Size)

    err = c.txManager.WithTransaction(ctx, func(ctx context.Context) error {
        return c.fileRepo.Create(ctx, file)
    })
    if err != nil {
        return nil, err
    }

    return &CreateFileOutput{File: file}, nil
}
```

```go
// internal/usecase/storage/query/list_files.go
type ListFilesInput struct {
    UserID   uuid.UUID
    FolderID uuid.UUID
}

type ListFilesOutput struct {
    Files []*entity.File
}

type ListFilesQuery struct {
    fileRepo repository.FileRepository
}

func NewListFilesQuery(fileRepo repository.FileRepository) *ListFilesQuery {
    return &ListFilesQuery{fileRepo: fileRepo}
}

func (q *ListFilesQuery) Execute(ctx context.Context, input ListFilesInput) (*ListFilesOutput, error) {
    files, err := q.fileRepo.FindByFolderID(ctx, input.FolderID)
    if err != nil {
        return nil, err
    }
    return &ListFilesOutput{Files: files}, nil
}
```

### Connect RPC Handler & Error Handling

```go
// internal/interface/handler/file_handler.go
type FileHandler struct {
    createFile *command.CreateFileCommand
    listFiles  *query.ListFilesQuery
}

func NewFileHandler(createFile *command.CreateFileCommand, listFiles *query.ListFilesQuery) *FileHandler {
    return &FileHandler{createFile: createFile, listFiles: listFiles}
}

func (h *FileHandler) CreateFile(
    ctx context.Context,
    req *connect.Request[filev1.CreateFileRequest],
) (*connect.Response[filev1.CreateFileResponse], error) {
    output, err := h.createFile.Execute(ctx, command.CreateFileInput{
        UserID:   interceptor.UserID(ctx),
        FolderID: uuid.MustParse(req.Msg.FolderId),
        FileName: req.Msg.FileName,
        Size:     req.Msg.Size,
    })
    if err != nil {
        // Domain errors -> Connect errors at the boundary
        if errors.Is(err, domain.ErrNotFound) {
            return nil, connect.NewError(connect.CodeNotFound, err)
        }
        return nil, connect.NewError(connect.CodeInternal, err)
    }
    return connect.NewResponse(&filev1.CreateFileResponse{
        File: toFileProto(output.File),
    }), nil
}
```

Error handling rules:
- Use `connect.NewError(code, err)` directly in handlers -- no custom error types
- Map domain errors to Connect codes at the handler boundary
- `connect.CodeNotFound` for missing resources
- `connect.CodeInvalidArgument` for validation errors
- `connect.CodeInternal` for unexpected errors
- Recovery interceptor catches panics and returns `connect.CodeInternal`

### Interceptors (ALL in one file)

```go
// internal/interface/interceptor/interceptor.go
// Recovery: catch panics, log stack trace, return connect.CodeInternal
// Logging: procedure name, duration, error
// RequestID: propagate X-Request-Id header (generate if missing)

func Recovery(log *slog.Logger) connect.UnaryInterceptorFunc {
    return func(next connect.UnaryFunc) connect.UnaryFunc {
        return func(ctx context.Context, req connect.AnyRequest) (resp connect.AnyResponse, err error) {
            defer func() {
                if r := recover(); r != nil {
                    log.ErrorContext(ctx, "panic recovered",
                        "panic", r, "stack", string(debug.Stack()),
                        "procedure", req.Spec().Procedure,
                    )
                    err = connect.NewError(connect.CodeInternal, fmt.Errorf("internal error"))
                }
            }()
            return next(ctx, req)
        }
    }
}

func Logging(log *slog.Logger) connect.UnaryInterceptorFunc { ... }
func RequestIDInterceptor() connect.UnaryInterceptorFunc { ... }
```

### main.go (Application Wiring)

```go
// cmd/server/main.go -- read this and understand the entire app
func main() {
    cfg := config.Load()
    log := logger.New(cfg.LogLevel)

    interceptors := connect.WithInterceptors(
        interceptor.RequestIDInterceptor(),
        interceptor.Recovery(log),
        interceptor.Logging(log),
    )

    mux := http.NewServeMux()
    mux.Handle(healthv1connect.NewHealthServiceHandler(&handler.HealthHandler{}, interceptors))
    // Add more service handlers here:
    // mux.Handle(filev1connect.NewFileServiceHandler(fileHandler, interceptors))

    corsHandler := cors.New(cors.Options{
        AllowedOrigins: cfg.AllowedOrigins,
        AllowedMethods: []string{http.MethodGet, http.MethodPost},
        AllowedHeaders: []string{
            "Content-Type", "Connect-Protocol-Version",
            "Connect-Timeout-Ms", "X-Request-Id",
        },
        ExposedHeaders: []string{"X-Request-Id"},
    }).Handler(mux)

    srv := &http.Server{
        Addr:    ":" + cfg.AppPort,
        Handler: h2c.NewHandler(corsHandler, &http2.Server{}),
    }

    // Graceful shutdown ...
}
```

No DI container, no router abstraction, no server wrapper. `main.go` IS the wiring.

### BaseRepository & Implementation

```go
// internal/infrastructure/database/base.go
type BaseRepository struct {
    txManager *TxManager
}

func (r *BaseRepository) Querier(ctx context.Context) Querier {
    return r.txManager.GetQuerier(ctx)
}

func (r *BaseRepository) HandleError(err error) error {
    if errors.Is(err, pgx.ErrNoRows) {
        return domain.ErrNotFound
    }
    var pgErr *pgconn.PgError
    if errors.As(err, &pgErr) && pgErr.Code == "23505" {
        return domain.ErrConflict
    }
    return fmt.Errorf("database error: %w", err)
}
```

```go
// internal/infrastructure/repository/file_repository.go
type FileRepository struct {
    database.BaseRepository
}

func NewFileRepository(txManager *database.TxManager) *FileRepository {
    return &FileRepository{BaseRepository: database.BaseRepository{TxManager: txManager}}
}

func (r *FileRepository) Create(ctx context.Context, file *entity.File) error {
    queries := sqlcgen.New(r.Querier(ctx))
    err := queries.CreateFile(ctx, sqlcgen.CreateFileParams{
        ID: file.ID, FolderID: file.FolderID, OwnerID: file.OwnerID,
        Name: file.Name.String(), Size: file.Size, Status: string(file.Status),
    })
    if err != nil {
        return r.HandleError(err)
    }
    return nil
}
```

## Anti-Patterns (Prohibited)

| Anti-Pattern | Why | Correct Approach |
|---|---|---|
| JSON/DB tags on domain entities | Couples domain to infrastructure | Tags on infrastructure models only; protobuf handles API serialization |
| Private fields + getters on entities | Non-idiomatic Go, boilerplate | Exported fields + behavior methods |
| Mixed-concern files (DB + HTTP + cache) | Violates single responsibility | One file per concern in infrastructure |
| Business rules in UseCase layer | Logic belongs in domain | Push into Entity/Value Object methods |
| Handler calls Repository directly | Skips UseCase orchestration | Handler -> UseCase -> Repository |
| Raw primitives for domain concepts | No validation, no type safety | Value Objects with constructor validation |
| Transaction per repository method | Cross-entity atomicity impossible | TransactionManager.WithTransaction in UseCase |
| Custom error type hierarchy | Duplicates `connect.NewError` | `connect.NewError(code, err)` at handler boundary |
| DI container for simple wiring | Unnecessary abstraction | Direct wiring in `main.go` |
| Separate router/server packages | Over-abstraction for 1 `mux.Handle()` | Inline in `main.go` |
| DTO/presenter packages | Duplicates protobuf serialization | Protobuf messages ARE the DTOs |
| UseCase Input/Output with JSON tags | Couples UseCase to HTTP | Plain structs with no tags |
