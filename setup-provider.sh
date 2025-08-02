#!/bin/bash

# Script untuk menginstal dan mengatur Kaisar CLI pada sistem Linux
# Didukung: Ubuntu 20.04, 22.04, 24.04, dan distribusi kompatibel

# Memastikan penggunaan Node.js versi yang benar
echo "Menggunakan Node.js: $(node -v)"
echo "Lokasi Node.js: $(which node)"

# Memeriksa hak akses root
if [ "$EUID" -ne 0 ]; then
  echo "Harap jalankan script ini dengan sudo: sudo ./setup-provider.sh"
  exit 1
fi

# Memperbaiki URL repositori untuk sistem berbasis Ubuntu
fix_repositories() {
  if grep -q 'id.archive.ubuntu.com' /etc/apt/sources.list; then
    echo "Memperbaiki URL repositori..."
    sed -i 's|id.archive.ubuntu.com|archive.ubuntu.com|g' /etc/apt/sources.list
    sed -i 's|http://archive.ubuntu.com|https://archive.ubuntu.com|g' /etc/apt/sources.list
    sed -i 's|http://security.ubuntu.com|https://security.ubuntu.com|g' /etc/apt/sources.list
  fi
}

# Memeriksa dan menginstal Node.js jika belum ada
install_nodejs() {
  if command -v node >/dev/null 2>&1; then
    echo "Node.js sudah terinstal: $(node -v)"
    if [ "$(node -v | cut -d. -f1)" != "v23" ]; then
      echo "Versi Node.js tidak sesuai (harus v23.x). Memperbarui ke v23.10.0..."
      if [ -f /etc/os-release ]; then
        . /etc/os-release
        case $ID in
          ubuntu|debian)
            fix_repositories
            curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
            apt-get update
            apt-get install -y nodejs
            ;;
          centos|rhel|fedora|rocky|almalinux)
            curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
            yum install -y nodejs
            ;;
          *)
            echo "Distribusi Linux tidak didukung. Instal Node.js v23 secara manual."
            exit 1
            ;;
        esac
      fi
    fi
  else
    echo "Menginstal Node.js v23.10.0..."
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case $ID in
        ubuntu|debian)
          fix_repositories
          curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
          apt-get update
          apt-get install -y nodejs
          ;;
        centos|rhel|fedora|rocky|almalinux)
          curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
          yum install -y nodejs
          ;;
        *)
          echo "Distribusi Linux tidak didukung. Instal Node.js secara manual."
          exit 1
          ;;
      esac
    else
      echo "Distribusi Linux tidak didukung. Instal Node.js secara manual."
      exit 1
    fi
    echo "Node.js terinstal: $(node -v)"
  fi
}

# Memeriksa dan menginstal npm jika belum ada
install_npm() {
  if command -v npm >/dev/null 2>&1; then
    echo "npm sudah terinstal: $(npm -v)"
  else
    echo "Menginstal npm..."
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case $ID in
        ubuntu|debian)
          apt-get install -y npm
          ;;
        centos|rhel|fedora|rocky|almalinux)
          yum install -y npm
          ;;
        *)
          echo "Distribusi Linux tidak didukung. Instal npm secara manual."
          exit 1
          ;;
      esac
    fi
    echo "npm terinstal: $(npm -v)"
  fi
}

# Memeriksa dan menginstal pm2 jika belum ada
install_pm2() {
  if npm list -g pm2 >/dev/null 2>&1; then
    echo "pm2 sudah terinstal: $(pm2 --version)"
  else
    echo "Menginstal pm2 secara global..."
    npm install -g pm2
    echo "pm2 terinstal: $(pm2 --version)"
  fi
}

# Memeriksa dan menginstal curl jika belum ada
install_curl() {
  if command -v curl >/dev/null 2>&1; then
    echo "curl sudah terinstal"
  else
    echo "Menginstal curl..."
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case $ID in
        ubuntu|debian)
          apt-get update
          apt-get install -y curl
          ;;
        centos|rhel|fedora|rocky|almalinux)
          yum install -y curl
          ;;
        *)
          echo "Distribusi Linux tidak didukung. Instal curl secara manual."
          exit 1
          ;;
      esac
    fi
  fi
}

# Memeriksa dan menginstal tar jika belum ada
install_tar() {
  if command -v tar >/dev/null 2>&1; then
    echo "tar sudah terinstal"
  else
    echo "Menginstal tar..."
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case $ID in
        ubuntu|debian)
          apt-get install -y tar
          ;;
        centos|rhel|fedora|rocky|almalinux)
          yum install -y tar
          ;;
      esac
    fi
  fi
}

