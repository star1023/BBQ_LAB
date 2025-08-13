package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

public interface SystemDocTransferService {
    List<Map<String, Object>> selectUserDocs(String userId) throws Exception;
    
    /**
     * @param param { sourceUserId, targetTeamId, targetUserId, docs(List<Map>) }
     * @return { RESULT("S"/"E"/"P"), COUNT(성공건수), FAILS(List<Map>), MESSAGE }
     */
    Map<String, Object> transferDocs(Map<String, Object> param) throws Exception;
}

