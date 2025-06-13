package kr.co.genesiskorea.dao;

import java.util.HashMap;
import java.util.List;

public interface TestDao {
	public List<HashMap<String,Object>> selectUser(HashMap<String,Object> map) throws Exception;
}
