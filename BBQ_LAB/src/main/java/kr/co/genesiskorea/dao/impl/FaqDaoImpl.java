package kr.co.genesiskorea.dao.impl;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.FaqDao;

@Repository
public class FaqDaoImpl implements FaqDao {
	@Autowired
	private SqlSessionTemplate sqlSessionTemplate;

	@Override
    public int selectFaqCount(Map<String, Object> param) {
        return sqlSessionTemplate.selectOne("faq.selectFaqCount", param);
    }

    @Override
    public List<Map<String, Object>> selectFaqList(Map<String, Object> param) {
        return sqlSessionTemplate.selectList("faq.selectFaqList", param);
    }

    @Override
    public Map<String, Object> selectFaqData(Map<String, Object> param) {
        return sqlSessionTemplate.selectOne("faq.selectFaqData", param);
    }

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("faq.selectHistory", param);
	}

	@Override
	public int selectFaqSeq() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("faq.selectFaqSeq");
	}
	
    @Override
    public void insertFaq(Map<String, Object> param) throws Exception {
    	sqlSessionTemplate.insert("faq.insertFaq", param);
    }

	@Override
	public void updateFaq(Map<String, Object> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("faq.updateFaq", param);
	}
	
	@Override
	public void updateIsDeleteY(Map<String, Object> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("faq.updateIsDeleteY", param);
	}
}
