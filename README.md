# Claude Team Manager

Claude Code agent team'lerini yoneten ve herhangi bir fikri multi-agent calisabilir prompt'a donusturen sistem.

## Ne Yapar?

1. **Prompt Architect** - Herhangi bir fikri/prompt'u multi-agent ready hale getirir (agent sayisi, roller, phase'ler, MCP routing)
2. **Ortam Hazirlik** - Eksik plugin, MCP, skill tespiti ve kurulumu
3. **Monitor & Control** - Calisan agent team'leri izler, mesaj gonderir, takilanlari yeniden baslatir

## Gereksinimler

- **Claude Code** v2.1.32+
- **tmux** (`sudo apt install tmux` veya `brew install tmux`)
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` settings.json'da

## Kurulum

```bash
git clone https://github.com/bdarbaz/claude-team-manager.git
cd claude-team-manager
chmod +x install.sh
./install.sh
```

Veya manuel:
```bash
cp agents/team-manager.md ~/.claude/agents/team-manager.md
```

## Kullanim

### Yol 1: Team Manager ile (onerilen)

Ikinci bir terminalden team manager'i baslat:

```bash
claude --agent team-manager
```

Sonra dogal dille:
```
"Uber Eats benzeri bir yemek siparis uygulamasi yap. Next.js + Supabase."
```

Team manager otomatik olarak:
- Ortami kontrol eder (plugin, MCP, skill)
- Eksikleri kurar
- Agent sayisini ve rollerini belirler
- Phase'leri tasarlar
- Prompt'u hazirlar ve lead'e gonderir
- Calismayi izler

### Yol 2: Standalone (team manager olmadan)

tmux baslat ve lead'e dogrudan prompt ver:

```bash
tmux new-session -s projem
claude --dangerously-skip-permissions
```

Sonra `prompts/auto-team.md` dosyasindaki prompt template'ini kullan. Proje aciklamanizi ekleyip lead'e yapisitirin. Lead kendi basina:
- Projeyi analiz eder
- MCP'leri tespit eder
- Agent sayisina karar verir
- Team'i kurar ve calistirir

Ornek:
```
Sen bir multi-agent orchestrator'sun. Sana verilen projeyi analiz edip,
uygun sayida teammate ile paralel olarak gelistireceksin.

PROJE: Portfolio web sitesi. Next.js, Tailwind, blog, contact form.

[...prompt/auto-team.md'deki kurallari ekle...]
```

## Agent Team Nasil Kurulur?

### 1. tmux Session Baslat
```bash
tmux new -s myproject
```

### 2. Claude'u Lead Olarak Baslat
```bash
claude --dangerously-skip-permissions
```

> `--team-mode` veya `--teammate-mode` flag'leri YOKTUR. Lead normal baslatilir, built-in agent team mekanizmasi `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` env var ile aktif olur.

### 3. Team Olustur (dogal dille)

```
Bir agent team olustur, split pane modunda calistir.
3 teammate:
- frontend: React component development
- backend: API and server logic
- database: Schema design and migrations

Isi biten teammate'in pane'ini hemen kapat.
Superpowers skilllerini kullan.
```

### 4. Yonetim Icin Ikinci Terminal Ac

```bash
claude --agent team-manager
```

## Kritik Kurallar

| Kural | Aciklama |
|-------|----------|
| Pane kapatma | "Isi biten teammate'in pane'ini hemen kapat" MUTLAKA prompt'a eklenmelidir |
| Superpowers | "Superpowers skilllerini kullan" - brainstorming/planning icin |
| Split pane | Teammate'ler otomatik split pane olarak acar, manuel tmux gerek yok |
| Dosya cakismasi | Her teammate FARKLI dosyalar uzerinde calismalı |
| Phase sırasi | Foundation -> Features -> Integration |

## tmux Kisayollari

| Kisayol | Islev |
|---------|-------|
| `Shift+Down` | Teammate'ler arasi gecis (Claude Code built-in) |
| `Ctrl+B` `z` | Pane zoom/unzoom |
| `Shift+Sol Tik` | Metin sec (mouse mode bypass) |
| `Shift+Ctrl+C` | Kopyala |
| `Shift+Ctrl+V` | Yapistir |

## Dosya Yapisi

```
claude-team-manager/
├── agents/
│   └── team-manager.md       # Agent tanim dosyasi (monitor + prompt architect)
├── prompts/
│   └── auto-team.md          # Standalone prompt template (team manager olmadan)
├── install.sh
├── uninstall.sh
├── LICENSE
└── README.md
```

## Lisans

MIT
