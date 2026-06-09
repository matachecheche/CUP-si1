{{-- Asistente de Consulta por Voz con IA (Whisper + GPT). Flotante, en toda la app. --}}
<div id="asistente-voz">
    <button type="button" id="av-fab" title="Consulta por voz" aria-label="Abrir asistente de voz">
        <i class="fas fa-microphone"></i>
    </button>
    <div id="av-panel" hidden>
        <div class="av-header">
            <span><i class="fas fa-robot"></i> Asistente CUP</span>
            <button type="button" id="av-cerrar" aria-label="Cerrar">&times;</button>
        </div>
        <div id="av-chat" class="av-chat">
            <div class="av-msg av-bot">¡Hola! 👋 Pregúntame por voz o escribiendo. Por ejemplo: «¿Cuántos postulantes aprobaron?»</div>
        </div>
        <div id="av-chips" class="av-chips"></div>
        <div class="av-input">
            <input type="text" id="av-texto" placeholder="Escribe tu consulta..." autocomplete="off">
            <button type="button" id="av-enviar" title="Enviar"><i class="fas fa-paper-plane"></i></button>
            <button type="button" id="av-mic" title="Hablar"><i class="fas fa-microphone"></i></button>
        </div>
        <div id="av-estado" class="av-estado"></div>
    </div>
