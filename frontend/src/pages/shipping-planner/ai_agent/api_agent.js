export default async function handler(req, res) {
    if (req.method !== 'POST') {
        return res.status(405).json({ message: 'Method not allowed' });
    }

    const { message, history } = req.body;

    try {
        // Panggil AI agent Anda di sini
        const aiResponse = await fetch('https://pojer26018.app.n8n.cloud/webhook/chatai', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                message,
                history
            })
        });

        const data = await aiResponse.json();

        res.status(200).json({
            message: data.response // sesuaikan dengan response AI Anda
        });

    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({
            message: 'Error connecting to AI agent'
        });
    }
}