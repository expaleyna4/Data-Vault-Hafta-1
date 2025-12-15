#!/bin/bash
# DATA VAULT - HAFTA 1 - Otomatik Kurulum Scripti
# Kimlik, Lisans ve Erişim Mimarisi

set -e  # Hata durumunda dur

echo "======================================"
echo "  DATA VAULT - HAFTA 1 KURULUM"
echo "======================================"
echo ""

# Kullanıcı bilgisi
echo "[1/8] Kullanıcı bilgisi alınıyor..."
CURRENT_USER=$(whoami)
echo "  → Kullanıcı: $CURRENT_USER"
sleep 1

# Git kurulumu
echo ""
echo "[2/8] Git kurulumu kontrol ediliyor..."
if ! command -v git &> /dev/null; then
    echo "  → Git kuruluyor..."
    sudo apt update -qq
    sudo apt install -y git
    echo "  ✓ Git kuruldu"
else
    echo "  ✓ Git zaten kurulu: $(git --version)"
fi
sleep 1

# ACL kurulumu
echo ""
echo "[3/8] ACL araçları kontrol ediliyor..."
if ! command -v setfacl &> /dev/null; then
    echo "  → ACL araçları kuruluyor..."
    sudo apt install -y acl
    echo "  ✓ ACL kuruldu"
else
    echo "  ✓ ACL zaten kurulu"
fi
sleep 1

# Git konfigürasyonu
echo ""
echo "[4/8] Git konfigürasyonu..."
git config --global user.name "Data Vault Admin" 2>/dev/null || true
git config --global user.email "admin@datavault.local" 2>/dev/null || true
echo "  ✓ Git ayarlandı"
sleep 1

# Gruplar oluştur
echo ""
echo "[5/8] Gruplar oluşturuluyor..."
sudo groupadd -f finans 2>/dev/null || echo "  ! finans grubu zaten var"
sudo groupadd -f ik 2>/dev/null || echo "  ! ik grubu zaten var"
sudo groupadd -f denetci 2>/dev/null || echo "  ! denetci grubu zaten var"
echo "  ✓ Gruplar hazır: finans, ik, denetci"
sleep 1

# Kullanıcılar oluştur
echo ""
echo "[6/8] Kullanıcılar oluşturuluyor..."
sudo useradd -M -s /bin/bash -G finans finansuser 2>/dev/null || echo "  ! finansuser zaten var"
sudo useradd -M -s /bin/bash -G ik ikuser 2>/dev/null || echo "  ! ikuser zaten var"
sudo useradd -M -s /bin/bash -g denetci denetci 2>/dev/null || echo "  ! denetci zaten var"
echo "  ✓ Kullanıcılar hazır"
sleep 1

# Dizinler ve izinler
echo ""
echo "[7/8] Dizinler ve izinler ayarlanıyor..."
sudo mkdir -p /data/{finans,ik}

# SGID ve temel izinler
sudo chmod 2770 /data/finans
sudo chmod 2770 /data/ik
sudo chown root:finans /data/finans
sudo chown root:ik /data/ik

# ACL izinleri
sudo setfacl -m u:denetci:r-x /data/finans
sudo setfacl -m u:denetci:r-x /data/ik
sudo setfacl -d -m u:denetci:r-x /data/finans
sudo setfacl -d -m u:denetci:r-x /data/ik

echo "  ✓ /data/finans (SGID 2770, ACL: denetci r-x)"
echo "  ✓ /data/ik (SGID 2770, ACL: denetci r-x)"
sleep 1

# Git repo oluştur
echo ""
echo "[8/8] Git repository oluşturuluyor..."
mkdir -p ~/data-vault/{scripts,config,docs}
cd ~/data-vault

# .gitignore
cat > .gitignore << 'EOF'
*.log
*.tmp
*~
.DS_Store
backup-*
EOF

# README.md
cat > README.md << 'EOF'
# DATA VAULT - Hafta 1

Departmanlar için dosya sunucusu sistemi.

## Özellikler
- Git versiyonlama
- SGID izin yönetimi
- ACL erişim kontrolü
- Grup bazlı izolasyon

## Kullanım
Detaylar için `docs/` klasörüne bakın.
EOF

# LICENSE (GNU GPLv3 kısaltılmış)
cat > LICENSE << 'EOF'
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (C) 2025 Data Vault Project
This is free software, and you are welcome to redistribute it.
EOF

# Git init ve commit
git init
git add .
git commit -m "feat: temel dizin yapısı ve ilk dokümanlar eklendi"

echo ""
echo "  ✓ Git repository hazır: ~/data-vault"
echo ""

# Özet
echo "======================================"
echo "  KURULUM TAMAMLANDI!"
echo "======================================"
echo ""
echo "📊 ÖZET:"
echo "  Gruplar:     finans, ik, denetci"
echo "  Kullanıcılar: finansuser, ikuser, denetci"
echo "  Dizinler:    /data/finans, /data/ik (SGID+ACL)"
echo "  Git Repo:    ~/data-vault"
echo ""
echo "🧪 TEST KOMUTLARı:"
echo "  ls -ld /data/finans /data/ik"
echo "  getfacl /data/finans"
echo "  cd ~/data-vault && git log --oneline"
echo ""
echo "✅ Sistem hazır!"
