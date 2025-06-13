package kr.co.genesiskorea.service;

import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

public interface SseEmitterService {

	SseEmitter subscribe(String sseId);

	void notify(String id, Object string);

	void broadcast();

	//void broadcast(Object eventPayload);

}
