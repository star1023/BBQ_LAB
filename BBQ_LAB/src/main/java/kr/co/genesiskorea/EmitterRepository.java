package kr.co.genesiskorea;

import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Repository;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class EmitterRepository {
	private final Map<String, SseEmitter> emitters = new ConcurrentHashMap<>();
	public void save(String id, SseEmitter emitter) {
		emitters.put(id, emitter);
	}
		 
	public void deleteById(String id) {
		emitters.remove(id);
	}
		 
	public SseEmitter get(String id) {
		return emitters.get(id);
	}
	
	public Iterator<String> getAll() {
		Iterator<String> iterator = emitters.keySet().iterator();
		return iterator;
	}
}
