#!/usr/bin/env python3
"""
Features:
- Recursive dependency resolution via deps.txt
- Generates Vivado Tcl script

Usage:
    python build.py Nets/IN-1_IN3P-1_STP_STDP-1_GENS-2_SNN_HW
"""

import sys
from pathlib import Path

# CONFIG
FPGA_PART = "xc7a35tcpg236-1"
BUILD_DIR_PREFIX = "vivado_build_"

# HELPERS
def log(msg):
    print(f"[INFO] {msg}")

def error(msg):
    print(f"[ERROR] {msg}")
    sys.exit(1)

# DEPENDENCY SYSTEM
class Module:
    def __init__(self, path: Path):
        self.path = path.resolve()
        self.name = path.name

        self.deps = []
        self.src_files = []
        self.sim_files = []
        self.xdc_files = []

def read_deps(module_path: Path):
    deps_file = module_path / "deps.txt"
    deps = []

    if deps_file.exists():
        for line in deps_file.read_text().splitlines():
            line = line.strip()

            if not line or line.startswith("#"):
                continue

            deps.append(line)

    return deps

def collect_files(module: Module):
    proj_dirs = list(module.path.glob("*_proj"))

    if not proj_dirs:
        log(f"WARNING: No *_proj in {module.path}")
        return

    for proj in proj_dirs:
        proj = proj.resolve()
        src = [p.resolve() for p in (proj / "src").glob("*.sv")]
        sim = [p.resolve() for p in (proj / "sim").glob("*.sv")]
        xdc = [p.resolve() for p in (proj / "constrs").glob("*.xdc")]

        module.src_files.extend(src)
        module.sim_files.extend(sim)
        module.xdc_files.extend(xdc)

class BuildSystem:
    def __init__(self, root: Path):
        self.root = root.resolve()
        self.modules = {}
        self.visited = set()

    def resolve(self, module_path_str):
        if module_path_str in self.visited:
            return

        self.visited.add(module_path_str)

        module_path = (self.root / module_path_str).resolve()

        if not module_path.exists():
            error(f"Module not found: {module_path}")

        module = Module(module_path)
        self.modules[module_path_str] = module

        log(f"Resolving {module_path_str}")

        # Resolve dependencies first
        deps = read_deps(module_path)
        module.deps = deps

        for dep in deps:
            self.resolve(dep)

        # Collect files
        collect_files(module)

    def gather_all_files(self):
        design = []
        sim = []
        xdc = []

        for module in self.modules.values():
            design.extend(module.src_files)
            sim.extend(module.sim_files)
            xdc.extend(module.xdc_files)

        return design, sim, xdc

# TCL GENERATION
def paths_to_tcl(paths):
    """
    Convert paths to POSIX format for Vivado Tcl.
    Paths are already resolved, so just convert style.
    """
    return " ".join([f'"{p.as_posix()}"' for p in paths])

def generate_tcl(target, design, sim, xdc):
    proj_name = Path(target).name
    build_dir = f"{BUILD_DIR_PREFIX}{proj_name}"

    tcl = f"""
# Auto-generated Vivado script

create_project {proj_name} {build_dir} -part {FPGA_PART} -force

# Add design sources
add_files -fileset sources_1 {paths_to_tcl(design)}

# Add simulation sources
add_files -fileset sim_1 {paths_to_tcl(sim)}

# Add constraints
add_files -fileset constrs_1 {paths_to_tcl(xdc)}

# Set top module
set_property top {proj_name} [current_fileset]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Project created: {proj_name}"
"""
    return tcl



def main():
    if len(sys.argv) < 2:
        error("Usage: python build.py <MODULE_PATH>")

    target = sys.argv[1]
    root = Path.cwd()

    build = BuildSystem(root)

    # Resolve dependencies
    build.resolve(target)

    design, sim, xdc = build.gather_all_files()

    log(f"Design files: {len(design)}")
    log(f"Simulation files: {len(sim)}")
    log(f"Constraints: {len(xdc)}")

    tcl_script = generate_tcl(target, design, sim, xdc)

    tcl_path = Path("build_generated.tcl")
    tcl_path.write_text(tcl_script)

    log(f"Tcl script generated: {tcl_path}")



if __name__ == "__main__":
    main()
