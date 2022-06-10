#! /bin/sh
#
# Initialize the local git hooks this repository.
# https://git-scm.com/docs/githooks

topLevel=$(git rev-parse --show-toplevel)
if ! cd "${topLevel}"; then
  echo "filed to cd into topLevel directory '${topLevel}'"
  exit 1
fi

hooksDir="${topLevel}/.githooks"
if ! hooksPath=$(git config core.hooksPath); then
  hooksPath="${topLevel}/.git/hooks"
fi

src="${hooksDir}/generic"
echo "linking hooks..."
for hook in \
  applypatch-msg \
  pre-applypatch \
  post-applypatch \
  pre-commit \
  pre-merge-commit \
  prepare-commit-msg \
  commit-msg \
  post-commit \
  pre-rebase \
  post-checkout \
  post-merge \
  pre-push \
  pre-receive \
  update \
  post-receive \
  post-update \
  push-to-checkout \
  pre-auto-gc \
  post-rewrite \
  sendemail-validate \
  fsmonitor-watchman \
  p4-pre-submit \
  post-index-change
do
  echo "  ${hook}"
  dest="${hooksPath}/${hook}"
  ln -sf "${src}" "${dest}"
done