</div>
<style>
    #av-fab{position:fixed;right:22px;bottom:22px;width:58px;height:58px;border:none;border-radius:50%;
        background:#2563eb;color:#fff;font-size:1.4rem;box-shadow:0 6px 20px rgba(0,0,0,.3);cursor:pointer;
        display:flex;align-items:center;justify-content:center;z-index:1080;transition:transform .15s}
    #av-fab:hover{transform:scale(1.08)}
    #av-panel{position:fixed;right:22px;bottom:22px;width:360px;max-width:calc(100vw - 24px);height:520px;
        max-height:calc(100vh - 40px);background:#fff;border-radius:14px;box-shadow:0 12px 40px rgba(0,0,0,.35);
        z-index:1081;display:flex;flex-direction:column;overflow:hidden;font-size:.9rem}
    .av-header{background:#0f172a;color:#fff;padding:12px 14px;display:flex;justify-content:space-between;
        align-items:center;font-weight:600}
    .av-header button{background:none;border:none;color:#fff;font-size:1.4rem;line-height:1;cursor:pointer}
    .av-chat{flex:1;overflow-y:auto;padding:12px;background:#f1f5f9;display:flex;flex-direction:column;gap:8px}
    .av-msg{max-width:85%;padding:8px 11px;border-radius:12px;line-height:1.35;white-space:pre-wrap;word-break:break-word}
    .av-bot{background:#e2e8f0;color:#0f172a;align-self:flex-start;border-bottom-left-radius:3px}
    .av-user{background:#2563eb;color:#fff;align-self:flex-end;border-bottom-right-radius:3px}
    .av-chips{display:flex;flex-wrap:wrap;gap:6px;padding:8px 12px;background:#fff;border-top:1px solid #e2e8f0;
        max-height:120px;overflow-y:auto}
    .av-chip{font-size:.72rem;padding:4px 9px;border:1px solid #cbd5e1;border-radius:999px;background:#f8fafc;
        color:#334155;cursor:pointer;white-space:nowrap}
    .av-chip:hover{background:#2563eb;color:#fff;border-color:#2563eb}
    .av-input{display:flex;gap:6px;padding:10px;border-top:1px solid #e2e8f0;background:#fff}
    .av-input input{flex:1;border:1px solid #cbd5e1;border-radius:8px;padding:8px 10px;outline:none}
    .av-input button{border:none;border-radius:8px;width:40px;background:#2563eb;color:#fff;cursor:pointer}
    .av-input #av-mic{background:#16a34a}
    .av-input #av-mic.av-rec{background:#dc2626;animation:avpulse 1s infinite}
    @keyframes avpulse{0%,100%{opacity:1}50%{opacity:.55}}
    .av-estado{font-size:.74rem;color:#64748b;padding:0 12px 8px;min-height:18px;background:#fff}
</style>
<script>
(function () {
    const token = document.querySelector('meta[name="csrf-token"]')?.content;
    const rutas = {
        transcribir: "{{ route('consulta-voz.transcribir') }}",
        responder:   "{{ route('consulta-voz.responder') }}",
        comandos:    "{{ route('consulta-voz.comandos') }}",
    };
    const $ = id => document.getElementById(id);
    const fab = $('av-fab'), panel = $('av-panel'), cerrar = $('av-cerrar'),
          chat = $('av-chat'), chips = $('av-chips'), input = $('av-texto'),
          enviar = $('av-enviar'), mic = $('av-mic'), estado = $('av-estado');
    let mediaRecorder = null, chunks = [], grabando = false, comandosCargados = false;
    fab.addEventListener('click', () => { panel.hidden = false; fab.style.display = 'none'; cargarComandos(); input.focus(); });
    cerrar.addEventListener('click', () => { panel.hidden = true; fab.style.display = 'flex'; window.speechSynthesis?.cancel(); });
    function burbuja(texto, quien) {
        const d = document.createElement('div');
        d.className = 'av-msg ' + (quien === 'user' ? 'av-user' : 'av-bot');
        d.textContent = texto; chat.appendChild(d); chat.scrollTop = chat.scrollHeight;
    }
    function hablar(texto) {
        if (!('speechSynthesis' in window)) return;
        const u = new SpeechSynthesisUtterance(texto); u.lang = 'es-ES';
        window.speechSynthesis.cancel(); window.speechSynthesis.speak(u);
    }
    async function responder(texto) {
        if (!texto.trim()) return;
        burbuja(texto, 'user'); input.value = ''; estado.textContent = 'Consultando...';
        try {
            const r = await fetch(rutas.responder, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': token, 'Accept': 'application/json' },
                body: JSON.stringify({ texto })
            });
            const data = await r.json();
            const resp = data.respuesta || 'No obtuve respuesta.';
            burbuja(resp, 'bot'); hablar(resp);
        } catch (e) { burbuja('Error de conexión con el asistente.', 'bot'); }
        finally { estado.textContent = ''; }
    }
    enviar.addEventListener('click', () => responder(input.value));
    input.addEventListener('keydown', e => { if (e.key === 'Enter') responder(input.value); });
    mic.addEventListener('click', async () => {
        if (grabando) { mediaRecorder.stop(); return; }
        if (!navigator.mediaDevices?.getUserMedia) { estado.textContent = 'Tu navegador no soporta micrófono.'; return; }
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            mediaRecorder = new MediaRecorder(stream); chunks = [];
            mediaRecorder.ondataavailable = e => chunks.push(e.data);
            mediaRecorder.onstop = async () => {
                grabando = false; mic.classList.remove('av-rec'); estado.textContent = 'Transcribiendo...';
                stream.getTracks().forEach(t => t.stop());
                const fd = new FormData();
                fd.append('audio', new Blob(chunks, { type: 'audio/webm' }), 'consulta.webm');
                try {
                    const r = await fetch(rutas.transcribir, {
                        method: 'POST', headers: { 'X-CSRF-TOKEN': token, 'Accept': 'application/json' }, body: fd
                    });
                    const data = await r.json(); estado.textContent = '';
                    if (data.ok && data.texto) responder(data.texto);
                    else burbuja(data.error || 'No te entendí, intenta de nuevo.', 'bot');
                } catch (e) { estado.textContent = ''; burbuja('Error al transcribir el audio.', 'bot'); }
            };
            mediaRecorder.start();
            grabando = true; mic.classList.add('av-rec');
            estado.textContent = '🔴 Grabando... toca el micrófono para terminar.';
        } catch (e) { estado.textContent = 'No se pudo acceder al micrófono.'; }
    });
    async function cargarComandos() {
        if (comandosCargados) return;
        try {
            const r = await fetch(rutas.comandos, { headers: { 'Accept': 'application/json' } });
            const data = await r.json();
            (data.comandos || []).forEach(c => {
                const b = document.createElement('button');
                b.type = 'button'; b.className = 'av-chip'; b.textContent = c.etiqueta;
                b.addEventListener('click', () => responder(c.etiqueta));
                chips.appendChild(b);
            });
            comandosCargados = true;
        } catch (e) {}
    }
})();
</script>
