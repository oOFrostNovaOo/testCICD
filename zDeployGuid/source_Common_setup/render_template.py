
import os
import argparse
import json
from pathlib import Path
from jinja2 import Environment, FileSystemLoader

def render_templates(vars_file, template_dir, output_dir):
    with open(vars_file) as f:
        variables = json.load(f)

    env = Environment(loader=FileSystemLoader(template_dir), keep_trailing_newline=True)

    for root, dirs, files in os.walk(template_dir):
        for file in files:
            template_path = os.path.relpath(os.path.join(root, file), template_dir)
            template = env.get_template(template_path)

            rendered = template.render(variables)

            output_path = Path(output_dir) / template_path
            output_path.parent.mkdir(parents=True, exist_ok=True)
            with open(output_path, "w") as f:
                f.write(rendered)

    print(f"✅ Render complete! Output saved to: {output_dir}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Render template folder with Jinja2")
    parser.add_argument("--vars", required=True, help="Path to JSON file with variables")
    parser.add_argument("--template_dir", required=True, help="Directory with Jinja2 templates")
    parser.add_argument("--output_dir", required=True, help="Directory to save rendered files")
    args = parser.parse_args()

    render_templates(args.vars, args.template_dir, args.output_dir)
