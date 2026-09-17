#!/usr/bin/env python3
"""
Features:
- Recursive dependency resolution via metainfo.json
- Generates Vivado Tcl script(s)
- Interactive index-based menu
- Dependency graph view

Usage:
    python build.py
"""

import sys
from pathlib import Path
import json
from subprocess import call

# CONFIG
FPGA_PART = "xc7a35tcpg236-1"

# CONSTANTS
MODULE_METAINFO_FILE_NAME = 'metainfo.json'
DEPS_FILED_NAME = 'dependencies'    # Scope: metainfo file
MODULE_PROJECT_DIR_SUFFIX = '_proj'
SRS_DIR_NAME = 'src'                # Scope: project
SIM_DIR_NAME = 'sim'                # Scope: project
CONSTRS_DIR_NAME = 'constrs'        # Scope: project
SRS_FILES_EXT = '.sv'               # Scope: project
SIM_FILES_EXT = '.sv'               # Scope: project
CONSTRS_FILES_EXT = '.xdc'          # Scope: project
WORKDIR_NAME = 'workdir'
BUILD_DIR_PREFIX = "vivado_build_"

# EXPECTED HW UNITS SET
'''
UNITS:
  Ptah    - SW-only unit
  Service - HW-only unit
  Sia     - HW-only unit
  Thoth   - SW/HW unit
  Wadjet  - SW/HW unit
  Nets    - HW-only unit
'''
UNITS = ("Service", "Sia", "Thoth/HW", "Wadjet/HW", "Nets", "ASD", "Wadjet/SDF")


######### HELPERS BEGIN
def log(msg):
    print(f"(INFO) {msg}")

def warn(msg):
    print(f"(WARN) {msg}")

def error(msg):
    print(f"(ERROR) {msg}")
    sys.exit(1)

def is_positive_numeric(s: str) -> bool:
    try:
        val = float(s)
        return val >= 0
    except ValueError:
        return False
######### HELPERS END


######### DEPENDENCY SYSTEM BEGIN
def parse_module_metainfo(file_path: Path):
    if not file_path.exists():
        return None

    with open(file_path, 'r', encoding="utf-8") as f:
        metainfo_data = json.load(f)

    return metainfo_data.get(DEPS_FILED_NAME, None)


class Module:
    def __init__(self, module_path: Path, root: Path):
        self.path = module_path.resolve()
        self.root = root
        self.name = module_path.name

        # Raw dep strings from metainfo.json (repo-root relative)
        self.dep_names = parse_module_metainfo(self.path / MODULE_METAINFO_FILE_NAME) or []

        # Filled in later by BuildSystem once all modules are known
        self.dep_ids = []        # resolved module IDs ("u.m")
        self.missing_deps = []   # raw strings that couldn't be resolved

        self.src_files = []
        self.sim_files = []
        self.xdc_files = []

        proj_dirs = list(self.path.glob(f"*{MODULE_PROJECT_DIR_SUFFIX}"))
        if not proj_dirs:
            warn(f"No *{MODULE_PROJECT_DIR_SUFFIX} in '{self.path}' directory")

        for proj in proj_dirs:
            proj = proj.resolve()
            self.src_files.extend(sorted((proj / SRS_DIR_NAME).glob(f"*{SRS_FILES_EXT}")))
            self.sim_files.extend(sorted((proj / SIM_DIR_NAME).glob(f"*{SIM_FILES_EXT}")))
            self.xdc_files.extend(sorted((proj / CONSTRS_DIR_NAME).glob(f"*{CONSTRS_FILES_EXT}")))

        self.src_files = [p.resolve() for p in self.src_files]
        self.sim_files = [p.resolve() for p in self.sim_files]
        self.xdc_files = [p.resolve() for p in self.xdc_files]

    def __repr__(self):
        return f"Module '{self.name}': Path: '{self.path}'"


