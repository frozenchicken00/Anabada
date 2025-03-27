import consumer from "./consumer"

export default function createConversationChannel(conversationId) {
  const channel = consumer.subscriptions.create(
    {
      channel: "ConversationChannel",
      conversation_id: conversationId
    },
    {
      connected() {
        console.log("Connected to ConversationChannel")
        const statusElement = document.getElementById('connection-status');
        if (statusElement) {
          statusElement.textContent = 'Online';
          statusElement.classList.remove('offline');
          statusElement.classList.add('online');
          statusElement.title = 'Online';
        }
      },

      disconnected() {
        console.log("Disconnected from ConversationChannel")
        const statusElement = document.getElementById('connection-status');
        if (statusElement) {
          statusElement.textContent = 'Offline';
          statusElement.classList.remove('online');
          statusElement.classList.add('offline');
          statusElement.title = 'Offline';
        }
      },

      received(data) {
        console.log("Received message:", data)
        
        if (data.message) {
          // Add message to conversation
          const messages = document.getElementById('messages');
          if (!messages) return;
          
          const currentDate = new Date(data.message.created_at).toDateString();
          const lastDateSeparator = messages.querySelector('.date-separator:last-of-type span');
          const lastDateString = lastDateSeparator ? lastDateSeparator.textContent.trim() : '';
          
          // Check if we need a new date separator
          let needsDateSeparator = true;
          
          if (lastDateSeparator) {
            // Convert display text back to actual date for comparison
            let lastDateObj;
            if (lastDateString === 'Today') {
              lastDateObj = new Date();
            } else if (lastDateString === 'Yesterday') {
              lastDateObj = new Date();
              lastDateObj.setDate(lastDateObj.getDate() - 1);
            } else {
              lastDateObj = new Date(lastDateString);
            }
            
            needsDateSeparator = lastDateObj.toDateString() !== currentDate;
          }
          
          if (needsDateSeparator) {
            const separator = document.createElement('div');
            separator.className = 'date-separator my-3';
            
            let dateDisplay;
            const today = new Date().toDateString();
            const yesterday = new Date();
            yesterday.setDate(yesterday.getDate() - 1);
            
            if (currentDate === today) {
              dateDisplay = 'Today';
            } else if (currentDate === yesterday.toDateString()) {
              dateDisplay = 'Yesterday';
            } else {
              const date = new Date(data.message.created_at);
              dateDisplay = date.toLocaleDateString('en-US', { 
                month: 'long',
                day: 'numeric',
                year: 'numeric'
              });
            }
            
            separator.innerHTML = `<span>${dateDisplay}</span>`;
            messages.appendChild(separator);
          }
          
          // Create message element
          const messageDiv = document.createElement('div');
          
          // Add the message HTML
          if (data.message_html) {
            messageDiv.innerHTML = data.message_html;
            messages.appendChild(messageDiv.firstElementChild);
          } else {
            // Fallback if no HTML provided
            const currentUserId = parseInt(document.querySelector('meta[name="current-user-id"]').content);
            const isCurrentUser = data.message.user_id === currentUserId;
            
            const messageEl = document.createElement('div');
            messageEl.className = `message ${isCurrentUser ? 'message-sent' : 'message-received'}`;
            messageEl.setAttribute('data-message-id', data.message.id);
            
            // Add avatar only for received messages
            if (!isCurrentUser) {
              const avatarDiv = document.createElement('div');
              avatarDiv.className = 'message-avatar';
              
              const userInitial = data.message.user.username ? 
                data.message.user.username.charAt(0).toUpperCase() : 'A';
              
              avatarDiv.innerHTML = `
                <div class="avatar-circle avatar-sm bg-info text-white">
                  ${userInitial}
                </div>
              `;
              messageEl.appendChild(avatarDiv);
            }
            
            // Create message content
            const messageContent = document.createElement('div');
            messageContent.className = 'message-content';
            
            const messageBubble = document.createElement('div');
            messageBubble.className = 'message-bubble';
            messageBubble.textContent = data.message.body;
            
            const messageInfo = document.createElement('div');
            messageInfo.className = 'message-info';
            
            const messageTime = document.createElement('span');
            messageTime.className = 'message-time';
            messageTime.textContent = new Date(data.message.created_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
            
            messageInfo.appendChild(messageTime);
            
            // Add read status for sent messages
            if (isCurrentUser) {
              const messageStatus = document.createElement('span');
              messageStatus.className = 'message-status';
              messageStatus.innerHTML = '<i class="bi bi-check2" title="Sent"></i>';
              messageInfo.appendChild(messageStatus);
            }
            
            messageContent.appendChild(messageBubble);
            messageContent.appendChild(messageInfo);
            messageEl.appendChild(messageContent);
            
            messages.appendChild(messageEl);
          }
          
          // Scroll to bottom
          messages.scrollTop = messages.scrollHeight;
          
          // Play sound if message is from other user
          const currentUserId = parseInt(document.querySelector('meta[name="current-user-id"]').content);
          if (data.message.user_id !== currentUserId) {
            const sound = document.getElementById('message-sound');
            if (sound) sound.play().catch(e => console.log("Failed to play sound:", e));
          }
          
          // Clear "no messages" placeholder if exists
          const placeholder = messages.querySelector('.text-center.py-5');
          if (placeholder) {
            placeholder.remove();
          }
        }
      },
      
      sendMessage(body) {
        this.perform('send_message', { body });
      }
    }
  );
  
  return channel;
}
