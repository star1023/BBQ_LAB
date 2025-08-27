package kr.co.genesiskorea.dao.impl;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.NotificationDao;

@Repository
public class NotificationDaoImpl implements NotificationDao {
	
	@Autowired
	private SqlSessionTemplate sqlSessionTemplate;

	@Override
	public int selectListCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		 return sqlSessionTemplate.selectOne("notification.selectListCount", param);
	}

	@Override
	public List<Map<String, Object>> selectList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("notification.selectList", param);
	}

}
