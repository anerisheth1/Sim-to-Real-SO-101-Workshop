# Real teleop collection plan (SO-101, task: "Pick up the vial and place it in the yellow rack")

Two datasets, one per lighting condition (lerobot-record needs the dataset dir NOT to exist yet; it creates it):
  yellow_light/   -> repo_id anerishe/so101_vials_real_yellow_light
  white_light/    -> repo_id anerishe/so101_vials_real_white_light

Each run is a single pick-and-place event (one vial picked up and placed in the rack).
Per lighting: 10 runs; 20 total.

Runs (run N = episode index N-1), same for both lightings. Mark done as you go.
  Runs 1-3  (ep0-2): rack + 1 vial on the floor
  Runs 4-6  (ep3-5): 2 vials on the floor
  Runs 7-9  (ep6-8): 3 vials on the floor
  Run 10    (ep9):   rack on the opposite side, 2 vials on the ground

  run 1   ep0  [ ] yellow  [ ] white
  run 2   ep1  [ ] yellow  [ ] white
  run 3   ep2  [ ] yellow  [ ] white
  run 4   ep3  [ ] yellow  [ ] white
  run 5   ep4  [ ] yellow  [ ] white
  run 6   ep5  [ ] yellow  [ ] white
  run 7   ep6  [ ] yellow  [ ] white
  run 8   ep7  [ ] yellow  [ ] white
  run 9   ep8  [ ] yellow  [ ] white
  run 10  ep9  [ ] yellow  [ ] white

Notes
- Keep the camera names ego (wrist) and external_D455 (front); they must match the training config.
- Scenario labels are NOT stored in the dataset (one task string for all). This file is the only record of which episode is which setup.
- If an episode is bad, press Left arrow during recording to re-record it, so the run order above stays aligned.
