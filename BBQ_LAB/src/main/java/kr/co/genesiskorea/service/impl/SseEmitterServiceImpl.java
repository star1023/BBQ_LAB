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
	
	// thread-safe 한 컬렉션 객체로 sse emitter 객체를 관리해야 한다.
	private final Map<String, SseEmitter> emitterMap = new ConcurrentHashMap<>();
	private static final long TIMEOUT = 60L * 60 * 1000;
	private static final long RECONNECTION_TIMEOUT = 1000L;
	@Autowired
	EmitterRepository emitterRepository;
	
	public SseEmitter subscribe(String userId) {
		SseEmitter emitter = createEmitter(userId);
		sendToClient(userId, "FIRST");
		return emitter;
	}
//	public SseEmitter subscribe(String userId) {
//		SseEmitter emitter = createEmitter(userId);
//		try {
//			emitter.send(SseEmitter.event()
//				.name("connect")
//				.data("connected")
//				.reconnectTime(RECONNECTION_TIMEOUT));
//		} catch (IOException e) {
//			emitter.completeWithError(e);
//		}
//		return emitter;
//	}
	
	
	public void notify(String userId, Object event) {
		sendToClient(userId, event);
	}
	
	private void sendToClient(String id, Object data) {
		SseEmitter emitter = emitterRepository.get(id);
		if (emitter != null) {
			try {
				emitter.send(SseEmitter.event().id(String.valueOf(id)).name("sse").data(data));
			} catch(IOException exception){
				emitterRepository.deleteById(id);
				emitter.completeWithError(exception);
			}
		}
	}
	
	public void broadcast() {
		Iterator<String> iterator = emitterRepository.getAll();
		while( iterator.hasNext() ) {
			String id = iterator.next();
			System.err.println("broadcast : "+id);
			sendToClient(id, id);
		}
	}
	
//	private SseEmitter createEmitter(String id) {
//		SseEmitter oldEmitter = emitterRepository.get(id);
//		if (oldEmitter != null) {
//			oldEmitter.complete();
//			emitterRepository.deleteById(id);
//		}
//
//		SseEmitter emitter = new SseEmitter(TIMEOUT);
//		emitterRepository.save(id, emitter);
//
//		emitter.onCompletion(() -> {
//			emitterRepository.deleteById(id);
//		});
//		emitter.onTimeout(() -> {
//			emitterRepository.deleteById(id);
//		});
//		emitter.onError(e -> {
//			emitterRepository.deleteById(id);
//		});
//
//		return emitter;
//	}
	private SseEmitter createEmitter(String id) {
		SseEmitter emitter = emitterRepository.get(id);
		
		if( emitter == null ) {
			emitter = new SseEmitter(TIMEOUT);
			emitterRepository.save(id, emitter);
		}
	 
		// Emitter가 완료될 때(모든 데이터가 성공적으로 전송된 상태) Emitter를 삭제한다.
		emitter.onCompletion(() -> emitterRepository.deleteById(id));
		// Emitter가 타임아웃 되었을 때(지정된 시간동안 어떠한 이벤트도 전송되지 않았을 때) Emitter를 삭제한다.
		emitter.onTimeout(() -> emitterRepository.deleteById(id));
		// Emitter 중 오류가났을 때 Emitter를 삭제한다.
		emitter.onError(e -> emitterRepository.deleteById(id));
		
		return emitter;
	}

	
	/*@Override
	public SseEmitter subscribe(String id) {
		// TODO Auto-generated method stub
		SseEmitter emitter = createEmitter();
		//연결 세션 timeout 이벤트 핸들러 등록
		emitter.onTimeout(() -> {
			log.info("server sent event timed out : id={}", id);
            //onCompletion 핸들러 호출
			emitter.complete();
		});

		//에러 핸들러 등록
		emitter.onError(e -> {
			log.info("server sent event error occurred : id={}, message={}", id, e.getMessage());
            //onCompletion 핸들러 호출
			emitter.complete();
		});

		//SSE complete 핸들러 등록
		emitter.onCompletion(() -> {
			if (emitterMap.remove(id) != null) {
				log.info("server sent event removed in emitter cache: id={}", id);
			}

			log.info("disconnected by completed server sent event: id={}", id);
		});

		emitterMap.put(id, emitter);

		//초기 연결시에 응답 데이터를 전송할 수도 있다.
		try {
			SseEmitter.SseEventBuilder event = SseEmitter.event()
				//event 명 (event: event example)
				.name("event example")
				//event id (id: id-1) - 재연결시 클라이언트에서 `Last-Event-ID` 헤더에 마지막 event id 를 설정
				.id(String.valueOf("id-1"))
				//event data payload (data: SSE connected)
				.data("SSE connected")
				//SSE 연결이 끊어진 경우 재접속 하기까지 대기 시간 (retry: <RECONNECTION_TIMEOUT>)
				.reconnectTime(RECONNECTION_TIMEOUT);
			emitter.send(event);
		} catch (IOException e) {
			log.error("failure send media position data, id={}, {}", id, e.getMessage());
		}
		return emitter;
	}
	
	public void broadcast(Object data) {
		emitterMap.forEach((id, emitter) -> {
			try {
				emitter.send(SseEmitter.event()
					.name("broadcast event")
					.id("broadcast event 1")
					.reconnectTime(RECONNECTION_TIMEOUT)
					.data(data));
				log.info("sended notification, id={}, payload={}", id, data);
			} catch (IOException e) {
				//SSE 세션이 이미 해제된 경우
				log.error("fail to send emitter id={}, {}", id, e.getMessage());
			}
		});
	}
	
	private SseEmitter createEmitter() {
		return new SseEmitter(TIMEOUT);
	}*/

}
