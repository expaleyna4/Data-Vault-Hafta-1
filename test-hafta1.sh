#!/bin/bash
# DATA VAULT - HAFTA 1 - Otomatik Test Scripti
# Kimlik, Lisans ve Erişim Mimarisi Testleri

echo "======================================"
echo "  DATA VAULT - HAFTA 1 TEST"
echo "======================================"
echo ""
echo "⏱️  Test başlıyor..."
echo ""
sleep 1

# Test sayaçları
PASSED=0
FAILED=0

# Test fonksiyonu
test_check() {
    if [ $? -eq 0 ]; then
        echo "  ✅ BAŞARILI"
        ((PASSED++))
    else
        echo "  ❌ BAŞARISIZ"
        ((FAILED++))
    fi
    echo ""
    read -p "Sonraki teste geçmek için Enter'a basın..." dummy
    echo ""
}

# Test 1: Gruplar
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 1/10] Grup Varlığı Kontrolü"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: finans, ik, denetci gruplarının sistemde olup olmadığını kontrol et"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  getent group finans"
echo ""
echo "➤ Yanıt:"
getent group finans
echo ""
echo "  getent group ik"
echo ""
echo "➤ Yanıt:"
getent group ik
echo ""
echo "  getent group denetci"
echo ""
echo "➤ Yanıt:"
getent group denetci
echo ""
echo "# Açıklama: Her grup bulundu mu? (finans, ik, denetci)"
getent group finans >/dev/null && getent group ik >/dev/null && getent group denetci >/dev/null
test_check

# Test 2: Kullanıcılar
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 2/10] Kullanıcı Varlığı Kontrolü"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: finansuser, ikuser, denetci kullanıcılarının sistemde olduğunu doğrula"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  id finansuser"
echo ""
echo "➤ Yanıt:"
id finansuser 2>&1
echo ""
echo "  id ikuser"
echo ""
echo "➤ Yanıt:"
id ikuser 2>&1
echo ""
echo "  id denetci"
echo ""
echo "➤ Yanıt:"
id denetci 2>&1
echo ""
echo "# Açıklama: Kullanıcılar var mı ve hangi gruplara dahiller?"
id finansuser >/dev/null 2>&1 && id ikuser >/dev/null 2>&1 && id denetci >/dev/null 2>&1
test_check

# Test 3: Dizin varlığı
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 3/10] Dizin Varlığı Kontrolü"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: /data/finans ve /data/ik dizinlerinin var olup olmadığını kontrol et"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  ls -ld /data/finans /data/ik"
echo ""
echo "➤ Yanıt:"
ls -ld /data/finans /data/ik 2>&1
echo ""
echo "# Açıklama: Her iki dizin de mevcut mu?"
[ -d /data/finans ] && [ -d /data/ik ]
test_check

# Test 4: SGID izinleri
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 4/10] SGID İzin Kontrolü"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: SGID (Set Group ID) izninin aktif olup olmadığını kontrol et"
echo "# SGID: 2770 = dizinde oluşturulan dosyalar otomatik olarak dizin grubuna ait olur"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  stat -c '%a %n' /data/finans"
echo ""
echo "➤ Yanıt:"
stat -c '%a %n' /data/finans 2>&1
PERM_FINANS=$(stat -c %a /data/finans 2>/dev/null)
echo "  Beklenen: 2770 (SGID bit set)"
echo ""
echo "  stat -c '%a %n' /data/ik"
echo ""
echo "➤ Yanıt:"
stat -c '%a %n' /data/ik 2>&1
PERM_IK=$(stat -c %a /data/ik 2>/dev/null)
echo "  Beklenen: 2770 (SGID bit set)"
echo ""
echo "# Açıklama: 2770 = rwxrws--- (2=SGID, 7=rwx owner, 7=rwx group, 0=--- other)"
[ "$PERM_FINANS" = "2770" ] && [ "$PERM_IK" = "2770" ]
test_check

# Test 5: Grup sahipliği
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 5/10] Grup Sahipliği Kontrolü"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: Her dizinin doğru gruba ait olduğunu doğrula"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  stat -c '%U:%G %n' /data/finans"
echo ""
echo "➤ Yanıt:"
stat -c '%U:%G %n' /data/finans 2>&1
GRP_FINANS=$(stat -c %G /data/finans 2>/dev/null)
echo "  Beklenen Grup: finans"
echo ""
echo "  stat -c '%U:%G %n' /data/ik"
echo ""
echo "➤ Yanıt:"
stat -c '%U:%G %n' /data/ik 2>&1
GRP_IK=$(stat -c %G /data/ik 2>/dev/null)
echo "  Beklenen Grup: ik"
echo ""
echo "# Açıklama: Dizin sahipliği root:finans ve root:ik şeklinde olmalı"
[ "$GRP_FINANS" = "finans" ] && [ "$GRP_IK" = "ik" ]
test_check

