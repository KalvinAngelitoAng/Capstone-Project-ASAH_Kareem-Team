import { BASE_URL } from "../../../../pages/utils/config.js";
const API_SUMMARY = `${BASE_URL}/ai_summary/ai_summary`;

async function loadSummary() {
    const box = document.getElementById("summary-container");

    try {
        const res = await fetch(API_SUMMARY);
        const json = await res.json();

        const data = json.data;  // <<=== INI PENTING

        box.innerHTML = `
            <h2>🤖 AI Situation Analysis</h2>
            <p>${data.situation_summary}</p>

            <br>
            <strong>Baseline Target:</strong> ${data.suggested_baseline_target} tons <br>
            <strong>Current Stockpile:</strong> ${data.current_stockpile_tons} tons <br>
            <strong>Source:</strong> ${data.data_source}<br><br>

            <h3>⚠️ Alerts</h3>
            <ul>
                <li><strong>Weather:</strong> ${data.alerts.weather_alert}</li>
                <li><strong>Shipping:</strong> ${data.alerts.shipping_alert}</li>
                <li><strong>Fleet:</strong> ${data.alerts.fleet_alert}</li>
            </ul>
        `;

    } catch (err) {
        console.error("Error:", err);
        box.innerHTML = `
            <div class="alert alert-danger">
                Gagal mengambil summary dari database.
            </div>
        `;
    }
}

loadSummary();
