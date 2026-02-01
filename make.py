import os
import shutil
import subprocess
import json
import argparse

openscad_paths = [
    "openscad",
    r"C:\Program Files\OpenSCAD (Nightly)\openscad.exe",
    r"C:\Program Files\OpenSCAD\openscad.exe",
]

params_filename = "ecvt.scad"
json_filename = "ecvt.json"  # Actual param values stored here

# Models dependent on params
include_folder = "."
model_filenames = ["ecvt.scad"]

# Independent files
include_filenames = []

part_names = [
    "assembly",
    "planetary_gear",
    "carrier",
    "sun_shaft",
    "planet_shaft",
    "shaft_handle",
    "small_gear",
    "small_gear_reverse",
    "small_shaft",
    "small_shaft_h",
    "base",
]

build_folder = "build"

# Openscad flags
use_manifold = True
hard_warnings = False

# Build everything
with open(json_filename) as json_file:
    params = json.load(json_file)
parametersets = params["parameterSets"]
buildsets = parametersets.keys()


def main():
    # Parse input arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("--openscad_path", default=None)
    args = vars(parser.parse_args())
    openscad_path = args["openscad_path"]

    if openscad_path is None:
        # Find openscad path
        for default_path in openscad_paths:
            try:
                subprocess.run([default_path, "--version"])
                openscad_path = default_path
                break
            except:
                pass
        if openscad_path is None:
            raise Exception(
                "Openscad is not found! Please provide openscad path using --openscad_path"
            )

    # Remove old build folder
    if os.path.exists(build_folder):
        shutil.rmtree(build_folder)

    # Make new folder for each build set
    os.mkdir(build_folder)
    for buildset in buildsets:
        os.mkdir(os.path.join(build_folder, buildset))

    for parameterset in parametersets:
        # Replace all given variables of json in params filename

        for part_name in part_names:
            output_stl = os.path.join(
                build_folder,
                parameterset,
                f"{part_name}_{parameterset}.stl",
            )
            command = [
                openscad_path,
                "-o",
                output_stl,
                "-p",
                json_filename,
                "-P",
                parameterset,
                "-D",
                f'selected_part="{part_name}"',
                params_filename,
            ]
            if use_manifold:
                command += ["--backend=manifold"]
            if hard_warnings:
                command += ["--hardwarnings"]
            subprocess.run(
                command,
                shell=False,
                check=True,
            )

    print("\nDone")


if __name__ == "__main__":
    main()
