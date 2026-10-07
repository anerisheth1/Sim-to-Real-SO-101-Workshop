#!/usr/bin/env bash
# Record real SO-101 teleop episodes; creates the dataset or resumes it if it already exists.
# Usage (inside the real-robot container):  /data_out/record_real.sh <yellow|white> [target_total_episodes]
# Needs ROBOT_PORT, TELEOP_PORT, ROBOT_ID, TELEOP_ID exported. DRY_RUN=1 prints the command only.
set -euo pipefail

LIGHT="${1:?usage: record_real.sh <yellow|white> [target_total_episodes]}"
TARGET="${2:-10}"
BASE="${BASE:-/data_out}"
PY="${PYTHON:-python}"
ROOT="$BASE/${LIGHT}_light"
REPO_ID="anerishe/so101_vials_real_${LIGHT}_light"
CAM_EGO="${CAMERA_GRIPPER:-2}"
CAM_EXT="${CAMERA_EXTERNAL:-0}"

for v in ROBOT_PORT TELEOP_PORT ROBOT_ID TELEOP_ID; do
  [ -n "${!v:-}" ] || { echo "Missing env var: $v" >&2; exit 1; }
done
case "$LIGHT" in yellow|white) ;; *) echo "light must be yellow or white" >&2; exit 1;; esac

# Silences the viewer's XDG_RUNTIME_DIR error
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-root}"
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"

RESUME=false
NUM="$TARGET"
if [ -f "$ROOT/meta/info.json" ]; then
  DONE=$("$PY" -c "import json,sys; print(json.load(open(sys.argv[1]))['total_episodes'])" "$ROOT/meta/info.json")
  NUM=$((TARGET - DONE))
  if [ "$NUM" -le 0 ]; then
    echo "$ROOT already has $DONE episodes (target $TARGET). Nothing to record."
    exit 0
  fi
  if [ "$DONE" -eq 0 ]; then
    # Leftover skeleton from an aborted run. Resuming it makes lerobot query the Hub, which fails
    # for a repo that doesn't exist, so move it aside and create fresh instead.
    BAK="$ROOT.empty_bak.$(date +%s)"
    echo "$ROOT has 0 episodes (aborted run) -> moving to $BAK and creating fresh."
    mv "$ROOT" "$BAK"
  else
    RESUME=true
    echo "Existing dataset with $DONE episodes -> resuming, recording $NUM more."
  fi
elif [ -d "$ROOT" ]; then
  if [ -z "$(ls -A "$ROOT")" ]; then
    echo "$ROOT exists but is empty -> removing the empty folder and creating fresh."
    rmdir "$ROOT"
  else
    echo "$ROOT exists but has no meta/info.json and is not empty (broken/partial dataset)." >&2
    echo "Inspect it, then move or delete it yourself and rerun. Not touching it." >&2
    exit 1
  fi
else
  echo "No existing dataset -> creating $ROOT."
fi

CMD=(lerobot-record
  --robot.type=so101_follower
  --robot.port="$ROBOT_PORT"
  --robot.id="$ROBOT_ID"
  --robot.cameras="{ ego: {type: opencv, index_or_path: $CAM_EGO, width: 640, height: 480, fps: 30}, external_D455: {type: opencv, index_or_path: $CAM_EXT, width: 640, height: 480, fps: 30} }"
  --teleop.type=so101_leader
  --teleop.port="$TELEOP_PORT"
  --teleop.id="$TELEOP_ID"
  --dataset.repo_id="$REPO_ID"
  --dataset.root="$ROOT"
  --dataset.single_task="Pick up the vial and place it in the yellow rack"
  --dataset.num_episodes="$NUM"
  --dataset.fps=30
  --dataset.episode_time_s=30
  --dataset.reset_time_s=30
  --dataset.push_to_hub=false
  --display_data=true
  --play_sounds=false
  --resume="$RESUME")

if [ "${DRY_RUN:-0}" = "1" ]; then printf '%q ' "${CMD[@]}"; echo; exit 0; fi
exec "${CMD[@]}"
