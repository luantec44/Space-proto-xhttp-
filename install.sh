#!/usr/bin/env bash
set -Eeuo pipefail
OWNER="luantec44"
REPO="Space-proto-xhttp-"
BRANCH="main"
VERSION="0.5.8.0"
BASE="https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}"
[[ ${EUID:-$(id -u)} -eq 0 ]] || { echo "ERRO: execute como root." >&2; exit 1; }
case "$(uname -m)" in
  x86_64|amd64) ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) echo "ERRO: arquitetura não suportada: $(uname -m). Use amd64 ou arm64." >&2; exit 1 ;;
esac
command -v curl >/dev/null 2>&1 || { apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl ca-certificates; }
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT
PKG="space-proto-v${VERSION}-${ARCH}.tar.gz"
echo "Baixando SSHPRO SPACE PROTO v${VERSION} (${ARCH})..."
curl -fL --retry 4 --connect-timeout 15 "${BASE}/dist/${PKG}" -o "$TMPDIR/$PKG"
curl -fsSL --retry 3 "${BASE}/SHA256SUMS" -o "$TMPDIR/SHA256SUMS"
EXPECTED="$(awk -v f="dist/${PKG}" '$2==f{print $1}' "$TMPDIR/SHA256SUMS" | head -n1)"
[[ -n "$EXPECTED" ]] || { echo "ERRO: checksum não encontrado para ${PKG}." >&2; exit 1; }
ACTUAL="$(sha256sum "$TMPDIR/$PKG" | awk '{print $1}')"
[[ "$ACTUAL" == "$EXPECTED" ]] || { echo "ERRO: SHA-256 inválido. Instalação cancelada." >&2; exit 1; }
tar -xzf "$TMPDIR/$PKG" -C "$TMPDIR"
cd "$TMPDIR/space-proto-v${VERSION}"
bash ./install.sh
echo
echo "SPACE PROTO v${VERSION} instalado/atualizado com sucesso."
echo "Desenvolvedor: @luantech"
echo "Menu: spaceproto"
echo "Controle: spacectl status"
