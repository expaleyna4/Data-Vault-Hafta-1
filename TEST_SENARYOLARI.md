# 🧪 TEST SENARYOLARI

## Hızlı Testler

### Git
```bash
cd ~/data-vault && git status  # Repo başlatılmış mı?
git log --oneline  # Commit var mı?
```

### Gruplar ve Kullanıcılar
```bash
getent group finans  # finans:x:1001:finansuser
getent group ik      # ik:x:1002:ikuser
id finansuser        # finans grubu görünmeli
```

### SGID ve İzinler
```bash
ls -ld /data/finans  # drwxrws--- ... root finans
stat -c "%a %n" /data/finans  # 2770
```

### ACL
```bash
getfacl /data/finans  # user:denetci:r-x ve default:user:denetci:r-x
```

### Erişim Kontrol
```bash
sudo -u finansuser ls /data/ik  # Permission denied ✓
sudo -u ikuser ls /data/finans  # Permission denied ✓
sudo -u denetci ls /data/finans  # Başarılı ✓
sudo -u denetci touch /data/finans/test.txt  # Permission denied ✓
sudo -u finansuser touch /data/finans/test.txt  # Başarılı ✓
ls -l /data/finans/test.txt  # Grup "finans" olmalı (SGID) ✓
```


## Otomatik Test Scripti

```bash
#!/bin/bash
echo "🧪 Test Başlıyor..."
cd ~/data-vault && git status >/dev/null 2>&1 && echo "✅ Git" || echo "❌ Git"
getent group finans >/dev/null && echo "✅ Gruplar" || echo "❌ Gruplar"
id finansuser >/dev/null 2>&1 && echo "✅ Kullanıcılar" || echo "❌ Kullanıcılar"
ls -ld /data/finans | grep "rws" >/dev/null && echo "✅ SGID" || echo "❌ SGID"
getfacl /data/finans 2>/dev/null | grep "user:denetci:r-x" >/dev/null && echo "✅ ACL" || echo "❌ ACL"
sudo -u finansuser ls /data/ik >/dev/null 2>&1 && echo "❌ Erişim (olmamalı!)" || echo "✅ Erişim Engeli"
sudo -u denetci ls /data/finans >/dev/null 2>&1 && echo "✅ Denetçi Okuma" || echo "❌ Denetçi Okuma"
sudo -u denetci touch /data/finans/t.txt >/dev/null 2>&1 && echo "❌ Denetçi Yazma (olmamalı!)" || echo "✅ Denetçi Yazma Engeli"
echo "✅ Testler Tamamlandı"
```

## Özet Tablo

| Test | Beklenen | Durum |
|------|----------|-------|
| Git Repo | Başlatılmış | ✅ |
| Gruplar | finans, ik, denetci | ✅ |
| SGID | 2770 + s harfi | ✅ |
| ACL | denetci:r-x | ✅ |
| Çapraz Erişim | Engellenmiş | ✅ |
| Denetçi Okuma | Başarılı | ✅ |
| Denetçi Yazma | Engellenmiş | ✅ |

