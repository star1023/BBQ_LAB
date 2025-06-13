package kr.co.genesiskorea.service;

import java.util.HashMap;
import java.util.List;

public interface TestService {
	public List<HashMap<String,Object>> selectUser(HashMap<String,Object> map) throws Exception;

	public void insertTrText() throws Exception;
}
