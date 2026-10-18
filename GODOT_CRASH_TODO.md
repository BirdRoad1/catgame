# TODO: Godot engine crash (use-after-free) — report + PR

Repro project: `/home/user/godot_crash_repro` (crashes 4.7.2 with signal 11 in `SelfList::remove`).

## The engine bug

`GDScript::_create_instance` in `modules/gdscript/gdscript.cpp` — both constructor-error branches
(`@implicit_new` ~L179-184 and `_init` ~L197-202 on master) do:

1. `instance->script = Ref<GDScript>();`
2. `instance->owner->set_script_instance(nullptr);` ← `memdelete`s `instance` (`core/object/object.cpp` `Object::set_script_instance`)
3. `instances.remove(&instance->script_instance_list);` ← reads freed memory

- 4.7.2: destructor skips unlinking (because `script` was cleared), so step 3 segfaults.
- master (`81ab961`, 2026-10-16): destructor now calls `script_instance_list.remove_from_list()`
  unconditionally, but step 3 still dereferences the dangling pointer → still UAF (may just print an
  error instead of crashing; ASan should catch it).

## Next steps

- [ ] Search Godot issues/PRs for an existing report ("Error constructing a GDScriptInstance", use-after-free)
- [ ] `git log`/`blame` the destructor change on master — see why the error branches were left alone
- [ ] Build master with `debug_symbols=yes use_asan=yes` and run the repro to confirm
      - Python < 3.14 needs the `zstandard` module for the build (I used a venv with `scons` + `zstandard`)
      - The clone/venv I started in Claude's scratchpad is temporary — clone your own fork instead
- [ ] Fix both branches (on master the explicit `remove` is redundant *and* unsafe); check `_new`'s owner cleanup for double-free
- [ ] Add a regression test under `modules/gdscript/tests/scripts/runtime/errors/`
- [ ] Minimize the repro, file the issue (4.7.2 + master), open the PR
