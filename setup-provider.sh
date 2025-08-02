#!/bin/bash

# Script untuk menginstal dan mengatur Kaisar Provider CLI versi 2507312203 pada sistem Linux
# Didukung: Ubuntu 20.04, 22.04, 24.04, dan distribusi kompatibel
# Meminta input alamat email secara interaktif untuk membuat wallet

# Pastikan menggunakan Node.js v23.10.0
NODE_PATH=$(find / -name node 2>/dev/null | grep -E "v23\.[0-9]+\.[0-9]+" | head -n 1)
if [ -n "$NODE_PATH" ]; then
  export PATH=$(dirname "$NODE_PATH"):$PATH
fi
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

# Memeriksa dan menginstal Node.js v23.10.0
install_nodejs() {
  if command -v node >/dev/null 2>&1 && [[ "$(node -v)" == v23.* ]]; then
    echo "Node.js v23 sudah terinstal: $(node -v)"
  else
    echo "Menghapus versi Node.js lama dan dependensinya..."
    apt-get remove --purge -y nodejs libnode-dev npm
    apt-get autoremove -y
    apt-get autoclean
    echo "Menginstal Node.js v20.x sebagai cadangan..."
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
    npm install -g pm2@6.0.8
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

# Perbarui PM2 ke versi terbaru
echo "Memperbarui PM2 ke versi 6.0.8..."
npm install -g pm2@6.0.8
pm2 update

# Bersihkan cache npm untuk menghindari masalah dependensi
echo "Membersihkan cache npm..."
npm cache clean --force

# Tampilkan versi
echo "Versi Node.js: $(node -v)"
echo "Versi npm: $(npm -v)"
echo "Versi pm2: $(pm2 --version)"

# Bersihkan proses Kaisar saja
echo "Menghentikan proses Kaisar yang berjalan..."
kaisar stop >/dev/null 2>&1
pm2 stop kaisar-provider >/dev/null 2>&1
pm2 delete kaisar-provider >/dev/null 2>&1

# Bersihkan direktori data
DATA_DIR="/var/lib/kaisar-provider-cli"
echo "Membersihkan direktori data: $DATA_DIR..."
sudo rm -rf "$DATA_DIR"/*
sudo mkdir -p "$DATA_DIR"
sudo chown $USER:$USER "$DATA_DIR"
sudo chmod 755 "$DATA_DIR"

# Siapkan direktori instalasi
INSTALL_DIR="/opt/kaisar-provider-cli-2507312203"
DOWNLOAD_URL="https://github.com/Kaisar-Network/kaisar-releases/raw/main/kaisar-provider-cli-2507312203.tar.gz"
sudo rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

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
  npm install commander@9.5.0 ethers@5.7.2
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

# Mulai aplikasi
echo "Memulai aplikasi Kaisar..."
kaisar start || {
  echo "Error: Gagal memulai aplikasi. Periksa log dengan: kaisar logs"
  exit 1
}

# Tunggu beberapa detik untuk memastikan aplikasi berjalan
sleep 5

# Periksa status
echo "Memeriksa status aplikasi..."
kaisar status || {
  echo "Error: Aplikasi tidak berjalan. Periksa log dengan: kaisar logs"
  exit 1
}

# Meminta input alamat email untuk wallet
echo "Masukkan alamat email untuk membuat wallet baru:"
read -p "Email: " EMAIL
if [ -z "$EMAIL" ]; then
  echo "Error: Alamat email tidak boleh kosong."
  exit 1
fi

# Buat wallet
echo "Membuat wallet baru dengan email $EMAIL..."
kaisar create-wallet -e "$EMAIL" || {
  echo "Error: Gagal membuat wallet. Periksa log dengan: kaisar logs"
  exit 1
}

# Periksa file wallet
echo "Memeriksa file wallet..."
ls -l "$DATA_DIR" | grep wallet || {
  echo "Error: File wallet tidak ditemukan di $DATA_DIR. Periksa log dengan: kaisar logs"
  exit 1
}

# Simpan konfigurasi PM2
echo "Menyimpan konfigurasi PM2..."
pm2 save

echo "--------------------------------------------------"
echo "Instalasi dan konfigurasi berhasil!"
echo "Aplikasi telah dimulai dan wallet telah dibuat."
echo "Periksa status: kaisar status"
echo "Lihat log: kaisar logs"
echo "Cek status provider di https://onenode.kaisar.io/provider menggunakan alamat wallet."
echo "Catatan: Anda mungkin perlu me-restart terminal atau menjalankan:"
echo "      source ~/.bashrc"
echo "--------------------------------------------------"