class BuildSystem:
    def __init__(self, root: Path):
        self.root = root.resolve()
        self.workdir = self.root / WORKDIR_NAME
        self.workdir.mkdir(parents=True, exist_ok=True)
        self.fpga_part = FPGA_PART

        '''
        self.structure = {
            <unit_id>: {
                "unit_name": <unit_name>,
                "path": <unit_path>,
                "modules": { <module_id>: <Module_obj>, ... }
            },
            ...
        }
        '''
        self.structure = {}
        self.module_ids_by_path = {}  # {Path: module_id, ...}
        self.build_modules_set = set()

        # Scan units and build Module objects
        for u_id, curr_unit in enumerate(UNITS):
            unit_path = (self.root / curr_unit).resolve()
            if not unit_path.exists():
                warn(f"Expected unit '{curr_unit}' is missed")
                continue

            modules = {}
            for m_id, p in enumerate(
                sorted(filter(Path.is_dir, unit_path.iterdir()), key=lambda x: x.name),
                start=1,
            ):
                module_id = f"{u_id}.{m_id}"
                module = Module(p, self.root)
                modules[module_id] = module
                self.module_ids_by_path[module.path] = module_id

            self.structure[str(u_id)] = {
                "unit_name": curr_unit,
                "path": unit_path,
                "modules": modules,
            }

        # Resolve dependency strings to module IDs (second pass)
        self._resolve_dep_ids()

    def _resolve_dep_ids(self):
        for unit in self.structure.values():
            for module in unit['modules'].values():
                for dep_name in module.dep_names:
                    dep_path = (self.root / dep_name).resolve()
                    dep_id = self.module_ids_by_path.get(dep_path)
                    if dep_id is None:
                        module.missing_deps.append(dep_name)
                    else:
                        module.dep_ids.append(dep_id)

    def _sorted_module_ids(self, module_ids):
        return sorted(module_ids, key=lambda x: (int(x.split(".")[0]), int(x.split(".")[1])))

    ######### VIEWS BEGIN
    def print_structure(self):
        print("\n===== MODULE STRUCTURE =====")
        for unit_id in sorted(self.structure.keys(), key=int):
            unit = self.structure[unit_id]
            print(f"[{unit_id}] Unit '{unit['unit_name']}'")
            if not unit['modules']:
                print("\t(no modules)")
                continue
            for mod_id in self._sorted_module_ids(unit['modules'].keys()):
                m = unit['modules'][mod_id]
                n = len(m.dep_ids) + len(m.missing_deps)
                suffix = f" ({n} deps)" if n else ""
                print(f"\t[{mod_id}] '{m.name}'{suffix}")
        print()

    def print_dependency_graph(self):
        print("\n===== DEPENDENCY GRAPH =====")
        for unit_id in sorted(self.structure.keys(), key=int):
            unit = self.structure[unit_id]
            print(f"\n[Unit {unit_id}] '{unit['unit_name']}'")
            for mod_id in self._sorted_module_ids(unit['modules'].keys()):
                self._print_module_tree(mod_id, "\t")
        print()

    def _print_module_tree(self, mod_id, indent):
        unit_id = mod_id.split(".")[0]
        module = self.structure[unit_id]['modules'][mod_id]

        total = len(module.dep_ids) + len(module.missing_deps)
        suffix = f"\t({total} deps)" if total else ""
        print(f"{indent}[{mod_id}] {module.name}{suffix}")

        if not total:
            print(f"{indent}    (no dependencies)")
            return

        self._print_dep_children(mod_id, indent + "\t", {mod_id})

    def _print_dep_children(self, mod_id, indent, stack):
        unit_id = mod_id.split(".")[0]
        module = self.structure[unit_id]['modules'][mod_id]

        # Build a flat list of children: resolved IDs + missing names
        children = [(dep_id, None) for dep_id in module.dep_ids] + \
                   [(None, dep_name) for dep_name in module.missing_deps]

        for i, (dep_id, dep_name) in enumerate(children):
            last = (i == len(children) - 1)
            branch = "└──" if last else "├──"

            if dep_id is None:
                print(f"{indent}{branch}[??] {dep_name} [MISSING]")
                continue

            dep_unit_id = dep_id.split(".")[0]
            dep_module = self.structure[dep_unit_id]['modules'][dep_id]
            marker = "\t[CYCLE]" if dep_id in stack else ""
            print(f"{indent}{branch}[{dep_id}] {dep_module.name}{marker}")

            if dep_id not in stack:
                stack.add(dep_id)
                child_indent = indent + ("\t" if last else "│  ")
                self._print_dep_children(dep_id, child_indent, stack)
                stack.discard(dep_id)
    ######### VIEWS END

    ######### SELECTION BEGIN
    def read_build_list(self):
        print("Select Unit(s)/Module(s) by index — comma-separated (e.g. '1, 2.2, 4'). Type 'all' for everything.")
        raw = input(": ").strip()

        self.build_modules_set = set()

        if not raw:
            return
        if raw.lower() == "all":
            for unit in self.structure.values():
                self.build_modules_set.update(unit['modules'].keys())
            return

        for token in raw.split(","):
            sel = token.strip()
            if not sel:
                continue
            if not is_positive_numeric(sel):
                warn(f"Incorrect entity '{sel}'")
                continue

            # Unit index -> add all its modules
            if sel in self.structure:
                self.build_modules_set.update(self.structure[sel]['modules'].keys())
                continue

            # Module index 'u.m'
            uid_str = str(int(float(sel)))
            if uid_str in self.structure and sel in self.structure[uid_str]['modules']:
                self.build_modules_set.add(sel)
            else:
                warn(f"Unknown entity '{sel}'")
    ######### SELECTION END

    ######### RESOLUTION BEGIN
    def resolve_module(self, module, visited=None, collected=None):
        """
        DFS (Depth-First Search) from `module`. Dependencies first, then the module's own files.
        `visited` is shared across the whole walk -> each module contributes
        its files at most once (diamonds collapse, cycles are skipped).
        """
        if visited is None:
            visited = set()
        if collected is None:
            collected = {"src": [], "sim": [], "xdc": []}

        if module.path in visited:
            return collected
        visited.add(module.path)

        # Deps first (leaf-first order)
        for dep_id in module.dep_ids:
            dep_unit_id = dep_id.split(".")[0]
            dep_module = self.structure[dep_unit_id]['modules'][dep_id]
            self.resolve_module(dep_module, visited, collected)

        # Then our own files, deduped
        for key, files in (("src", module.src_files),
                           ("sim", module.sim_files),
                           ("xdc", module.xdc_files)):
            existing = set(collected[key])
            for f in files:
                if f not in existing:
                    collected[key].append(f)
                    existing.add(f)

        return collected
    ######### RESOLUTION END

    ######### FPGA PART BEGIN
    def change_fpga_part(self):
        print(f"Current FPGA part: {self.fpga_part}")
        new_part = input("Enter new FPGA part (empty to keep current): ").strip()
        if not new_part:
            log("FPGA part unchanged")
            return
        self.fpga_part = new_part
        log(f"FPGA part set to: {self.fpga_part}")
    ######### FPGA PART END

    ######### TCL GENERATION BEGIN
    def generate_tcl_scripts(self):
        if not self.build_modules_set:
            warn("Nothing selected — build list is empty")
            return

        print(f"\nGenerating TCL for {len(self.build_modules_set)} module(s) -> {self.workdir}\n")

        for module_id in self._sorted_module_ids(self.build_modules_set):
            unit_id = module_id.split(".")[0]
            module = self.structure[unit_id]['modules'][module_id]

            log(f"[{module_id}] {module.name}: resolving dependencies...")
            for missing in module.missing_deps:
                warn(f"\tmissing dependency: '{missing}'")

            collected = self.resolve_module(module)
            log(f"design={len(collected['src'])} "
                f"sim={len(collected['sim'])} "
                f"xdc={len(collected['xdc'])}")

            tcl_text = generate_tcl(
                module,
                collected['src'],
                collected['sim'],
                collected['xdc'],
                self.fpga_part
            )

            out_path = self.workdir / f"build_{module.name}.tcl"
            out_path.write_text(tcl_text, encoding="utf-8")
            log(f"-> {out_path}")

        print()
    ######### TCL GENERATION END


