## Inti Masalah
- Anda membuka halaman dari path build yang salah: `/src/pages/.../*.html` di Vercel. Vite meng-output file HTML di root `dist` (sesuai `vite.config.js`), misalnya `weeklyPeriods.html`, `employees.html`, `equipment.html`, `dailyEquipment.html`. Mengakses `/src/...` membuat modul ESM dan env tidak ter-inject serta rute statis tidak ada → data gagal.
- Variabel env frontend yang dipakai halaman berbeda-beda (`VITE_API_BASE_URL`, `VITE_BASE_URL`, `VITE_API_BASE`) dan saat diset ke domain frontend, request API menjadi `https://frontend-domain/...` → 404. 
- Ada ketidakkonsistenan prefix route backend: 
  - Dengan prefix `/api`: `weekly-periods`, `daily-equipment-status`, `auth`.
  - Tanpa prefix `/api`: `employees`, `equipments`, `daily-reports`, `weekly-schedules`, `daily-attendance`, dll (`backend/src/index.js:55–87`).
  - Frontend halaman (`employees.js`, `equipment.js`, `weekly_periods.js`) semuanya menambah resource di atas satu base saja, sehingga satu nilai env tidak bisa cocok untuk semua (hasilnya 404 di sebagian halaman).

## Solusi Aman (tanpa merusak logika)
1. Akses halaman build yang benar (tanpa ubah kode):
   - `https://capstone-project-asahkareem-team.vercel.app/weeklyPeriods.html`
   - `https://capstone-project-asahkareem-team.vercel.app/employees.html`
   - `https://capstone-project-asahkareem-team.vercel.app/equipment.html`
   - `https://capstone-project-asahkareem-team.vercel.app/dailyEquipment.html`
   - Jika Anda tetap ingin mempertahankan URL `/src/...`, saya akan menambahkan rewrite di `vercel.json` untuk memetakan semua `/src/pages/.../*.html` ke output build yang sesuai.

2. Benahi env di frontend agar selalu mengarah ke backend (bukan frontend):
   - Set satu sumber kebenaran: `VITE_BACKEND_ORIGIN = https://<domain-backend>` (tanpa `/api`).
   - Opsional, untuk kompatibilitas yang sudah ada: 
     - `VITE_API_BASE_URL = https://<domain-backend>/api`
     - `VITE_BASE_URL = https://<domain-backend>`
     - `VITE_API_BASE = https://<domain-backend>/api/auth`
   - Pastikan build ulang frontend setelah menyetel env.

3. Perbaiki konstruksi URL di halaman yang terpengaruh agar cocok dengan prefix backend yang sebenarnya, tanpa mengubah logika bisnis:
   - `weekly_periods.js` → gunakan `VITE_BACKEND_ORIGIN` lalu tambahkan `'/api/weekly-periods'` eksplisit.
   - `daily_equipment_status_persistent.js` → gunakan `VITE_BACKEND_ORIGIN` lalu tambahkan `'/api/daily-equipment-status'` eksplisit.
   - `employees.js` → gunakan `VITE_BACKEND_ORIGIN` lalu tambahkan `'/employees'`.
   - `equipment.js` → gunakan `VITE_BACKEND_ORIGIN` lalu tambahkan `'/equipments'`.
   - Ini hanya mengubah cara membangun URL, bukan alur/fungsi (logika tetap sama).

4. Lengkapi rewrite Vercel agar URL lama tetap berfungsi:
   - Tambah aturan rewrite berikut: 
     - `/src/pages/mine-planner/weekly_periods/weekly_periods.html` → `/weeklyPeriods.html`
     - `/src/pages/mine-planner/employees/employees.html` → `/employees.html`
     - `/src/pages/mine-planner/equipment/equipment.html` → `/equipment.html`
     - `/src/pages/mine-planner/daily-equipment-status/daily_equipment_status.html` → `/dailyEquipment.html`
   - Ini memastikan akses via `/src/...` akan tetap diarahkan ke hasil build.

5. Backend CORS sudah benar:
   - `FRONTEND_URL` telah berisi semua domain Vercel (cek `backend/.env` dan Railway). Tidak perlu perubahan jika sudah muncul hijau.

## Implementasi yang Saya akan lakukan
- Tambah helper aman di masing-masing halaman untuk membaca `VITE_BACKEND_ORIGIN` dan membentuk endpoint sesuai prefix backend (tanpa mengubah struktur fungsi/handler yang ada).
- Tambah rewrite di `vercel.json` untuk semua halaman yang Anda sebut agar URL `/src/...` tetap bekerja.
- Dokumentasi ringan di README bagian deploy (sudah ditambah) agar env terset konsisten.

## Hasil yang Diharapkan
- Semua halaman data (Weekly Periods, Employees, Equipment, Daily Equipment Status) berhasil memuat data dari database di deployment Vercel.
- Tidak ada perubahan logika bisnis: hanya perbaikan konstruksi URL dan routing static.
- Tidak muncul lagi 404 maupun `ERR_NETWORK` selama env frontend menunjuk ke backend.

Apabila disetujui, saya akan langsung melakukan perubahan kecil pada empat file JS tersebut untuk membenahi base URL dan menambahkan rewrite Vercel agar URL `/src/...` tetap valid.