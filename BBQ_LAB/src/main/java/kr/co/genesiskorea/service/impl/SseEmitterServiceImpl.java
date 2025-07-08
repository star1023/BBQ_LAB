package kr.co.genesiskorea.service.impl;

import java.io.IOException;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import kr.co.genesiskorea.EmitterRepository;
import kr.co.genesiskorea.service.SseEmitterService;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class SseEmitterServiceImpl implements SseEmitterService {

	private final Map<String, SseEmitter> emitterMap = new ConcurrentHashMap<>();
	private static final long TIMEOUT = 60L * 60 * 1000;
	private static final long RECONNECTION_TIMEOUT = 1000L;

	@Autowired
	EmitterRepository emitterRepository;

	public SseEmitter subscribe(String userId) {
		log.info("[subscribe] userId={}", userId);
		SseEmitter emitter = createEmitter(userId);
		log.info("[subscribe] created emitter for {}", userId);
		sendToClient(userId, "FIRST");
		log.info("[subscribe] sent FIRST message to {}", userId);
		return emitter;
	}

	public void notify(String userId, Object event) {
		log.info("[notify] userId={}, event={}", userId, event);
		sendToClient(userId, event);
	}

	private void sendToClient(String id, Object data) {
		log.info("[sendToClient] id={}, data={}", id, data);
		SseEmitter emitter = emitterRepository.get(id);
		if (emitter != null) {
			try {
				emitter.send(SseEmitter.event().id(String.valueOf(id)).name("sse").data(data));
				log.info("[sendToClient] sent data to id={}", id);
			} catch(IOException exception){
				log.error("[sendToClient] send failed to id={}, error={}", id, exception.getMessage());
				emitterRepository.deleteById(id);
				emitter.completeWithError(exception);
			}
		} else {
			log.warn("[sendToClient] emitter not found for id={}", id);
		}
	}

	public void broadcast() {
		log.info("[broadcast] broadcasting to all emitters");
		Iterator<String> iterator = emitterRepository.getAll();
		while (iterator.hasNext()) {
			String id = iterator.next();
			log.info("[broadcast] sending to id={}", id);
			sendToClient(id, id);
		}
	}

	private SseEmitter createEmitter(String id) {
		log.info("[createEmitter] id={}", id);

		SseEmitter emitter = emitterRepository.get(id);

		// 기존 emitter가 있다면 ping을 보내 연결 확인
		if (emitter != null) {
			try {
				log.info("[createEmitter] testing existing emitter for id={}", id);
				emitter.send(SseEmitter.event().comment("ping")); // 테스트 메시지
				log.info("[createEmitter] existing emitter is still active: id={}", id);
				return emitter; // 그대로 재사용
			} catch (IOException e) {
				log.warn("[createEmitter] existing emitter is inactive. Replacing it: id={}", id);
				emitter.complete();
				emitterRepository.deleteById(id);
			}
		}

		// 새 emitter 생성
		emitter = new SseEmitter(TIMEOUT);
		emitterRepository.save(id, emitter);
		log.info("[createEmitter] new emitter created for id={}", id);

		emitter.onCompletion(() -> {
			log.info("[emitter.onCompletion] id={}", id);
			emitterRepository.deleteById(id);
		});
		emitter.onTimeout(() -> {
			log.warn("[emitter.onTimeout] id={}", id);
			emitterRepository.deleteById(id);
		});
		emitter.onError(e -> {
			log.error("[emitter.onError] id={}, error={}", id, e.getMessage());
			emitterRepository.deleteById(id);
		});

		return emitter;
	}
}
