# Rancangan Aplikasi Home Workout

Dokumen ini mencatat apa yang dibangun, kenapa, dan keputusan teknisnya.
Status pengerjaan ada di [PROGRES.md](PROGRES.md).

## Tujuan

Aplikasi latihan di rumah untuk dipakai sendiri: latihan tanpa alat yang
berdasar riset, dipandu langkah demi langkah, plus pencatat kalori, durasi,
dan progres mingguan. Semua data disimpan di HP (tanpa akun, tanpa server).

**Bukan tujuan (untuk sekarang):** fitur sosial, akun/cloud, langganan,
video latihan.

**Anti-tujuan:** latihan tanpa dasar yang jelas, angka kalori yang dilebihkan,
layar yang ramai sampai susah dibaca saat napas ngos-ngosan.

## Prinsip

1. **Berdasar bukti.** Setiap program punya rujukan (ACSM, WHO, studi EMG ACE,
   McMaster, 7-Minute Workout, RCAF 5BX). Kalori memakai MET dari 2024
   Compendium of Physical Activities, cenderung konservatif.
2. **Terbaca dari jauh.** Saat latihan, fase dibedakan dengan warna penuh
   (kunyit = gerak, air = istirahat, matras = pemanasan/pendinginan), angka
   besar, dan sekarang juga suara.
3. **Lokal dan ringan.** `shared_preferences` untuk data, tanpa backend.

## Teknologi

- Flutter 3.29 / Dart 3.7, Material 3, Android (portrait).
- State: `ChangeNotifier` (`AppState`) + `InheritedNotifier` (`AppScope`).
- Paket: `shared_preferences`, `wakelock_plus` 1.2.10, `flutter_tts` 4.2.3,
  `flutter_local_notifications` 19.5.0, `timezone` 0.10.1.
- Versi paket sengaja dikunci: proyek Android memakai Kotlin 1.8.22 dan
  AGP 8.7. `wakelock_plus` ≥1.4 dan `flutter_tts` ≥4.2.4 butuh Kotlin 2.2 /
  minSdk 24, jadi tidak dipakai.
- Desain "resep gerak": Plus Jakarta Sans + Barlow Condensed (angka), palet
  terang/gelap di `lib/theme.dart` (`context.palette`), figur gerakan digambar
  dengan kode (`lib/widgets/exercise_figure.dart`).

## Struktur kode

| Folder | Isi |
|---|---|
| `lib/models` | Data murni: gerakan, program, sesi, rencana 4 minggu, latihan buatan, berat badan |
| `lib/data` | Pustaka gerakan & program berbasis riset, pose figur |
| `lib/services` | Logika tanpa UI: timer latihan, kalori, statistik, isyarat suara, saran level, rencana 4 minggu, pengingat |
| `lib/state` | `AppState`: penyimpanan & pengaturan |
| `lib/screens`, `lib/widgets` | Tampilan |

Layanan yang menyentuh platform (suara, notifikasi) diberi antarmuka
(`Speaker`, `ReminderScheduler`) dengan versi senyap untuk tes. `AppState`
memakai versi senyap secara default; `main.dart` memasang versi asli.

---

## Versi 1 (selesai)

- Onboarding: berat badan, level (pemula/menengah/lanjutan), target hari/minggu.
- Beranda: kartu latihan hari ini (dirotasi per hari sesuai level), ringkasan
  hari ini & minggu ini, grafik batang mingguan.
- Pustaka 19 program: 4 protokol riset seluruh tubuh + 15 program kekuatan
  (dada, perut, kaki, tubuh atas, tubuh bawah × 3 level).
- Pemutar latihan: hitung mundur, gerakan waktu & repetisi, istirahat (+20 dtk),
  pemanasan/pendinginan, layar tetap menyala, getar di pergantian fase.
- Figur animasi untuk semua gerakan, mode gelap, riwayat sesi.

## Versi 2

### F1. Panduan suara

**Kenapa:** saat plank atau push-up, mata tidak bisa ke layar.

- Diucapkan dengan TTS bawaan HP, bahasa Indonesia (`id-ID`).
- Isyarat (`voiceCue` di `lib/services/voice_coach.dart`, fungsi murni):
  - Awal latihan: "Bersiap. Gerakan pertama, {nama}."
  - Mulai gerakan inti: "{nama}, {12 kali | 10 kali per sisi | 30 detik}."
  - Mulai pemanasan/pendinginan/pemulihan: "Pemanasan, {nama}." dst.
  - Mulai istirahat: "Istirahat {n} detik. Berikutnya, {nama}."
  - Setengah waktu gerakan inti berdurasi ≥20 detik: "Setengah jalan."
  - Hitung mundur "tiga, dua, satu" di 3 detik terakhir fase berwaktu ≥10 detik.
  - Selesai: "Latihan selesai. Kerja bagus."
- Saat dijeda, suara dihentikan dan tidak ada isyarat.
- Bisa dimatikan di Pengaturan dan lewat tombol speaker di layar latihan
  (keduanya mengubah pengaturan yang sama). Default: menyala.
- Kalau mesin TTS tidak ada / bahasa Indonesia tidak tersedia, aplikasi tetap
  jalan tanpa suara (galat ditelan).

### F2. Penilaian setelah latihan & saran level

**Kenapa:** pedoman ACSM menyarankan naik beban/variasi jika latihan sudah
terasa ringan ("masih sanggup 1–2 repetisi lebih").

- Layar ringkasan bertanya "Bagaimana rasanya?": Terlalu ringan / Pas /
  Terlalu berat. Opsional; disimpan di sesi (`WorkoutSession.effort`).
