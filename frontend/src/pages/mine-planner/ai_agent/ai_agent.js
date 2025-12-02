const WEBHOOK_URL = "https://pojer26018.app.n8n.cloud/webhook-test/chatai"; // Ganti dengan URL webhook backend Anda

// Ambil pesan dari user yang dikirim melalui Webhook
const userMessage = $json.message;

// Kembalikan sebagai object baru bernama "prompt"
return [
    {
        prompt: userMessage
    }
];
