#!/bin/sh
set -eu

ADMIN_PASSWORD_FILE="/run/secrets/rabbitmq_admin_password"
USER_PASSWORD_FILE="/run/secrets/rabbitmq_system_user_password"

export RABBITMQ_DEFAULT_PASS="$(cat "$ADMIN_PASSWORD_FILE")"

rabbitmq-server &
pid="$!"

trap 'kill -TERM "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null || true' INT TERM

until rabbitmq-diagnostics -q ping >/dev/null 2>&1; do
  sleep 1
done

rabbitmqctl add_vhost "specialvhost" >/dev/null 2>&1 || true

rabbitmqctl set_user_tags "magicadmin" administrator >/dev/null 2>&1 || true

USER_PASSWORD="$(cat "$USER_PASSWORD_FILE")"
rabbitmqctl add_user "magicsystemuser" "$USER_PASSWORD" >/dev/null 2>&1 || true

rabbitmqctl set_permissions -p "specialvhost" "magicadmin" ".*" ".*" ".*" >/dev/null 2>&1 || true
rabbitmqctl set_permissions -p "specialvhost" "magicsystemuser"  ".*" ".*" ".*" >/dev/null 2>&1 || true

rabbitmqctl delete_user "guest" >/dev/null 2>&1 || true

wait "$pid"
