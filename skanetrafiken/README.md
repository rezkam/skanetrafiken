# Skånetrafiken Trip Planner Skill

Plan public transport journeys in Skåne, Sweden with real-time information.

An [Agent Skills](https://agentskills.io) compatible skill for AI agents.

## Installation

### Clawdhub

```bash
npx clawdhub@latest install rezkam/boring-but-good/skanetrafiken
# or: pnpm dlx clawdhub@latest install rezkam/boring-but-good/skanetrafiken
# or: bunx clawdhub@latest install rezkam/boring-but-good/skanetrafiken
```

### Claude Code

```bash
git clone https://github.com/rezkam/boring-but-good.git
cp -r boring-but-good/skanetrafiken ~/.claude/skills/skanetrafiken
```

## Requirements

- `curl` - HTTP requests
- `jq` - JSON processing

## Features

- **Single-call trip planning** - Get journey options with one command
- **Real-time delays** - Shows actual departure times with delay indicators
- **Flexible scheduling** - Travel now, depart at, or arrive by specific times
- **Platform info** - Track and platform numbers for each leg
- **Disruption alerts** - Service disruption warnings when available
- **Cross-border support** - Copenhagen trips via Öresundståg

## Usage

See [SKILL.md](SKILL.md) for complete usage guide, query formatting rules, and examples.

## License

MIT