# Proses instalasi utama
install_curl
install_nodejs
install_npm
install_pm2
install_tar

# Bersihkan cache npm untuk menghindari masalah dependensi
echo "Membersihkan cache npm..."
npm cache clean --force

# Tampilkan versi
echo "Versi Node.js: $(node -v)"
echo "Versi npm: $(npm -v)"
echo "Versi pm2: $(pm2 --version)"

# Ambil informasi versi terbaru dari API Kaisar
echo "Memeriksa versi terbaru Kaisar Provider CLI..."
API_URL="https://app-api.kaisar.io/kavm/check-version/0?app=provider-cli&platform=linux"
VERSION_INFO=$(curl -fsSL "$API_URL")
DOWNLOAD_URL=$(echo "$VERSION_INFO" | grep -oP '"downloadUrl"\s*:\s*"\K[^"]+')
LATEST_VERSION=$(echo "$VERSION_INFO" | grep -oP '"latestVersion"\s*:\s*"\K[^"]+')

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Error: Tidak dapat mengambil URL unduhan dari API."
  exit 1
fi

# Siapkan direktori instalasi
INSTALL_DIR="/opt/kaisar-provider-cli-$LATEST_VERSION"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Buat direktori data dengan izin yang lebih aman
DATA_DIR="/var/lib/kaisar-provider-cli"
mkdir -p "$DATA_DIR"
chown $USER:$USER "$DATA_DIR"
chmod 755 "$DATA_DIR"

# Unduh dan ekstrak paket rilis
echo "Mengunduh paket Kaisar Provider CLI dari $DOWNLOAD_URL..."
curl -fL "$DOWNLOAD_URL" -o kaisar-provider-cli.tar.gz || {
  echo "Error: Tidak dapat mengunduh paket."
  exit 1
}

echo "Mengekstrak paket..."
tar -xzf kaisar-provider-cli.tar.gz
rm kaisar-provider-cli.tar.gz

# Instal dependensi
if [ -f package.json ]; then
  echo "Menginstal dependensi..."
  npm install
  # Pastikan ethers terinstal
  if ! npm list ethers >/dev/null 2>&1; then
    echo "Menginstal ethers secara eksplisit..."
    npm install ethers
  fi
else
  echo "Error: package.json tidak ditemukan di paket yang diekstrak."
  exit 1
fi

# Tautkan CLI secara global
echo "Menautkan CLI secara global..."
npm link || {
  echo "Error: Tidak dapat menautkan CLI secara global. Periksa izin npm Anda."
  exit 1
}

# Tambahkan variabel lingkungan ke file profil
echo "Mengatur variabel lingkungan..."
ENV_SETUP="export KAISAR_DATA_DIR=\"$DATA_DIR\""

# Tambahkan ke file profil
for profile_file in /etc/profile /etc/bash.bashrc /etc/bashrc ~/.bashrc ~/.bash_profile ~/.profile; do
  if [ -f "$profile_file" ]; then
    if ! grep -q "KAISAR_DATA_DIR" "$profile_file"; then
      echo "$ENV_SETUP" >> "$profile_file"
      echo "Ditambahkan ke $profile_file"
    fi
  fi
done

# Verifikasi instalasi
echo "Memverifikasi instalasi..."
export KAISAR_DATA_DIR="$DATA_DIR"
kaisar --version || {
  echo "Error: Verifikasi instalasi gagal. Perintah 'kaisar' mungkin belum tersedia sampai Anda me-restart terminal."
  echo "Namun, instalasi mungkin telah selesai. Coba restart terminal dan jalankan: kaisar --version"
  exit 1
}

echo "--------------------------------------------------"
echo "Instalasi berhasil! Anda sekarang dapat menggunakan CLI dengan perintah 'kaisar'."
echo "Contoh perintah:"
echo "  kaisar start   # Memulai Aplikasi Provider"
echo "  kaisar status  # Memeriksa status Aplikasi Provider"
echo "  kaisar logs    # Melihat log aplikasi"
echo ""
echo "Catatan: Anda mungkin perlu me-restart terminal atau menjalankan:"
echo "      source ~/.bashrc"
echo "untuk membuat perintah 'kaisar' tersedia segera"
echo "--------------------------------------------------"
