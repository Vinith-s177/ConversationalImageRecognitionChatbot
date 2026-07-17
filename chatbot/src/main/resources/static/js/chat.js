document.addEventListener('DOMContentLoaded', function() {
    const chatForm = document.getElementById('chatForm');
    const chatInput = document.getElementById('chatInput');
    const chatMessages = document.getElementById('chatMessages');
    const typingIndicator = document.getElementById('typingIndicator');
    const copyOcrBtn = document.getElementById('copyOcrBtn');
    const ocrTextVal = document.getElementById('ocrTextVal');

    // Auto-scroll chat to the bottom initially
    scrollToBottom();

    // Render colors for visual indicators
    renderVisualColors();

    function renderVisualColors() {
        document.querySelectorAll('[data-color]').forEach(el => {
            const colorText = el.getAttribute('data-color').toLowerCase().trim();
            let cssColor = colorText;
            
            if (colorText.includes('golden') || colorText.includes('yellow')) {
                cssColor = '#eab308';
            } else if (colorText.includes('neon') || colorText.includes('lush') || colorText.includes('green')) {
                cssColor = '#10b981';
            } else if (colorText.includes('silver') || colorText.includes('metallic')) {
                cssColor = 'linear-gradient(135deg, #cbd5e1 0%, #94a3b8 100%)';
            } else if (colorText.includes('white and grey') || colorText.includes('white and gray')) {
                cssColor = 'linear-gradient(135deg, #ffffff 0%, #94a3b8 100%)';
            } else if (colorText.includes('dark grey') || colorText.includes('dark gray')) {
                cssColor = '#475569';
            } else if (colorText.includes('grey') || colorText.includes('gray')) {
                cssColor = '#64748b';
            } else if (colorText.includes('blue')) {
                cssColor = '#3b82f6';
            } else if (colorText.includes('black')) {
                cssColor = '#0f172a';
            } else if (colorText.includes('white')) {
                cssColor = '#f8fafc';
            } else if (colorText.includes('red')) {
                cssColor = '#ef4444';
            }
            
            if (cssColor.startsWith('linear-gradient')) {
                el.style.background = cssColor;
            } else {
                el.style.backgroundColor = cssColor;
            }
        });
    }

    // OCR Copy Text function
    if (copyOcrBtn && ocrTextVal) {
        copyOcrBtn.addEventListener('click', function() {
            const rawText = ocrTextVal.innerText;
            navigator.clipboard.writeText(rawText).then(function() {
                const originalText = copyOcrBtn.innerText;
                copyOcrBtn.innerText = 'Copied! ✓';
                copyOcrBtn.style.color = '#34d399';
                copyOcrBtn.style.borderColor = 'rgba(16, 185, 129, 0.4)';
                
                setTimeout(function() {
                    copyOcrBtn.innerText = originalText;
                    copyOcrBtn.style.color = '';
                    copyOcrBtn.style.borderColor = '';
                }, 2000);
            }).catch(function(err) {
                console.error('Could not copy text: ', err);
            });
        });
    }

    // Submit message via AJAX
    if (chatForm) {
        chatForm.addEventListener('submit', function(e) {
            e.preventDefault();

            const messageText = chatInput.value.trim();
            if (!messageText) return;

            // 1. Append User Message to UI
            appendMessage('user', messageText, getCurrentTime());

            // 2. Clear input & Focus
            chatInput.value = '';
            chatInput.focus();

            // 3. Disable controls and show loader
            toggleChatControls(false);
            scrollToBottom();

            // 4. Send AJAX POST request to '/chat/send'
            fetch('/chat/send', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams({
                    'message': messageText
                })
            })
            .then(response => {
                if (!response.ok) {
                    return response.json().then(err => { throw new Error(err.error || 'Server error'); });
                }
                return response.json();
            })
            .then(data => {
                // 5. Append Bot response to UI
                if (data.success) {
                    appendMessage('bot', data.reply, data.timestamp);
                } else {
                    appendMessage('bot', 'Sorry, I couldn\'t process that message.', getCurrentTime());
                }
            })
            .catch(error => {
                console.error('Error sending message:', error);
                appendMessage('bot', 'System Error: ' + error.message, getCurrentTime());
            })
            .finally(() => {
                // 6. Enable controls and hide loader
                toggleChatControls(true);
                scrollToBottom();
            });
        });
    }

    function appendMessage(sender, content, timestamp) {
        const messageDiv = document.createElement('div');
        messageDiv.classList.add('message', sender);

        const bubbleDiv = document.createElement('div');
        bubbleDiv.classList.add('message-bubble');
        // Render formatting simply or support basic linebreaks
        bubbleDiv.innerHTML = formatMarkdown(content);

        const metaDiv = document.createElement('div');
        metaDiv.classList.add('message-meta');
        metaDiv.innerText = timestamp;

        messageDiv.appendChild(bubbleDiv);
        messageDiv.appendChild(metaDiv);

        chatMessages.appendChild(messageDiv);
    }

    function toggleChatControls(enable) {
        if (enable) {
            chatInput.removeAttribute('disabled');
            chatForm.querySelector('button').removeAttribute('disabled');
            typingIndicator.style.display = 'none';
        } else {
            chatInput.setAttribute('disabled', 'true');
            chatForm.querySelector('button').setAttribute('disabled', 'true');
            typingIndicator.style.display = 'flex';
        }
    }

    function scrollToBottom() {
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    function getCurrentTime() {
        const now = new Date();
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        return `${hours}:${minutes}`;
    }

    // Helper function to turn simple line breaks and markdown format to html tags
    function formatMarkdown(text) {
        if (!text) return '';
        
        let formatted = text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;");

        // Format code blocks
        formatted = formatted.replace(/```([\s\S]*?)```/g, '<pre><code>$1</code></pre>');
        
        // Format bold text
        formatted = formatted.replace(/\*\*([\s\S]*?)\*\*/g, '<strong>$1</strong>');
        
        // Format bullet points
        formatted = formatted.replace(/^\s*-\s+(.+)$/gm, '<li>$1</li>');
        formatted = formatted.replace(/(<li>.*<\/li>)/g, '<ul>$1</ul>');
        
        // Fix nested lists merging issues
        formatted = formatted.replace(/<\/ul>\s*<ul>/g, '');

        // Format line breaks
        formatted = formatted.replace(/\n/g, '<br>');

        return formatted;
    }
});
