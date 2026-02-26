#!/usr/bin/env python3
import sys
import json
import subprocess

def get_audio_sinks():
    """Get all available audio sinks using pw-dump JSON output."""
    try:
        # Get PipeWire state as JSON
        result = subprocess.run(['pw-dump'], capture_output=True, text=True, check=True)
        data = json.loads(result.stdout)
        
        # Find current default sink
        default_sink_name = None
        for obj in data:
            if (obj.get('type') == 'PipeWire:Interface:Metadata' and 
                obj.get('props', {}).get('metadata.name') == 'default'):
                metadata = obj.get('metadata', [])
                for meta in metadata:
                    if meta.get('key') == 'default.audio.sink':
                        default_sink_name = meta.get('value', {}).get('name')
                        break
                break
        
        # Find all audio sinks
        sinks = []
        for obj in data:
            if (obj.get('type') == 'PipeWire:Interface:Node' and
                obj.get('info', {}).get('props', {}).get('media.class') == 'Audio/Sink'):
                
                props = obj['info']['props']
                sink_id = obj['id']
                node_name = props.get('node.name', '')
                
                # Get a friendly display name
                display_name = (props.get('node.description') or 
                               props.get('device.description') or 
                               props.get('node.nick') or 
                               node_name)
                
                # Check if this is the current default
                is_default = node_name == default_sink_name
                if is_default:
                    display_name += " - Default"
                
                # Filter out virtual/internal sinks we can't switch to
                # Include ALSA devices and proper BlueZ devices
                if (node_name.startswith('alsa_output.') or 
                    node_name.startswith('bluez_output.')):
                    
                    sinks.append({
                        'id': sink_id,
                        'name': display_name,
                        'node_name': node_name,
                        'state': obj.get('info', {}).get('state', 'unknown'),
                        'is_default': is_default
                    })
        
        # Sort sinks: default first, then by name
        sinks.sort(key=lambda x: (not x['is_default'], x['name']))
        
        return sinks
        
    except subprocess.CalledProcessError as e:
        print(f"Error running pw-dump: {e}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing pw-dump output: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)

def is_console_environment():
    """Detect if running in a console environment or graphical environment."""
    return sys.stdin and sys.stdin.isatty()

def set_default_sink(sink_id):
    """Set the default audio sink using wpctl."""
    try:
        subprocess.run(['wpctl', 'set-default', str(sink_id)], check=True)
        print(f"Successfully switched to audio sink ID {sink_id}")
    except subprocess.CalledProcessError as e:
        print(f"Error setting default sink: {e}")
        sys.exit(1)

def main():
    # Get available sinks
    sinks = get_audio_sinks()
    
    if not sinks:
        print("No audio sinks found.")
        sys.exit(1)
    
    # Detect environment and choose interface
    use_console = is_console_environment()
    
    if use_console:
        # Console interface using fzf
        # Check if fzf is installed
        try:
            subprocess.run(['which', 'fzf'], check=True, stdout=subprocess.PIPE)
        except subprocess.CalledProcessError:
            print("Error: fzf is not installed. Please install it for console selection.")
            sys.exit(1)
        
        # Prepare list for fzf
        output = ''
        for sink in sinks:
            if sink['is_default']:
                output += f"-> {sink['name']}\n"
            else:
                output += f"{sink['name']}\n"
        
        # Call fzf
        fzf_command = f"echo '{output}' | fzf --prompt='Select an audio sink: ' --height=10"
        try:
            fzf_process = subprocess.run(fzf_command, shell=True, encoding='utf-8', 
                                       stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
            selected_sink_name = fzf_process.stdout.strip()
            
            # Remove the "-> " prefix if present
            if selected_sink_name.startswith("-> "):
                selected_sink_name = selected_sink_name[3:]
                
        except subprocess.CalledProcessError:
            print("User cancelled the operation.")
            sys.exit(0)
    
    else:
        # Graphical interface using wofi
        # Prepare list for wofi with HTML markup
        output = ''
        for sink in sinks:
            if sink['is_default']:
                output += f"<b>-> {sink['name']}</b>\n"
            else:
                output += f"{sink['name']}\n"
        
        # Call wofi
        wofi_command = f"echo '{output}' | wofi --show=dmenu --allow-markup --prompt='Select an audio sink' --insensitive"
        try:
            wofi_process = subprocess.run(wofi_command, shell=True, encoding='utf-8',
                                        stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
            selected_sink_name = wofi_process.stdout.strip()
            
            # Remove HTML markup
            selected_sink_name = (selected_sink_name.replace('<b>', '')
                                                   .replace('</b>', '')
                                                   .replace('-> ', ''))
        except subprocess.CalledProcessError:
            print("User cancelled the operation.")
            sys.exit(0)
    
    # Find the selected sink
    selected_sink = None
    selected_sink_name_clean = selected_sink_name.replace(" - Default", "")
    
    for sink in sinks:
        sink_name_clean = sink['name'].replace(" - Default", "")
        if sink_name_clean == selected_sink_name_clean:
            selected_sink = sink
            break
    
    if selected_sink is None:
        print(f"Error: Could not find sink '{selected_sink_name}'")
        print("Available sinks:")
        for sink in sinks:
            print(f"  - {sink['name']} (ID: {sink['id']})")
        sys.exit(1)
    
    # Set the default sink
    set_default_sink(selected_sink['id'])

if __name__ == "__main__":
    main()
