set -euo pipefail

REPO="YanisTrabelsi/MIVN"
BRANCH="main"
TARGET="${HOME}/.config/nvim"
TMP_DIR="$(mktemp -d)"

cleanup() {
	rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

echo "==> Downloading MIVN (${BRANCH})..."
curl -fsSL "https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" -o "${TMP_DIR}/mivn.tar.gz"

echo "==> Extracting..."
tar -xzf "${TMP_DIR}/mivn.tar.gz" -C "${TMP_DIR}"

if (( -d "${TARGET}" -a ! -d "${TARGET}/install.sh" -a ! -d "${TARGET}/install.ps1")); then
	BACKUP="${TARGET}.bak.$(date +%Y%m%d%H%M%S)"
	echo "==> Existing config found, backing it up to ${BACKUP}"
	mv "${TARGET}" "${BACKUP}"
elif ((-d "${TARGET}")); then
	echo "==> Deleting old version"
	rm -rf "${TARGET}"
	echo "==> Old version deleted"
fi

mkdir -p "$(dirname "${TARGET}")"
mv "${TMP_DIR}/MIVN-${BRANCH}" "${TARGET}"

echo "==> MIVN installed to ${TARGET}"
echo "==> Launch 'nvim' to let lazy.nvim install the plugins."