######### TCL HELPERS BEGIN
def paths_to_tcl(paths):
    """Convert resolved paths to quoted POSIX form for Vivado Tcl."""
    return " ".join(f'"{p.as_posix()}"' for p in paths)


def generate_tcl(module, design, sim, xdc, fpga_part):
    proj_name = module.name
    build_dir = f"{BUILD_DIR_PREFIX}{proj_name}"

    lines = [
        "# Auto-generated Vivado script",
        f"# Module: {module.name}",
        f"# Part:   {fpga_part}",
        "",
        f"create_project {proj_name} {build_dir} -part {fpga_part} -force",
        "",
    ]

    if design:
        lines.append(f"add_files -fileset sources_1 {paths_to_tcl(design)}")
        lines.append("update_compile_order -fileset sources_1")
    else:
        lines.append("# (no design sources found)")

    if sim:
        lines.append(f"add_files -fileset sim_1 {paths_to_tcl(sim)}")
        lines.append("update_compile_order -fileset sim_1")

    if xdc:
        lines.append(f"add_files -fileset constrs_1 {paths_to_tcl(xdc)}")

    lines += [
        "",
        f"set_property top {proj_name} [current_fileset]",
        f'puts "Project created: {proj_name}"',
        "",
    ]
    return "\n".join(lines)
######### TCL HELPERS END


######### MENU BEGIN
def interactive_menu(build: BuildSystem):
    while True:
        print("=" * 60)
        print(" Ptah Build System")
        print(f" FPGA part: {build.fpga_part}")
        print("=" * 60)
        print(" 1. Show module structure")
        print(" 2. Show dependency graph")
        print(" 3. Generate TCL script(s)")
        print(" 4. Change FPGA part")
        print(" 0. Exit")

        choice = input("Select: ").strip()

        if choice == "0":
            return
        elif choice == "1":
            build.print_structure()
        elif choice == "2":
            build.print_dependency_graph()
        elif choice == "3":
            build.print_structure()
            build.read_build_list()
            build.generate_tcl_scripts()
        elif choice == "4":
            build.change_fpga_part()
        else:
            warn(f"Unknown menu option '{choice}'")
######### MENU END


def main():
    # <root>/Ptah/build.py
    root = Path(__file__).resolve().parent.parent

    build = BuildSystem(root)
    interactive_menu(build)


if __name__ == "__main__":
    main()