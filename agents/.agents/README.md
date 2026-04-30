# Global Agent Skills

This directory contains **global agent skills** installed via [`npx skills`](https://github.com/vercel-labs/skills). Global skills are available across all projects and agents on this machine.

## Installed Skills

| Skill | Source |
|---|---|
| `caveman` | [mattpocock/skills](https://github.com/mattpocock/skills) |
| `find-skills` | [vercel-labs/skills](https://github.com/vercel-labs/skills) |
| `grill-me` | [mattpocock/skills](https://github.com/mattpocock/skills) |
| `grill-with-docs` | [mattpocock/skills](https://github.com/mattpocock/skills) |
| `setup-matt-pocock-skills` | [mattpocock/skills](https://github.com/mattpocock/skills) |
| `to-prd` | [mattpocock/skills](https://github.com/mattpocock/skills) |
| `write-a-skill` | [mattpocock/skills](https://github.com/mattpocock/skills) |

## Adding More Skills

To install additional global skills:

```sh
npx skills add -g
```

The `-g` flag installs the skill globally (into this directory), making it available to all your agent-powered tools regardless of the current project.
