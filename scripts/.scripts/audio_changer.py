#!/usr/bin/env python3
import json
import shutil
import subprocess
import sys
from typing import TypedDict, cast

# PipeWire property bags use dotted keys, so the functional TypedDict form is
# required. Both node info.props and metadata props use the same shape.
Props = TypedDict(
    "Props",
    {
        "media.class": str,
        "node.name": str,
        "node.description": str,
        "device.description": str,
        "node.nick": str,
        "metadata.name": str,
    },
    total=False,
)


class MetadataEntry(TypedDict, total=False):
    key: str
    value: object  # int | str | dict depending on the entry


class Info(TypedDict, total=False):
    props: Props
    state: str


class PwObject(TypedDict, total=False):
    id: int
    type: str
    info: Info
    props: Props
    metadata: list[MetadataEntry]


class Sink(TypedDict):
    id: int
    name: str
    node_name: str
    state: str
    is_default: bool


EMPTY_PROPS: Props = {}


def node_props(obj: PwObject) -> Props:
    """Props of a PipeWire node live under obj["info"]["props"]."""
    info = obj.get("info")
    if info is None:
        return EMPTY_PROPS
    return info.get("props", EMPTY_PROPS)


def default_sink_name(objects: list[PwObject]) -> str | None:
    """Read the current default sink name from the "default" metadata object."""
    for obj in objects:
        if obj.get("type") != "PipeWire:Interface:Metadata":
            continue
        # Metadata objects keep their props at the top level, not under "info".
        if obj.get("props", EMPTY_PROPS).get("metadata.name") != "default":
            continue
        for meta in obj.get("metadata", []):
            if meta.get("key") != "default.audio.sink":
                continue
            raw = meta.get("value")
            if isinstance(raw, dict):
                name = cast("dict[str, object]", raw).get("name")
                if isinstance(name, str):
                    return name
    return None


def get_audio_sinks() -> list[Sink]:
    """Get all available audio sinks using pw-dump JSON output."""
    try:
        # Get PipeWire state as JSON
        result = subprocess.run(["pw-dump"], capture_output=True, text=True, check=True)
        objects = cast("list[PwObject]", json.loads(result.stdout))

        current_default = default_sink_name(objects)

        # Find all audio sinks
        sinks: list[Sink] = []
        for obj in objects:
            if obj.get("type") != "PipeWire:Interface:Node":
                continue
            props = node_props(obj)
            if props.get("media.class") != "Audio/Sink":
                continue

            node_name = props.get("node.name", "")

            # Filter out virtual/internal sinks we can't switch to
            # Include ALSA devices and proper BlueZ devices
            if not node_name.startswith(("alsa_output.", "bluez_output.")):
                continue

            # Get a friendly display name
            display_name = (
                props.get("node.description")
                or props.get("device.description")
                or props.get("node.nick")
                or node_name
            )

            # Check if this is the current default
            is_default = node_name == current_default
            if is_default:
                display_name += " - Default"

            info = obj.get("info")
            sinks.append(
                Sink(
                    id=obj.get("id", -1),
                    name=display_name,
                    node_name=node_name,
                    state="unknown" if info is None else info.get("state", "unknown"),
                    is_default=is_default,
                )
            )

        # Sort sinks: default first, then by name
        sinks.sort(key=lambda sink: (not sink["is_default"], sink["name"]))

        return sinks

    except subprocess.CalledProcessError as e:
        print(f"Error running pw-dump: {e}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing pw-dump output: {e}")
        sys.exit(1)
    except OSError as e:
        print(f"Error: {e}")
        sys.exit(1)


def is_console_environment() -> bool:
    """Detect if running in a console environment or graphical environment."""
    return sys.stdin is not None and sys.stdin.isatty()


def set_default_sink(sink_id: int) -> None:
    """Set the default audio sink using wpctl."""
    try:
        _ = subprocess.run(["wpctl", "set-default", str(sink_id)], check=True)
        print(f"Successfully switched to audio sink ID {sink_id}")
    except subprocess.CalledProcessError as e:
        print(f"Error setting default sink: {e}")
        sys.exit(1)


def format_sinks(sinks: list[Sink]) -> str:
    """Render sinks as launcher input, marking the current default."""
    return "".join(
        f"-> {sink['name']}\n" if sink["is_default"] else f"{sink['name']}\n"
        for sink in sinks
    )


def select_sink_name(sinks: list[Sink]) -> str | None:
    """Prompt for a sink with fzf (console) or fuzzel (graphical).

    Returns the chosen entry, or None when the user cancels.
    """
    output = format_sinks(sinks)

    if is_console_environment():
        if shutil.which("fzf") is None:
            print(
                "Error: fzf is not installed. Please install it for console selection."
            )
            sys.exit(1)
        command = ("fzf", "--prompt=Select an audio sink: ", "--height=10")
    else:
        command = ("fuzzel", "--dmenu", "-i")

    try:
        process = subprocess.run(
            command,
            input=output,
            text=True,
            capture_output=True,
            check=True,
        )
    except FileNotFoundError:
        print(f"Error: {command[0]} is not installed.")
        sys.exit(1)
    except subprocess.CalledProcessError:
        return None

    return process.stdout.strip().removeprefix("-> ")


def main() -> None:
    # Get available sinks
    sinks = get_audio_sinks()

    if not sinks:
        print("No audio sinks found.")
        sys.exit(1)

    selected_sink_name = select_sink_name(sinks)
    if selected_sink_name is None:
        print("User cancelled the operation.")
        sys.exit(0)

    # Find the selected sink
    selected_sink_name_clean = selected_sink_name.replace(" - Default", "")
    selected_sink = next(
        (
            sink
            for sink in sinks
            if sink["name"].replace(" - Default", "") == selected_sink_name_clean
        ),
        None,
    )

    if selected_sink is None:
        print(f"Error: Could not find sink '{selected_sink_name}'")
        print("Available sinks:")
        for sink in sinks:
            print(f"  - {sink['name']} (ID: {sink['id']})")
        sys.exit(1)

    # Set the default sink
    set_default_sink(selected_sink["id"])


if __name__ == "__main__":
    main()
