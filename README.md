# Claude Team Manager

Claude Code agent team'lerini tmux üzerinden yöneten custom agent. Ayrı bir terminalden agent team'lerinizi izleyin, mesaj gönderin, yeniden başlatın ve temizleyin.

## Nedir?

Claude Code'un [Agent Teams](https://code.claude.com/docs/en/agent-teams) özelliği birden fazla Claude oturumunu tmux split pane'lerinde çalıştırır. Bu agent, **ikinci bir terminalden** tüm team'i yönetmenizi sağlar.

```
┌─────────────────────────────────────────────────┐
│ Terminal 1: tmux (agent team çalışıyor)         │
│ ┌──────────────┬──────────────┬───────────────┐ │
│ │ Lead         │ Frontend     │ Backend       │ │
│ │ (claude)     │ (claude)     │ (claude)      │ │
│ │              │              │               │ │
│ └──────────────┴──────────────┴───────────────┘ │
├─────────────────────────────────────────────────┤
│ Terminal 2: claude --agent team-manager          │
│ > "durum göster"                                │
│ > "frontend agent'a 'login sayfasını bitir' de" │
│ > "backend takılmış, yeniden başlat"            │
│ > "tüm takımı kapat"                            │
└─────────────────────────────────────────────────┘
```

## Gereksinimler

- **Claude Code** v2.1.32+ (`npm install -g @anthropic-ai/claude-code`)
- **tmux** (split-pane modu için) (`sudo apt install tmux` veya `brew install tmux`)

## Kurulum

```bash
git clone https://github.com/KULLANICI_ADI/claude-team-manager.git
cd claude-team-manager
chmod +x install.sh
./install.sh
```

Installer otomatik olarak:
1. Claude Code ve tmux'un kurulu olduğunu kontrol eder
2. `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` feature flag'ini aktifleştirir
3. Agent dosyasını `~/.claude/agents/` dizinine kopyalar
4. tmux mouse desteğini açar

### Manuel Kurulum

Agent dosyasını direkt kopyalayın:

```bash
cp agents/team-manager.md ~/.claude/agents/team-manager.md
```

## Kullanım

### Interaktif Mod (Önerilen)

```bash
claude --agent team-manager
```

Sonra doğal dille yönetin:

| Komut | Ne yapar |
|-------|----------|
| `durum göster` | Tüm tmux session ve pane'leri listeler |
| `frontend agent'a mesaj gönder: login sayfasını bitir` | Belirli teammate'e talimat gönderir |
| `pane 2'yi yeniden başlat` | Takılmış agent'ı graceful restart yapar |
| `tüm takımı kapat` | Tüm teammate'leri kapatıp temizler |
| `layout'u tiled yap` | Pane düzenini değiştirir |
| `pane 3'e zoom yap` | Tek pane'i tam ekran yapar |

### Tek Seferlik Komut

```bash
# Durum kontrolü
claude -p --agent team-manager "tmux durumunu göster"

# Teammate'e mesaj
claude -p --agent team-manager "myproject session'ında pane 2'ye 'API endpoint'leri bitir' mesajı gönder"

# Takım temizliği
claude -p --agent team-manager "tüm takımları kapat ve temizle"
```

## Agent Team Nasıl Kurulur?

### 1. tmux Session Başlat

```bash
tmux new -s myproject
```

### 2. Claude'u Team Lead Olarak Başlat

```bash
claude --team-mode tmux --dangerously-skip-permissions
```

> **Dikkat:** `--team-mode tmux` flag'i **zorunludur** - bu olmadan Claude agent spawn edemez ve teammate yönetemez. `--dangerously-skip-permissions` opsiyoneldir ama multi-agent çalışmada her işlem için onay vermemek için önerilir.

### 3. Team Oluştur (doğal dille)

```
Create an agent team with 3 teammates:
- frontend: React component development
- backend: API and server logic
- database: Schema design and migrations
```

### 4. Yönetim İçin İkinci Terminal Aç

```bash
# Yeni terminal penceresi aç (tmux dışında)
claude --agent team-manager
```

## Kritik Flag'ler

| Flag | Kim kullanır | Zorunlu mu | Açıklama |
|------|-------------|------------|----------|
| `--team-mode tmux` | **Team Lead** | **Evet** | Lead'in teammate spawn edebilmesi ve yönetebilmesi için zorunlu |
| `--teammate-mode tmux` | **Teammate'ler** | **Evet** | Teammate olarak başlatılan agent'lar için zorunlu (lead otomatik ekler) |
| `--dangerously-skip-permissions` | Lead veya Teammate | Hayır | Her işlem için onay sormasını engeller, multi-agent'ta önerilir |

> **Lead = `--team-mode tmux`**, **Teammate = `--teammate-mode tmux`**. Karıştırmayın!

## tmux Kısayolları

Agent manager olmadan da tmux'ta gezinmek için:

| Kısayol | İşlev |
|---------|-------|
| `Ctrl+B` sonra `o` | Sonraki pane'e geç |
| `Ctrl+B` sonra `↑↓←→` | Ok tuşlarıyla pane seç |
| `Ctrl+B` sonra `q` + numara | Numaralı pane'e atla |
| `Ctrl+B` sonra `z` | Pane'i zoom/unzoom |
| Mouse tıklama | Doğrudan pane'e geç (mouse on ise) |

## tmux Mouse & Clipboard

tmux mouse mode açıkken sağ tık tmux menüsü açar. Kopyala/yapıştır için:

| İşlem | Kısayol |
|-------|---------|
| Metin seç | **Shift + Sol Tık sürükle** |
| Kopyala | **Shift + Ctrl+C** |
| Yapıştır | **Shift + Ctrl+V** veya **Shift + Sağ Tık** |
| tmux buffer'dan yapıştır | `Ctrl+B` sonra `]` |

> **Shift tuşu** tmux mouse mode'u bypass eder ve terminal'in kendi seçim/kopyalama özelliğini kullanmanızı sağlar.

## Dosya Yapısı

```
claude-team-manager/
├── agents/
│   └── team-manager.md    # Agent tanım dosyası
├── install.sh             # Otomatik kurulum scripti
├── uninstall.sh           # Kaldırma scripti
├── LICENSE
└── README.md
```

## Agent Nasıl Çalışır?

Agent, tmux komutlarını kullanarak:

- `tmux ls` / `tmux list-panes` ile session ve pane'leri keşfeder
- `tmux capture-pane` ile her pane'in çıktısını okur
- `tmux send-keys` ile teammate'lere mesaj/komut gönderir
- `~/.claude/teams/` ve `~/.claude/tasks/` dosyalarını okuyarak team metadata'sına erişir
- Graceful shutdown (Ctrl+C → /exit) → force kill sıralamasıyla güvenli kapatma yapar

## Güvenlik Kuralları

- Lead (Pane 0) asla onaysız kapatılmaz
- Tüm kapatmalar önce graceful (Ctrl+C → /exit) denenir
- Yıkıcı işlemlerden önce ve sonra durum gösterilir
- Team config restart sırasında korunur

## Kaldırma

```bash
chmod +x uninstall.sh
./uninstall.sh
```

Veya manuel:

```bash
rm ~/.claude/agents/team-manager.md
```

## Lisans

MIT
