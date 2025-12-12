## Diagnosa Singkat

* Frontend memuat script sebagai ES Module (`weekly_periods.html`:319) sehingga fungsi di `weekly_periods.js` tidak otomatis ada di global scope.

* `renderPeriodsTable` membuat tombol dengan `onclick="editPeriod(...)"` dan `onclick="deletePeriod(...)"` (`weekly_periods.js`:213–221) serta tombol retry error `onclick="loadWeeklyPeriods()"` (`weekly_periods.js`:92). Karena ESM, fungsi tersebut tidak ditemukan → `Uncaught ReferenceError: loadWeeklyPeriods is not defined`.

* Semua request memakai `API_BASE_URL = import.meta.env?.VITE_API_BASE_URL || "http://localhost:3000/api"` (`weekly_periods.js`:1). Di Vercel Anda membuka berkas dari `src`, sehingga `import.meta.env` tidak di-inject (build tidak terjadi) dan fallback ke `http://localhost:3000/api`. Dari halaman HTTPS, panggilan ke HTTP/localhost diblokir (mixed content/CORS) → `AxiosError: ERR_NETWORK`.

* Backend CORS hanya mengizinkan origin dari `FRONTEND_URL` env atau daftar localhost dev (`backend/src/index.js`:20–46). Domain Vercel harus ditambahkan.

## Solusi Frontend (tanpa mengubah logika)

1. Ekspor fungsi yang dipanggil via `onclick` ke `window` di akhir `weekly_periods.js` agar kompatibel dengan ESM:

   ```js
   // Tambahkan di paling bawah weekly_periods.js
   window.loadWeeklyPeriods = loadWeeklyPeriods;
   window.editPeriod = editPeriod;
   window.deletePeriod = deletePeriod;
   ```

   * Ini tidak mengubah isi/flow fungsi; hanya membuatnya dapat diakses dari HTML inline `onclick`.

2. Pastikan deployment memuat hasil build Vite (folder `dist`), bukan `src`:

   * Konfigurasi Vercel: Framework = Vite, Build Command = `vite build`, Output Directory = `dist`.

   * Akses halaman melalui path yang dihasilkan build, bukan `src/pages/...`.

3. Set environment variable di Vercel agar base URL tidak fall back ke localhost:

   * Tambahkan `VITE_API_BASE_URL` di Vercel (Project Settings → Environment Variables), isi dengan URL backend yang valid dan HTTPS, misalnya: `https://<domain-backend>/api`.

   * Rebuild & redeploy frontend agar `import.meta.env` di-inject.

## Solusi Backend/CORS

1. Tambahkan domain Vercel ke `FRONTEND_URL` env di backend:

   * Contoh: `FRONTEND_URL=https://capstone-project-asahkareem-team.vercel.app` (boleh comma-separated jika multi-origin) (`backend/src/index.js`:20–46 akan otomatis mengizinkan origin ini).
2. Pastikan backend dapat diakses via HTTPS publik. Jika belum:

   * Deploy backend ke layanan yang menyediakan HTTPS (Railway/Render/Fly.io/Heroku), catat base URL.

   * Gunakan base URL tersebut untuk `VITE_API_BASE_URL` di frontend.

## Penyesuaian URL & Endpoint (verifikasi)

* Frontend memanggil:

  * List: `GET ${API_BASE_URL}/weekly-periods` (`weekly_periods.js`:73)

  * Detail: `GET ${API_BASE_URL}/weekly-periods/:id` (`weekly_periods.js`:292–295)

  * Create: `POST ${API_BASE_URL}/weekly-periods` (`weekly_periods.js`:256–261)

  * Update: `PUT ${API_BASE_URL}/weekly-periods/:id` (`weekly_periods.js`:336–339)

  * Delete: `DELETE ${API_BASE_URL}/weekly-periods/:id` (`weekly_periods.js`:378–380)

  * Generate next: `POST ${API_BASE_URL}/weekly-periods/generate-next` (`weekly_periods.js`:405–407)

* Backend route prefix: `/api/weekly-periods` (`backend/src/index.js`:67), handler sesuai (`backend/src/routes/weekly_periods_route.js`:14–21). Response shape `data: [...]` sesuai ekspektasi frontend (`backend/src/controllers/weekly_periods_controller.js`:3–11).

## Langkah Deploy Ulang yang Pasti Memperbaiki

1. Backend:

   * Set `FRONTEND_URL=https://capstone-project-asahkareem-team.vercel.app`.

   * Pastikan backend online di HTTPS publik, catat `https://<domain>/api`.
2. Frontend:

   * Tambahkan `VITE_API_BASE_URL=https://<domain>/api` di Vercel env.

   * Pastikan build Vite: `vite build` → `dist`.

