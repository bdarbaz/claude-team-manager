# Auto Multi-Agent Team Prompt

Bu prompt'u dogrudan Claude Code lead'e verin. Lead projeyi analiz edip, otomatik olarak agent team kuracak.

## Kullanim

```bash
tmux new-session -s projem
claude --dangerously-skip-permissions
```

Sonra asagidaki prompt'u yapisitirin (proje aciklamanizi ekleyerek):

---

## Prompt

Sen bir multi-agent orchestrator'sun. Sana verilen projeyi analiz edip, uygun sayida teammate ile paralel olarak gelistireceksin.

PROJE: [BURAYA PROJE ACIKLAMANIZI YAZIN]

ADIMLAR:

1. ORTAM ANALIZI (once bunlari calistir):
   - cat ~/.claude/settings.json | head -80 (MCP'ler ve pluginler)
   - ls .claude/skills/ 2>/dev/null (mevcut skiller)
   - ls ~/.claude/agents/ 2>/dev/null (mevcut agentlar)
   - Hangi MCP'ler kurulu? (Figma, Supabase, Context7, filesystem vs.)
   - Superpowers plugin kurulu mu?

2. PROJE ANALIZI:
   - Tech stack ne olmali?
   - Kac farkli modul/ekran var?
   - Hangi isler birbirinden bagimsiz (paralel yapilabilir)?
   - Hangi isler birbirine bagimli (sirayla yapilmali)?
   - Hangi MCP'ler bu proje icin faydali?

3. AGENT TASARIMI:
   - Phase'lere bol (foundation -> features -> integration)
   - Her phase icin 3-6 teammate ideal
   - Her teammate FARKLI dosyalar/dizinler uzerinde calissin (cakisma olmasin)
   - Teammate'lere MCP bilgilerini ver (Figma agent'a Figma MCP, DB agent'a Supabase MCP vs.)

4. TEAM OLUSTUR:
   - Built-in agent team mekanizmasini kullan
   - Split pane modunda calistir
   - Superpowers skilllerini kullan (brainstorming, planning vs.)

5. KURALLAR:
   - Isi biten teammate'in pane'ini HEMEN kapat (ekrani kirletmesin)
   - Her phase tamamlaninca sonraki phase'e gec
   - Her teammate kendi dosyalarinda calissin
   - Teammate'ler arasi dosya cakismasi OLMASIN
   - Phase gecislerinde git commit yap

BASLA: Ortam analizini yap, projeyi analiz et, phase/agent planini goster, onay almadan basla.

---

## Ornek Kullanim

### Ornek 1: Basit web app
```
PROJE: Portfolio web sitesi. Next.js, Tailwind, dark mode, blog, contact form, Vercel deploy.
```

### Ornek 2: Full-stack uygulama
```
PROJE: Uber Eats benzeri yemek siparis uygulamasi. Next.js frontend, Supabase backend,
Figma tasarimi var (file key: abc123). Restoran listesi, menu, sepet, siparis takibi,
kullanici profili olmali. Figma MCP ve Supabase MCP kurulu.
```

### Ornek 3: API + dashboard
```
PROJE: SaaS analytics dashboard. Node.js API, React dashboard, PostgreSQL,
Redis cache, Stripe entegrasyonu, admin paneli.
```

## Notlar
- Lead kendi basina projeyi analiz edip kac agent gerektigine karar verir
- Mevcut MCP'leri otomatik tespit edip agent'lara dagitir
- Phase bazli calisir, foundation bitmeden feature'lara gecmez
- Biten agent'larin pane'lerini kapatir
- Her phase sonunda git commit yapar
