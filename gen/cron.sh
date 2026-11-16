#!/bin/sh
# Sunucuda her gün cron çalıştırır:  gen/cron.sh daily      (ilk büyütme: gen/cron.sh fill <evren> <sayı>)
# Gerekenler (bir kez kurulur, bkz. README): ~/.isimo-sorular.env (CLAUDE_CODE_OAUTH_TOKEN=…, chmod 600),
# ~/.ssh/isimo_sorular (bu depoya yazma izinli deploy anahtarı), docker.
set -u
cd "$(dirname "$0")/.."
export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/isimo_sorular -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
LOG="$HOME/isimo-sorular.log"
{
  echo "=== $(date -u +%FT%TZ) $*"
  git pull -q --rebase --autostash origin main || echo "git pull olmadı"
  # Kod değiştiyse görüntüyü yeniden kur (değişmediyse önbellekten saniyeler sürer).
  docker build -q -t isimo-sorular gen >/dev/null || { echo "docker build olmadı"; exit 1; }
  docker run --rm --env-file "$HOME/.isimo-sorular.env" -v "$PWD:/w" --user "$(id -u):$(id -g)" \
    --memory 1g --cpus 1 isimo-sorular node gen/run.mjs "$@"
  echo "çıkış $?"
  git add v1
  if ! git diff --cached --quiet; then
    git -c user.name=isimo-sorular -c user.email=isimo-sorular@users.noreply.github.com commit -qm "Sorular $(date -u +%F) $*"
    for try in 1 2 3; do
      git push -q origin HEAD:main && break
      git pull -q --rebase origin main; sleep 10
    done
  fi
} >>"$LOG" 2>&1
# Günlüğü küçük tut.
tail -n 4000 "$LOG" >"$LOG.tmp" && mv "$LOG.tmp" "$LOG"