- Saran (`adviseLevel` di `lib/services/progression.dart`):
  - 3 sesi terakhir yang dinilai (program pustaka, level = level pengguna)
    semuanya "terlalu ringan" → sarankan naik level (kecuali sudah lanjutan).
  - 2 sesi terakhir yang dinilai semuanya "terlalu berat" → sarankan turun
    level (kecuali sudah pemula).
  - Hanya menghitung sesi setelah level terakhir diubah dan setelah saran
    terakhir ditutup ("Nanti"), supaya saran tidak muncul terus.
  - Latihan buatan sendiri tidak ikut dihitung.
- Saran muncul di beranda (di atas kartu latihan) dan di layar ringkasan,
  dengan tombol "Ganti ke {level}" dan "Nanti".

### F3. Program bertahap 4 minggu

**Kenapa:** rotasi harian v1 tidak punya arah; progresi bertahap (overload
progresif) adalah inti model progresi ACSM.

- Satu rencana aktif: level + jumlah sesi/minggu + tanggal mulai.
- Jumlah sesi per minggu = target mingguan, dibatasi 2–6 (minimal 2 hari
  latihan kekuatan per minggu sesuai WHO/ACSM; maksimal 6 supaya ada hari
  istirahat).
- Pembagian bagian tubuh per minggu:

  | Sesi/minggu | Urutan |
  |---|---|
  | 2 | Tubuh atas, Tubuh bawah |
  | 3 | Dada, Kaki, Perut |
  | 4 | Tubuh atas, Tubuh bawah, Perut, Seluruh tubuh |
  | 5 | Dada, Kaki, Perut, Tubuh atas, Tubuh bawah |
  | 6 | Dada, Kaki, Perut, Tubuh atas, Tubuh bawah, Seluruh tubuh |

- Progresi per minggu (hanya untuk program kekuatan dan 7-Minute Workout;
  protokol riset 5BX dan McMaster dijalankan apa adanya sesuai studinya):
  - Minggu 1: takaran dasar.
  - Minggu 2: istirahat dipersingkat 10 detik (min. 10 detik).
  - Minggu 3: +1 putaran, istirahat normal.
  - Minggu 4: +1 putaran dan istirahat dipersingkat.
- Minggu berjalan dihitung dari tanggal mulai (7 hari per minggu), bukan
  minggu kalender. Sesi tercatat "selesai" jika program varian minggu itu
  diselesaikan dalam rentang minggu tersebut. Sesi yang terlewat tidak
  menggeser jadwal.
- Beranda: jika rencana aktif, kartu "latihan hari ini" menampilkan sesi
  berikutnya dari rencana. Jika target minggu ini sudah tuntas, kartu kembali
  ke rotasi harian sebagai latihan tambahan.
- Setelah minggu 4: tampil ringkasan dan tawaran memulai lagi (di level
  berikutnya jika belum lanjutan).
- Masuk dari kartu di atas tab Latihan.

### F4. Latihan buatan sendiri

- Pilih gerakan dari semua gerakan berfigur (dikelompokkan per kategori),
  atur jumlah repetisi atau detik per gerakan, urutan (geser), putaran (1–5),
  istirahat (0–60 detik), dan opsi pemanasan + pendinginan 1 menit.
- Bawaan saat gerakan ditambahkan: jika di pustaka gerakan itu berbasis
  repetisi → 10 kali (per sisi bila perlu), selain itu 30 detik.
- Disimpan sebagai `CustomWorkout` (JSON) dan diubah jadi `WorkoutProgram`
  saat dijalankan (id `custom:<id>`), jadi pemutar, kalori, figur, dan suara
  bekerja sama persis.
- Tampil di bagian "Latihanku" di tab Latihan, bisa diubah dan dihapus.
- Detail latihan buatan menampilkan panduan menyusun latihan (ACSM) alih-alih
  rujukan studi, dan tidak menampilkan level.

### F5. Pengingat latihan

- Notifikasi mingguan di jam dan hari pilihan (default 17.00; hari bawaan
  mengikuti target mingguan).
- `flutter_local_notifications` dengan jadwal tidak-eksak
  (`inexactAllowWhileIdle`) supaya tidak perlu izin alarm tepat waktu; bisa
  meleset beberapa menit, cukup untuk pengingat.
- Zona waktu: dicari lokasi di database `timezone` yang offset-nya sama dengan
  offset HP (diutamakan Asia/Jakarta, Makassar, Jayapura). Tidak perlu plugin
  tambahan; untuk negara dengan DST bisa meleset 1 jam saat pergantian musim.
- Izin notifikasi Android 13+ diminta saat pengingat dinyalakan. Jika ditolak,
  pengingat tetap mati dan muncul pesan.
- Jadwal dipasang ulang setiap aplikasi dibuka dan saat pengaturan berubah;
  setelah HP restart dipulihkan oleh receiver bawaan plugin.
- Batasan: notifikasi tetap muncul walau hari itu sudah latihan (butuh kerja
  latar belakang, ditunda).

### F7. Catatan berat badan

- Riwayat berat (`WeightEntry`: tanggal + kg). Satu entri per hari; mencatat
  lagi di hari yang sama menimpa entri hari itu.
- Mencatat berat memperbarui berat profil, sehingga perkiraan kalori latihan
  berikutnya ikut akurat. Sesi lama tidak dihitung ulang.
- Mengubah berat di Pengaturan juga masuk riwayat.
- Data lama: jika riwayat kosong tetapi berat profil ada, berat profil menjadi
  entri pertama.
- Tab Progres: berat terbaru, selisih sejak catatan pertama, grafik garis
  (≥2 catatan), dan tombol "Catat berat".

---

## Ditunda (lihat PROGRES.md)

F6 streak & kalender, F8 widget layar utama, F9 pengingat minum, F10
penghitung langkah, F11 catatan makan, F12 Health Connect, git, cadangan data.
