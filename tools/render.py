#!/usr/bin/env python3

import shutil
import os
import argparse
import yaml
from jinja2 import Environment, FileSystemLoader

def load_variables(file_path):
    with open(file_path, 'r') as file:
        return yaml.safe_load(file)

def render_templates(vars_file, template_dir, output_dir):
    # Load config variables
    variables = load_variables(vars_file)

    # Set up Jinja2 environment
    env = Environment(loader=FileSystemLoader(template_dir))

    # Walk through the template_dir and process all files
    for root, _, files in os.walk(template_dir):
        for file_name in files:
            src_path = os.path.join(root, file_name)
            rel_dir = os.path.relpath(root, template_dir)
            dest_dir = os.path.join(output_dir, rel_dir)
            os.makedirs(dest_dir, exist_ok=True)

            if file_name.endswith(".j2"):
                # --- Render template ---
                template_path = os.path.join(rel_dir, file_name)
                output_file_name = file_name[:-3]  # bỏ phần ".j2"
                output_path = os.path.join(dest_dir, output_file_name)

                template = env.get_template(template_path)
                rendered = template.render(variables)

                with open(output_path, 'w') as f:
                    f.write(rendered)
                print(f"✅ Rendered: {template_path} → {output_file_name}")

            else:
                # --- Copy file static ---
                dest_path = os.path.join(dest_dir, file_name)
                shutil.copy2(src_path, dest_path)
                print(f"📄 Copied: {os.path.join(rel_dir, file_name)}")
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Render Jinja2 templates with YAML variables")
    parser.add_argument("--vars", required=True, help="Path to YAML variables file")
    parser.add_argument("--template_dir", required=True, help="Directory containing Jinja2 templates")
    parser.add_argument("--output_dir", required=True, help="Directory to output rendered files")

    args = parser.parse_args()

    render_templates(args.vars, args.template_dir, args.output_dir)