# Test 6: ACL kontrolü
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 6/10] ACL İzin Kontrolü"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: ACL (Access Control List) ile denetci kullanıcısına sadece okuma izni verilmiş mi?"
echo "# ACL: Standart izinlerin ötesinde kullanıcı bazlı ince ayar yapma sistemi"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  getfacl /data/finans"
echo ""
echo "➤ Yanıt:"
getfacl /data/finans 2>/dev/null
echo ""
echo "# Açıklama: 'user:denetci:r-x' satırı var mı?"
echo "# r-x = read + execute (okuma ve dizin listeleme), write yok"
getfacl /data/finans 2>/dev/null | grep "user:denetci:r-x" >/dev/null
test_check

# Test 7: Dosya oluşturma (finansuser)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 7/10] Dosya Oluşturma Testi"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: finansuser kendi departman dizininde dosya oluşturabilmeli"
echo ""
TESTFILE="test-$(date +%s).txt"
echo "➤ Çalıştırılan Komut:"
echo "  sudo -u finansuser touch /data/finans/$TESTFILE"
echo ""
echo "➤ Yanıt:"
sudo -u finansuser touch /data/finans/$TESTFILE 2>&1
if [ $? -eq 0 ]; then
    echo "  Dosya oluşturuldu: /data/finans/$TESTFILE"
else
    echo "  Hata: Dosya oluşturulamadı"
fi
echo ""
echo "# Açıklama: finansuser, finans grubunun üyesi olduğu için yazabilmeli"
[ -f /data/finans/$TESTFILE ]
test_check

# Test 8: SGID miras (grup otomatik ataması)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 8/10] SGID Miras Testi"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: SGID biti sayesinde oluşturulan dosyanın grubu otomatik 'finans' olmalı"
echo "# Normal durumda: Dosya kullanıcının primary grubuna ait olur"
echo "# SGID ile: Dosya, dizinin grubuna (finans) ait olur"
echo ""
TEST_FILE=$(ls -t /data/finans/test-*.txt 2>/dev/null | head -n1)
if [ -n "$TEST_FILE" ]; then
    echo "➤ Çalıştırılan Komut:"
    echo "  ls -l $TEST_FILE"
    echo ""
    echo "➤ Yanıt:"
    ls -l "$TEST_FILE" 2>&1
    echo ""
    FILE_GRP=$(stat -c %G "$TEST_FILE" 2>/dev/null)
    echo "  Dosya Grubu: $FILE_GRP"
    echo "  Beklenen: finans"
    echo ""
    echo "# Açıklama: SGID miras çalıştı mı? Grup 'finans' olmalı (finansuser değil)"
    [ "$FILE_GRP" = "finans" ]
    test_check
else
    echo "  ❌ Test dosyası bulunamadı"
    ((FAILED++))
    echo ""
    read -p "Sonraki teste geçmek için Enter'a basın..." dummy
    echo ""
fi

# Test 9: İzolasyon kontrolü
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 9/10] Departman İzolasyonu Testi"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: finansuser, başka departmanın (ik) dizinine erişememeli"
echo "# İzolasyon: Her departman sadece kendi dizininde çalışabilir"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  sudo -u finansuser ls /data/ik"
echo ""
echo "➤ Yanıt:"
sudo -u finansuser ls /data/ik 2>&1
EXIT_CODE=$?
echo ""
echo "# Açıklama: 'Permission denied' hatası alınmalı (izolasyon çalışıyor)"
if [ $EXIT_CODE -ne 0 ]; then
    echo "  ✅ BAŞARILI (Erişim reddedildi - beklenen)"
    ((PASSED++))
else
    echo "  ❌ BAŞARISIZ (Erişim sağlandı - beklenmeyen)"
    ((FAILED++))
fi
echo ""
read -p "Sonraki teste geçmek için Enter'a basın..." dummy
echo ""

# Test 10: Git repository
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 10/10] Git Repository Kontrolü"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: ~/data-vault dizininin Git repository olduğunu doğrula"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  cd ~/data-vault && git log --oneline"
echo ""
echo "➤ Yanıt:"
cd ~/data-vault 2>/dev/null && git log --oneline 2>&1 | head -n 5
echo ""
echo "# Açıklama: Git commit geçmişi var mı?"
cd ~/data-vault 2>/dev/null && git status >/dev/null 2>&1
test_check

# Özet rapor
echo "======================================"
echo "         TEST SONUÇLARI"
echo "======================================"
echo ""
echo "  ✅ Başarılı: $PASSED"
echo "  ❌ Başarısız: $FAILED"
echo "  📊 Toplam: $((PASSED + FAILED))"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "🎉 TÜM TESTLER BAŞARILI!"
    echo ""
    echo "📊 Sistem Durumu:"
    echo "  Gruplar:     $(getent group finans ik denetci | wc -l) adet"
    echo "  Kullanıcılar: 3 adet (finansuser, ikuser, denetci)"
    echo "  Dizinler:    /data/finans, /data/ik (SGID+ACL)"
    echo "  Git Repo:    ~/data-vault"
    echo ""
    echo "📁 Dizin İzinleri:"
    ls -ld /data/finans /data/ik
    echo ""
    echo "🔐 ACL Özeti:"
    getfacl /data/finans 2>/dev/null | grep -E "user:denetci|group:finans"
else
    echo "⚠️  BAZI TESTLER BAŞARISIZ!"
    echo ""
    echo "Sorun giderme için:"
    echo "  bash ~/kurulum-hafta1.sh"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "Çıkmak için Enter'a basın..." dummy
