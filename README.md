# 🍅 i.Pomodoro

App Pomodoro minimale per macOS - Tecnica Pomodoro con timer personalizzabili e notifiche

## 📱 Caratteristiche

- **Timer Pomodoro**: Sessioni di lavoro, pause brevi e pause lunghe personalizzabili
- **Design Apple-style**: Interfaccia nativa macOS con materiali trasparenti
- **Notifiche**: Suoni personalizzabili per le notifiche di fine sessione
- **Impostazioni intuitive**: Controlli moderni per personalizzare durate e audio
- **Minimale**: Design pulito e funzionale senza distrazioni

## 🎯 Tecnica Pomodoro

La Tecnica Pomodoro è un metodo di gestione del tempo che prevede:
- **25 minuti** di lavoro concentrato
- **5 minuti** di pausa breve
- **15-30 minuti** di pausa lunga ogni 4 cicli

### Benefici:
- Migliora concentrazione e focus
- Riduce la procrastinazione
- Aumenta la produttività
- Previene il burnout

## 🚀 Come usare

1. **Scegli la modalità** (Lavoro, Pausa Breve, Pausa Lunga)
2. **Premi Start** per iniziare il timer
3. **Lavora** fino alla notifica sonora
4. **Fai una pausa** quando richiesto
5. **Ripeti il ciclo** per massimizzare la produttività

## ⚙️ Requisiti

- macOS 12.0 o superiore
- Xcode 14.0 o superiore (per la compilazione)

## 🛠 Installazione

### Da sorgente:

```bash
git clone https://github.com/GLBrando/i.Pomodoro.git
cd i.Pomodoro/Pomodoro
xcodebuild -project Pomodoro.xcodeproj -scheme Pomodoro -configuration Release build
cp -R build/Release/Pomodoro.app /Applications/
```

### Utilizzo:

1. Apri l'app dalla cartella Applicazioni
2. Personalizza le impostazioni dal menu ⚙️
3. Inizia la tua sessione Pomodoro!

## 🎨 Design

L'app utilizza:
- **SwiftUI** per l'interfaccia utente
- **Materiali Apple** (.regularMaterial, .ultraThinMaterial)
- **SF Symbols** per le icone
- **Design system nativo** macOS

## 📝 Licenza

Questo progetto è rilasciato sotto licenza MIT.

## 🤝 Contributi

I contributi sono benvenuti! Sentiti libero di aprire issue o pull request.

---

**Sviluppato con ❤️ per la produttività**