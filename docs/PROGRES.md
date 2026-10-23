# Progres Pengerjaan

Rancangan lengkap: [RANCANGAN.md](RANCANGAN.md). Perbarui file ini setiap
selesai satu sesi kerja.

**Status:** `[x]` selesai, `[~]` sebagian / perlu dicek, `[ ]` belum.

## Ringkasan terakhir

**23 Okt 2026**: v2 selesai di kode (F1, F2, F3, F4, F5, F7).
`flutter analyze` bersih, **50 tes lolos**. Tampilan dicek lewat tangkapan
layar dengan font asli (terang & gelap). **Belum di-build ke HP.**

Langkah berikutnya: build APK dan uji di HP (lihat "Perlu dicek di HP").

---

## Versi 1

- [x] Onboarding: berat, level, target hari/minggu
- [x] Beranda: latihan hari ini, ringkasan, grafik mingguan
- [x] Pustaka 19 program berbasis riset (seluruh tubuh + 5 bagian tubuh × 3 level)
- [x] Pemutar latihan: waktu & repetisi, istirahat, pemanasan/pendinginan
- [x] Layar tetap menyala saat latihan (`wakelock_plus`)
- [x] Redesign "resep gerak" + font + mode gelap
- [x] Figur animasi untuk semua gerakan
- [x] Riwayat sesi (hapus dengan geser)

## Versi 2

| # | Fitur | Status | Catatan |
|---|---|---|---|
| F1 | Panduan suara | [~] | Logika & UI selesai dan dites. Suara asli TTS belum didengar di HP |
| F2 | Penilaian + saran level | [x] | Ringkasan latihan, kartu saran di beranda |
| F3 | Program 4 minggu | [x] | Tab Latihan → kartu "Program 4 minggu"; beranda ikut rencana |
| F4 | Latihan buatan sendiri | [x] | Tab Latihan → "Latihanku" → Buat latihan |
| F5 | Pengingat latihan | [~] | UI & jadwal selesai. Notifikasi asli belum dicoba di HP |
| F7 | Catatan berat badan | [x] | Tab Progres → "Berat badan", grafik garis |

### Perlu dicek di HP (setelah build)

- [ ] Build Android lolos. Paket baru: `flutter_tts` 4.2.3,
      `flutter_local_notifications` 19.5.0, `timezone`; desugaring diaktifkan
      di `android/app/build.gradle.kts`.
- [ ] Suara TTS bahasa Indonesia terdengar dan tidak terpotong. Jika HP belum
      punya suara Indonesia, unduh di Setelan → Bahasa → Text-to-speech.
- [ ] Izin notifikasi muncul saat pengingat dinyalakan (Android 13+).
- [ ] Notifikasi pengingat muncul di jam yang dipilih (coba set 2–3 menit ke
      depan). Di HP Xiaomi/MIUI, mungkin perlu mengizinkan "Autostart" /
      menonaktifkan penghemat baterai untuk app ini.
- [ ] Ikon notifikasi tampil (ikon putih barbel).
- [ ] Geser urutan gerakan di editor latihan buatan (tahan lalu geser).

### Batasan yang diketahui

- Pengingat tetap muncul walau hari itu sudah latihan.
- Jadwal pengingat bisa meleset beberapa menit (mode tidak-eksak, tanpa izin
  alarm presisi).
- Grafik berat hanya menampilkan label titik terakhir. Sentuh dan geser untuk
  melihat nilai titik lain.
- Sesi lama tidak dihitung ulang kalorinya saat berat berubah.
- Figur: push-up lebar/diamond terlihat sama dengan push-up biasa; Y-T raise
  hanya fase Y; pike push-up kaki di kursi memakai figur pike biasa.

---

## Berikutnya (backlog)

Urutan saran, paling bermanfaat dulu:

- [ ] **Git**: proyek belum di-version control. Disarankan `git init` + commit
      awal sebelum fitur berikutnya.
- [ ] **F6 Streak & kalender**: kalender bulanan hari latihan + rekor beruntun.
- [ ] **Cadangan data**: ekspor/impor riwayat ke file JSON (ganti HP).
- [ ] **F9 Pengingat minum**: target harian, tombol "+1 gelas", notifikasi
      berkala. Bisa memakai ulang `ReminderScheduler`.
- [ ] **F8 Widget layar utama**: latihan hari ini + progres minggu ini.
- [ ] **F10 Penghitung langkah**: sensor HP, masuk ke kalori harian.
- [ ] **F12 Health Connect**: kirim sesi latihan ke Google Fit/Samsung Health.
- [ ] **F11 Catatan makan**: kalori masuk vs keluar; butuh database makanan
      Indonesia (paling besar).
- [ ] Pengingat pintar: lewati notifikasi jika hari itu sudah latihan (butuh
      kerja latar belakang).
- [ ] Ganti nama aplikasi di launcher (masih `home_workout`) dan ikon app.

## Log sesi

| Tanggal | Yang dikerjakan |
|---|---|
| 22 Okt 2026 | v1, redesign, mode gelap, figur semua gerakan |
| 23 Okt 2026 | Dokumen rancangan & progres; v2: F1, F2, F3, F4, F5, F7 + 29 tes baru |
