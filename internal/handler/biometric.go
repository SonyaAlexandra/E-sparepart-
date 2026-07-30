package handler

import (
	"encoding/json"
	"fmt"
	"log"
)

func broadcastToAllSessions(eventType string, payload interface{}) {
	data, err := json.Marshal(payload)
	if err != nil {
		return
	}

	msg := fmt.Sprintf("event: %s\ndata: %s\n\n", eventType, string(data))

	sseHubMu.Lock()
	sessions := make([]chan string, 0, len(sseHub))
	for _, ch := range sseHub {
		sessions = append(sessions, ch)
	}
	sseHubMu.Unlock()

	if len(sessions) == 0 {
		log.Println("[Biometric] Tidak ada SSE session aktif, event dibuang")
		return
	}

	for _, ch := range sessions {
		select {
		case ch <- msg:
		default:
		}
	}
}
