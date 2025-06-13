package kr.co.genesiskorea.controller;

import java.util.UUID;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import kr.co.genesiskorea.service.SseEmitterService;
//import kr.co.genesiskorea.service.SseEmitterService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequiredArgsConstructor
@Slf4j
public class SSEController {
	private final SseEmitterService sseEmitterService;
	
	@CrossOrigin(origins = "http://localhost:8080") //  CORS 문제를 해결하기 위해 추가
	@GetMapping(value = "/subscribe/{id}", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
	public SseEmitter subscribe(@PathVariable String id) {
		return sseEmitterService.subscribe(id);
	}
	
	@PostMapping("/send-data/{id}")
	public void sendData(@PathVariable String id) {
		sseEmitterService.notify(id, id);
	}
	
	@PostMapping("/send-data/broadcast")
	public void broadcast() {
		sseEmitterService.broadcast();
	}
	
	/*
	//응답 mime type 은 반드시 text/event-stream 이여야 한다.
	//클라이언트로 부터 SSE subscription 을 수락한다.
	@GetMapping(path = "/v1/sse/subscribe", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
	public ResponseEntity<SseEmitter> subscribe() {
		String sseId = UUID.randomUUID().toString();
		SseEmitter emitter = sseEmitterService.subscribe(sseId);
		return ResponseEntity.ok(emitter);
	}
	
	//eventPayload 를 SSE 로 연결된 모든 클라이언트에게 broadcasting 한다.
	@PostMapping(path = "/v1/sse/broadcast")
	public ResponseEntity<Void> broadcast(@RequestBody Object eventPayload) {
		sseEmitterService.broadcast(eventPayload);
		return ResponseEntity.ok().build();
	}
	*/
}
