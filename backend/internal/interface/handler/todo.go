package handler

import (
	"context"
	"errors"

	"connectrpc.com/connect"
	"github.com/google/uuid"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/entity"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/domain/valueobject"
	todov1 "github.com/Hiro-mackay/ai-bootstrap/backend/internal/gen/todo/v1"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/usecase/todo/command"
	"github.com/Hiro-mackay/ai-bootstrap/backend/internal/usecase/todo/query"
)

// TodoHandler implements the TodoService Connect RPC handler.
type TodoHandler struct {
	createCmd *command.CreateTodoCommand
	updateCmd *command.UpdateTodoCommand
	deleteCmd *command.DeleteTodoCommand
	getQuery  *query.GetTodoQuery
	listQuery *query.ListTodosQuery
}

// NewTodoHandler returns a new TodoHandler with all use cases wired.
func NewTodoHandler(
	createCmd *command.CreateTodoCommand,
	updateCmd *command.UpdateTodoCommand,
	deleteCmd *command.DeleteTodoCommand,
	getQuery *query.GetTodoQuery,
	listQuery *query.ListTodosQuery,
) *TodoHandler {
	return &TodoHandler{
		createCmd: createCmd,
		updateCmd: updateCmd,
		deleteCmd: deleteCmd,
		getQuery:  getQuery,
		listQuery: listQuery,
	}
}

func (h *TodoHandler) CreateTodo(
	ctx context.Context,
	req *connect.Request[todov1.CreateTodoRequest],
) (*connect.Response[todov1.CreateTodoResponse], error) {
	out, err := h.createCmd.Execute(ctx, command.CreateTodoInput{
		Title:       req.Msg.Title,
		Description: req.Msg.Description,
	})
	if err != nil {
		return nil, toConnectError(err)
	}

	return connect.NewResponse(&todov1.CreateTodoResponse{
		Todo: toTodoProto(out.Todo),
	}), nil
}

func (h *TodoHandler) GetTodo(
	ctx context.Context,
	req *connect.Request[todov1.GetTodoRequest],
) (*connect.Response[todov1.GetTodoResponse], error) {
	id, err := uuid.Parse(req.Msg.Id)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("invalid todo id"))
	}

	out, err := h.getQuery.Execute(ctx, query.GetTodoInput{ID: id})
	if err != nil {
		return nil, toConnectError(err)
	}

	return connect.NewResponse(&todov1.GetTodoResponse{
		Todo: toTodoProto(out.Todo),
	}), nil
}

func (h *TodoHandler) ListTodos(
	ctx context.Context,
	_ *connect.Request[todov1.ListTodosRequest],
) (*connect.Response[todov1.ListTodosResponse], error) {
	out, err := h.listQuery.Execute(ctx, query.ListTodosInput{})
	if err != nil {
		return nil, toConnectError(err)
	}

	todos := make([]*todov1.Todo, 0, len(out.Todos))
	for _, t := range out.Todos {
		todos = append(todos, toTodoProto(t))
	}

	return connect.NewResponse(&todov1.ListTodosResponse{
		Todos: todos,
	}), nil
}

func (h *TodoHandler) UpdateTodo(
	ctx context.Context,
	req *connect.Request[todov1.UpdateTodoRequest],
) (*connect.Response[todov1.UpdateTodoResponse], error) {
	id, err := uuid.Parse(req.Msg.Id)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("invalid todo id"))
	}

	input := command.UpdateTodoInput{ID: id}
	if req.Msg.Title != nil {
		input.Title = req.Msg.Title
	}
	if req.Msg.Description != nil {
		input.Description = req.Msg.Description
	}
	if req.Msg.Status != nil {
		s := protoStatusToDomain(*req.Msg.Status)
		input.Status = &s
	}

	out, err := h.updateCmd.Execute(ctx, input)
	if err != nil {
		return nil, toConnectError(err)
	}

	return connect.NewResponse(&todov1.UpdateTodoResponse{
		Todo: toTodoProto(out.Todo),
	}), nil
}

func (h *TodoHandler) DeleteTodo(
	ctx context.Context,
	req *connect.Request[todov1.DeleteTodoRequest],
) (*connect.Response[todov1.DeleteTodoResponse], error) {
	id, err := uuid.Parse(req.Msg.Id)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("invalid todo id"))
	}

	if err := h.deleteCmd.Execute(ctx, command.DeleteTodoInput{ID: id}); err != nil {
		return nil, toConnectError(err)
	}

	return connect.NewResponse(&todov1.DeleteTodoResponse{}), nil
}

func toTodoProto(t *entity.Todo) *todov1.Todo {
	return &todov1.Todo{
		Id:          t.ID.String(),
		Title:       t.Title.String(),
		Description: t.Description,
		Status:      domainStatusToProto(t.Status),
		CreatedAt:   timestamppb.New(t.CreatedAt),
		UpdatedAt:   timestamppb.New(t.UpdatedAt),
	}
}

func domainStatusToProto(s valueobject.TodoStatus) todov1.TodoStatus {
	switch s {
	case valueobject.TodoStatusCompleted:
		return todov1.TodoStatus_TODO_STATUS_COMPLETED
	case valueobject.TodoStatusPending:
		return todov1.TodoStatus_TODO_STATUS_PENDING
	default:
		return todov1.TodoStatus_TODO_STATUS_UNSPECIFIED
	}
}

func protoStatusToDomain(s todov1.TodoStatus) string {
	switch s {
	case todov1.TodoStatus_TODO_STATUS_COMPLETED:
		return "completed"
	case todov1.TodoStatus_TODO_STATUS_PENDING:
		return "pending"
	default:
		return ""
	}
}

func toConnectError(err error) error {
	switch {
	case errors.Is(err, domain.ErrNotFound):
		return connect.NewError(connect.CodeNotFound, err)
	case errors.Is(err, domain.ErrValidation):
		return connect.NewError(connect.CodeInvalidArgument, err)
	case errors.Is(err, domain.ErrConflict):
		return connect.NewError(connect.CodeAlreadyExists, err)
	case errors.Is(err, domain.ErrForbidden):
		return connect.NewError(connect.CodePermissionDenied, err)
	default:
		return connect.NewError(connect.CodeInternal, errors.New("internal error"))
	}
}
