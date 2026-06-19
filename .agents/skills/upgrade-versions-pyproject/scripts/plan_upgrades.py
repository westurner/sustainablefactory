#!/usr/bin/env python3
"""
Helper script for planning version upgrades in pyproject.toml files.

Usage:
    python plan_upgrades.py [--target PATTERN] [--exclude PACKAGES] [--format json|table]

Examples:
    python plan_upgrades.py --target 'src/*/pyproject.toml' --format json
    python plan_upgrades.py --target all --format table --exclude pytest,sphinx
"""

import json
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import argparse
import re


def find_pyproject_files(target: str, workspace: Optional[Path] = None) -> List[Path]:
    """Discover pyproject.toml files based on target specification."""
    if workspace is None:
        workspace = Path.cwd()
    
    if target == "all":
        # Find all pyproject.toml files
        return sorted(workspace.glob("**/pyproject.toml"))
    elif "*" in target or "?" in target:
        # Glob pattern
        return sorted(workspace.glob(target))
    else:
        # Single file path
        path = workspace / target if not Path(target).is_absolute() else Path(target)
        if path.exists():
            return [path]
        return []


def parse_pyproject_dependencies(file_path: Path) -> Dict[str, str]:
    """Parse dependencies from pyproject.toml file.
    
    Returns dict of {package_name: version_specifier}
    E.g., {"click": ">=8.1.0", "pytest": ">=7.0"}
    """
    import tomllib
    
    try:
        with open(file_path, "rb") as f:
            data = tomllib.load(f)
    except Exception as e:
        print(f"Warning: Failed to parse {file_path}: {e}", file=sys.stderr)
        return {}
    
    deps = {}
    
    # Get main dependencies
    if "project" in data and "dependencies" in data["project"]:
        for dep in data["project"]["dependencies"]:
            # Skip local paths
            if dep.startswith("-e"):
                continue
            
            # Parse package name and version
            # Format: "package>=1.0.0" or "package" or "package[extra]>=1.0"
            match = re.match(r'^([a-zA-Z0-9._-]+)(\[.*?\])?(.*)$', dep)
            if match:
                package_name = match.group(1)
                version_spec = match.group(3) if match.group(3) else ""
                deps[package_name] = version_spec or ""
    
    return deps


def get_latest_version(package: str) -> Optional[str]:
    """Query pip for the latest version of a package."""
    try:
        result = subprocess.run(
            ["pip", "index", "versions", package],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        # Look for "LATEST:" line
        for line in result.stdout.split("\n"):
            if "LATEST:" in line:
                version = line.split("LATEST:")[-1].strip()
                return version
        
        return None
    except Exception as e:
        print(f"Warning: Failed to check version for {package}: {e}", file=sys.stderr)
        return None


def extract_version_number(spec: str) -> Optional[str]:
    """Extract version number from a version specifier.
    
    E.g., ">=8.1.0" -> "8.1.0"
    """
    match = re.search(r'\d+\.\d+(?:\.\d+)?', spec)
    if match:
        return match.group()
    return None


def plan_upgrades(
    file_path: Path,
    exclude: Optional[List[str]] = None
) -> Dict:
    """Plan upgrades for a single pyproject.toml file."""
    if exclude is None:
        exclude = []
    
    exclude_lower = [p.lower() for p in exclude]
    deps = parse_pyproject_dependencies(file_path)
    
    plan = {
        "file": str(file_path),
        "upgrades": [],
        "already_current": [],
        "skipped": [],
        "errors": []
    }
    
    for package, current_spec in deps.items():
        if package.lower() in exclude_lower:
            plan["skipped"].append({
                "package": package,
                "reason": "excluded"
            })
            continue
        
        current_version = extract_version_number(current_spec)
        latest = get_latest_version(package)
        
        if latest is None:
            plan["errors"].append({
                "package": package,
                "reason": "could not fetch latest version"
            })
            continue
        
        if current_version != latest:
            plan["upgrades"].append({
                "package": package,
                "old_version": current_version or current_spec,
                "new_version": latest
            })
        else:
            plan["already_current"].append({
                "package": package,
                "version": current_version
            })
    
    return plan


def main():
    parser = argparse.ArgumentParser(
        description="Plan version upgrades for pyproject.toml files"
    )
    parser.add_argument(
        "--target",
        default="all",
        help="Target file(s): 'all', file path, or glob pattern"
    )
    parser.add_argument(
        "--exclude",
        default="",
        help="Comma-separated packages to skip"
    )
    parser.add_argument(
        "--format",
        choices=["json", "table"],
        default="table",
        help="Output format"
    )
    parser.add_argument(
        "--workspace",
        default=None,
        help="Workspace root directory (default: current directory)"
    )
    
    args = parser.parse_args()
    
    workspace = Path(args.workspace) if args.workspace else Path.cwd()
    exclude = [p.strip() for p in args.exclude.split(",") if p.strip()]
    
    files = find_pyproject_files(args.target, workspace)
    
    if not files:
        print(f"No pyproject.toml files found matching target: {args.target}")
        sys.exit(1)
    
    all_plans = []
    for file_path in files:
        plan = plan_upgrades(file_path, exclude)
        all_plans.append(plan)
    
    if args.format == "json":
        print(json.dumps(all_plans, indent=2))
    else:
        # Table format
        total_upgrades = 0
        total_current = 0
        total_errors = 0
        
        for plan in all_plans:
            print(f"\n{plan['file']}")
            print("-" * 80)
            
            if plan["upgrades"]:
                print(f"  Upgradable ({len(plan['upgrades'])}):")
                for upg in plan["upgrades"]:
                    print(f"    {upg['package']}: {upg['old_version']} → {upg['new_version']}")
                total_upgrades += len(plan["upgrades"])
            
            if plan["already_current"]:
                print(f"  Already Current ({len(plan['already_current'])}):")
                for curr in plan["already_current"]:
                    print(f"    {curr['package']}: {curr['version']}")
                total_current += len(plan["already_current"])
            
            if plan["skipped"]:
                print(f"  Skipped ({len(plan['skipped'])}):")
                for skip in plan["skipped"]:
                    print(f"    {skip['package']}: {skip['reason']}")
            
            if plan["errors"]:
                print(f"  Errors ({len(plan['errors'])}):")
                for err in plan["errors"]:
                    print(f"    {err['package']}: {err['reason']}")
                total_errors += len(plan["errors"])
        
        print("\n" + "=" * 80)
        print(f"Summary: {total_upgrades} upgradable, {total_current} current, {total_errors} errors")


if __name__ == "__main__":
    main()
