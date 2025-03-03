#!/usr/bin/env python 
import sys
import subprocess

# function to parse output of command "wpctl status" and return a dictionary of sinks with their id and name.
def parse_wpctl_status():
    # Execute the wpctl status command and store the output in a variable.
    output = str(subprocess.check_output("wpctl status", shell=True, encoding='utf-8'))

    # remove the ascii tree characters and return a list of lines
    lines = output.replace("├", "").replace("─", "").replace("│", "").replace("└", "").splitlines()

    # get the index of the Sinks line as a starting point
    sinks_index = None
    for index, line in enumerate(lines):
        if "Sinks:" in line:
            sinks_index = index
            break

    # start by getting the lines after "Sinks:" and before the next blank line and store them in a list
    sinks = []
    for line in lines[sinks_index +1:]:
        if not line.strip():
            break
        sinks.append(line.strip())

    # remove the "[vol:" from the end of the sink name
    for index, sink in enumerate(sinks):
        sinks[index] = sink.split("[vol:")[0].strip()
    
    # strip the * from the default sink and instead append "- Default" to the end. Looks neater in the wofi list this way.
    for index, sink in enumerate(sinks):
        if sink.startswith("*"):
            sinks[index] = sink.strip().replace("*", "").strip() + " - Default"

    # make the dictionary in this format {'sink_id': <int>, 'sink_name': <str>}
    sinks_dict = [{"sink_id": int(sink.split(".")[0]), "sink_name": sink.split(".")[1].strip()} for sink in sinks]

    return sinks_dict

# Detect if running in a console environment or graphical environment
def is_console_environment():
   return sys.stdin and sys.stdin.isatty()

# Choose between fzf (console) and wofi (graphical)
sinks = parse_wpctl_status()
use_console = is_console_environment()

if use_console:
    # Prepare list for fzf - plain text format
    output = ''
    for items in sinks:
        if items['sink_name'].endswith(" - Default"):
            output += f"-> {items['sink_name']}\n"
        else:
            output += f"{items['sink_name']}\n"
    
    # Check if fzf is installed
    if subprocess.run("which fzf", shell=True, stdout=subprocess.PIPE).returncode != 0:
        print("Error: fzf is not installed. Please install it for console selection.")
        exit(1)
    
    # Call fzf and show the list
    fzf_command = f"echo '{output}' | fzf --prompt='Select an audio sink: ' --height=10"
    fzf_process = subprocess.run(fzf_command, shell=True, encoding='utf-8', stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    
    if fzf_process.returncode != 0:
        print("User cancelled the operation.")
        exit(0)
        
    selected_sink_name = fzf_process.stdout.strip()
    # Remove the "-> " prefix if present
    if selected_sink_name.startswith("-> "):
        selected_sink_name = selected_sink_name[3:]
        
else:
    # Prepare list for wofi - with HTML markup
    output = ''
    for items in sinks:
        if items['sink_name'].endswith(" - Default"):
            output += f"<b>-> {items['sink_name']}</b>\n"
        else:
            output += f"{items['sink_name']}\n"
    
    # Call wofi and show the list
    wofi_command = f"echo '{output}' | wofi --show=dmenu --allow-markup --prompt='Select an audio sink' --insensitive"
    wofi_process = subprocess.run(wofi_command, shell=True, encoding='utf-8', stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    
    if wofi_process.returncode != 0:
        print("User cancelled the operation.")
        exit(0)
        
    selected_sink_name = wofi_process.stdout.strip()
sinks = parse_wpctl_status()
selected_sink = next(sink for sink in sinks if sink['sink_name'] == selected_sink_name)
subprocess.run(f"wpctl set-default {selected_sink['sink_id']}", shell=True)
