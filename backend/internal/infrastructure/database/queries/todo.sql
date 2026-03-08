-- name: CreateTodo :exec
INSERT INTO todos (id, title, description, status, created_at, updated_at)
VALUES ($1, $2, $3, $4, $5, $6);

-- name: GetTodoByID :one
SELECT id, title, description, status, created_at, updated_at
FROM todos
WHERE id = $1;

-- name: ListTodos :many
SELECT id, title, description, status, created_at, updated_at
FROM todos
ORDER BY created_at DESC;

-- name: UpdateTodo :exec
UPDATE todos
SET title = $2, description = $3, status = $4, updated_at = $5
WHERE id = $1;

-- name: DeleteTodo :exec
DELETE FROM todos WHERE id = $1;
