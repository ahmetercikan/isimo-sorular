# İsim Şehir — günlük sorular

Sunucu her gün Claude ile **Sahneyi Hatırla** için yeni sorular üretir, ayrı bir Claude oturumu her soruyu internetten doğrular,
yalnız onaylananlar buraya eklenir. Uygulama `https://ahmetercikan.github.io/isimo-sorular/v1/<evren>.json` dosyasını çekip
paketteki sorulara ekler (`isimo/src/data/quiz/daily.ts`); uygulama güncellemesi gerekmez.

- `v1/<evren>.json` — yayındaki günlük sorular (`k` = sabit anahtar, 100000+; `added` = eklendiği gün). Elle silinen soru uygulamadan da kalkar.
- `v1/index.json` — durum: evren başına sayı, son çalışma (`last.ok`, `last.error`), son 120 çalışma.
- `known/<evren>.json` — uygulama paketindeki sorular (tekrar denetimi için). isimo'da `node scripts/quiz-known.mjs ../isimo-sorular/known` ile yenilenir.
- `config.json` — günlük sayı, modeller, hedef evrenler (sırayla döner; Replik Kimin? için `"replik"` eklenir).
- `gen/run.mjs` — üretici (Claude Code başsız; archiva-ai `claude_code.py` ile aynı yalıtım), `gen/cron.sh` — sunucuda günlük iş.

## Sunucu kurulumu (bir kez)

```sh
git clone git@github.com:ahmetercikan/isimo-sorular.git ~/isimo-sorular   # deploy anahtarı: ~/.ssh/isimo_sorular (yazma izinli)
printf 'CLAUDE_CODE_OAUTH_TOKEN=%s\n' "<token>" > ~/.isimo-sorular.env && chmod 600 ~/.isimo-sorular.env
( crontab -l; echo '15 1 * * * ~/isimo-sorular/gen/cron.sh daily' ) | crontab -   # her gün 04:15 TSİ
```

Günlük: `~/isimo-sorular.log`. Elle: `gen/cron.sh daily`, `gen/cron.sh fill titanik 30`.
Anahtar (`claude setup-token`) yaklaşık bir yıl geçerlidir; süresi dolunca `index.json` → `last.error` dolar, yenisi env dosyasına yazılır.
